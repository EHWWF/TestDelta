create or replace package costs_pkg as

    /**
     * Calculates external and internal forecasts.
     * Deletes previous forecasts.
     * Requires current plan and proper milestones within.
     */
    procedure forecast(p_id in nvarchar2);

    /**
     * Returns latest forecast number which is available in PROMIS
     */
    function get_latest_fc_number return nvarchar2;

end;
/
create or replace
package body costs_pkg as

    /*************************************************************************/
    procedure forecast(p_id in nvarchar2) as
        v_ordering number;
        v_timeline timeline%rowtype;
        begin
            notice_pkg.debug(project_pkg.get_subject(p_id), project_pkg.get_summary(p_id)||' forecast calculation started.');

            begin
                /* load current timeline */
                select * into v_timeline from timeline where project_id=p_id and type_code='CUR';

                /* Get current phase ordering */
                select ph.ordering
                into v_ordering
                from phase_mapping_vw pt
                    join phase ph on ph.code=pt.pts_phase_code
                where pt.phase_code=project_pkg.get_current_phase(p_id)
                      and ph.is_active=1;

                exception when no_data_found then
                return;
            end;

            /* drop previously generated forecasts */
            delete from costs where project_id=p_id and type_code in ('CALF');

            /* Prepare temporary table for costs_vw */
            insert into costs_tmp
                select * from costs_vw cst
                where cst.project_id=v_timeline.project_id and month is not null;

            /* generate internal costs */
            insert into costs (
                project_id,
                function_code,
                scope_code,
                method_code,
                type_code,
                cost,
                start_date,
                finish_date)
                select
                    v_timeline.project_id,
                    cst.function_code,
                    'INT',
                    'PROB',
                    'CALF',
                    round(cst.forecast * prob.probability, 10) as cost,
                    to_date(cst.year||'-'||cst.month,'yyyy-mm'),
                    last_day(to_date(cst.year||'-'||cst.month,'yyyy-mm'))
                from (
                         /* phases and their boundaries according to milestones setup
                          * start date calculated from milestone, finish date calculated from next phase start date,
                          * all dates on monthly basis */
                         select
                             ph.*,
                             greatest((lead(phase_start_date) over(order by phase_ordering))-1,last_day(phase_start_date)) as phase_finish_date
                         from (
                                  select
                                      pt.pts_phase_code,
                                      ph.ordering as phase_ordering,
                                      trunc(min(nvl(tla.actual_date,tla.plan_date)),'mm') as phase_start_date
                                  from milestone_vw tla
                                      join phase_milestone ml on ml.milestone_code=tla.milestone_code and ml.category='CF'
                                      join phase_mapping_vw pt on pt.phase_code=ml.phase_code
                                      join phase ph on ph.code=pt.pts_phase_code
                                  where tla.timeline_id=v_timeline.id
                                  group by pt.pts_phase_code,ph.ordering
                              ) ph cross join (select 1 from dual)
                     ) ph
                    join (
                             /* probabilities calcualted starting from the current phase, multiplied for following phases,
                              * starting from v_ordering phase */
                             select
                                 phase_code,
                                 round(round(exp(sum(ln(phase_probability/100)) over(order by phase_ordering)),10),10) as probability
                             from (
                                 select
                                     prob.phase_code,
                                     ph.ordering as phase_ordering,
                                     lag(prob.probability,1,100) over(partition by project_id order by ph.ordering) as phase_probability
                                 from costs_probability prob
                                     join phase ph on prob.phase_code=ph.code
                                 where prob.scope_code='INT' and prob.probability>0 and ph.ordering>=v_ordering
                                       and prob.project_id=v_timeline.project_id
                             )
                         ) prob on prob.phase_code=ph.pts_phase_code and prob.probability is not null
                    join (
                             /* costs, layed out in years and months, grouped by function */
                             select
                                 function_code,
                                 year,
                                 month,
                                 to_date(year||'-'||month,'yyyy-mm') as month_start_date,
                                 sum(int_det_fct) as forecast
                             from costs_tmp
                             where project_id=v_timeline.project_id
                                   and month is not null
                             group by year,month,function_code
                         ) cst on
                                   cst.forecast is not null
                                   /* starting from current month */
                                   and cst.month_start_date>=trunc(sysdate,'mm')
                                   /* month has to be within phase boundaries */
                                   and cst.month_start_date between ph.phase_start_date and nvl(ph.phase_finish_date,cst.month_start_date);

            /* generate external costs */
            insert into costs (
                project_id,
                study_id,
                function_code,
                scope_code,
                method_code,
                type_code,
                cost,
                start_date,
                finish_date)
                select
                    v_timeline.project_id,
                    cst.study_id,
                    cst.function_code,
                    'EXT',
                    'PROB',
                    'CALF',
                    round(cst.forecast * case when cst.month < cst.forecast_month and cst.year = cst.forecast_year  then 1 else prob.probability end, 10) as cost,
                    to_date(cst.year||'-'||cst.month,'yyyy-mm'),
                    last_day(to_date(cst.year||'-'||cst.month,'yyyy-mm'))
                from (
                         /* costs, layed out in years and months, grouped by study and function */
                         select
                             study_id,
                             function_code,
                             year,
                             month,
                             max(forecast_month) forecast_month,
                             max(forecast_year) forecast_year,
                             to_date(year||'-'||month,'yyyy-mm') as month_start_date,
                             sum(ext_det_fct) as forecast
                         from costs_tmp
                         where project_id=v_timeline.project_id and month is not null and study_id is not null
                         group by year,month,study_id,function_code
                     ) cst
                    join (
                             /* study,function level probability of nearest milestone, taking into account probability rules */
                             select
                                 prob.function_code,
                                 ts.study_id,
                                 prob.probability / 100 as probability,
                                 row_number() over(partition by ts.study_id,prob.function_code,prob.study_element_id order by prob.lag desc ) as rn_rule_priority,
                                 row_number() over(partition by ts.study_id,prob.function_code,lag order by (nvl(tm.actual_date, tm.plan_date) - sysdate)) as rn_milestone_priority
                             from milestone_vw tm
                                 join study_vw ts on ts.wbs_id=tm.wbs_id
                                 join costs_probability prob on prob.scope_code='EXT' and prob.study_element_id=tm.milestone_id
                             where
                                 tm.timeline_id=v_timeline.id
                                 and (
                                     prob.rule_code='AFTER' and trunc(sysdate,'mm') >= trunc(nvl(tm.actual_date,tm.plan_date),'mm')
                                     or prob.rule_code='BEFORE' and trunc(nvl(tm.actual_date,tm.plan_date),'mm') >= add_months(trunc(sysdate,'mm'),prob.lag)
                                 )
                         ) prob on prob.rn_rule_priority=1 and prob.rn_milestone_priority=1 and prob.function_code=cst.function_code and prob.study_id=cst.study_id
                where
                    /* for each forecast of function within a study */
                    cst.study_id is not null
                    and cst.forecast is not null
                    /* starting from current month */
                    and cst.month_start_date>=trunc(sysdate,'yyyy');

            notice_pkg.information(project_pkg.get_subject(p_id), project_pkg.get_summary(p_id)||' forecast calculation complete.');
            log_pkg.log(project_pkg.get_subject(p_id), project_pkg.get_summary(p_id), 'Forecast calculated.');
        end;

    function get_latest_fc_number return nvarchar2 as
        cursor c_fc is
            select forecast_number
            from costs cst
            where cst.type_code='FCT' and is_last_forecast=1 and rownum=1;
        v_fc_number nvarchar2(10);
        begin
            open c_fc;
            fetch c_fc into v_fc_number;
            close c_fc;

            return v_fc_number;
        end;
end;
/