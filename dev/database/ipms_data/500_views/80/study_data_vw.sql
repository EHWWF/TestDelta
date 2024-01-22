create or replace view study_data_vw as
select
	xt.project_id,
	xt.sandbox_id,
	xt.timeline_id,
	xt.timeline_type_code,
	xt.wbs_id,
	xt.study_id,
	xt.study_id as id,
	xt.code,
	xt.name,
	st.study_name,
	xt.start_date,
	xt.finish_date,
	xt.study_phase as phase,
	st.phase_code as phase_code,
	xt.placeholder,
	case
		when trunc(nvl(fp.milestone_date, xt.start_date)) <= trunc(last_day(sysdate))
		then 'RUN'
		when trunc(nvl(fp.milestone_date, xt.start_date)) <= trunc(last_day(add_months(sysdate,cs.value)))
		then 'COMM'
		when trunc(nvl(fp.milestone_date, xt.start_date)) > trunc(last_day(add_months(sysdate,cs.value))) or xt.placeholder=0 and fp.milestone_date is null
		then 'PLAN'
		else 'OTHER'
	end as status_code,
	count(distinct xt.wbs_id) over(partition by xt.timeline_id,xt.study_id) as wbs_count,
	fp.milestone_date as fpfv,
	fpfvb.milestone_date as fpfvb,
	lplva.milestone_date as lplva,
	lp.milestone_date as lplv,
	dmc_actual.milestone_date as dmc_actual,
	dmc_plan.milestone_date as dmc_plan,
	csrapp.milestone_date as csrapp,
	prcompl.milestone_date as prcompl,
	cdblock.milestone_date as cdblock,
	nvl(st.is_obligation,0) as is_obligation,
	nvl(st.is_probing,0) as is_probing,
	nvl(st.is_gpdc_approved,0) as is_gpdc_approved,
	st.plan_patients,
	st.actual_patients,
	st.int_ext_flag,
	st.study_modus_no,
	st.study_modus_name,
	st.clin_plan_type,
	st.study_unit_count,
	st.study_unit_count_plan,
	st.therapeutic_group_code,
	st.therapeutic_group_desc,
	st.is_timeline_auto_import,
	st.is_study_auto_import,
	st.volunteer_flag,
	st.study_country_count,
	st.study_country_count_plan,
	st.subject_type,
	st.plan_entered_screen,
	st.act_entered_screen,
	st.is_lead,
	st.fte_avg,
    st.is_delete,
	st.budget_class,
	st.branch_flag,
	st.update_date
from
	timeline_wbs xt
	join configuration cs on cs.code='STD-MM'
	left join (
		select sb.id as sandbox_id, sb.snd_timeline_id as timeline_id, sb.timeline_id as src_timeline_id, sb_src_tl.project_id as src_project_id 
		from program_sandbox sb
		inner join timeline sb_src_tl on sb_src_tl.id=sb.timeline_id
	--) sb on xt.project_id is null and sb.timeline_id=xt.timeline_id --at DEV1 it does not work, returns error: ORA-00932 Inconsistent Data Type CHAR expected
	) sb on (nvl(xt.project_id,'#')='#' and sb.timeline_id=xt.timeline_id)
	left join study st on st.project_id=nvl(xt.project_id, sb.src_project_id) and st.id=xt.study_id
	left join (
		select
			ms.timeline_id,
			ms.wbs_id,
			ms.milestone_date,
			row_number() over(partition by ms.timeline_id,ms.wbs_id order by ms.milestone_date desc) as rn
		from study_milestone_vw ms
		join configuration cf on cf.code='FPFV' and lower(cf.value)=lower(ms.milestone_id)
	) fp on fp.timeline_id=xt.timeline_id and fp.wbs_id=xt.wbs_id and fp.rn=1
	left join (
		select
			ms.timeline_id,
			ms.wbs_id,
			ms.milestone_date,
			row_number() over(partition by ms.timeline_id,ms.wbs_id order by ms.milestone_date desc) as rn
		from study_milestone_vw ms
		join configuration cf on cf.code='LPLV' and lower(cf.value)=lower(ms.milestone_id)
	) lp on lp.timeline_id=xt.timeline_id and lp.wbs_id=xt.wbs_id and lp.rn=1
	left join (
		select
			ms.timeline_id,
			ms.wbs_id,
			ms.actual_date as milestone_date,
			row_number() over(partition by ms.timeline_id,ms.wbs_id order by ms.actual_date desc) as rn
		from study_milestone_vw ms
		join configuration cf on cf.code='DMC' and lower(cf.value)=lower(ms.milestone_id)
		where ms.actual_date is NOT null
	) dmc_actual on dmc_actual.timeline_id=xt.timeline_id and dmc_actual.wbs_id=xt.wbs_id and dmc_actual.rn=1
	left join (
		select
			ms.timeline_id,
			ms.wbs_id,
			ms.plan_date as milestone_date,
			row_number() over(partition by ms.timeline_id,ms.wbs_id order by ms.plan_date desc) as rn
		from study_milestone_vw ms
		join configuration cf on cf.code='DMC' and lower(cf.value)=lower(ms.milestone_id)
		where ms.actual_date is null
	) dmc_plan on dmc_plan.timeline_id=xt.timeline_id and dmc_plan.wbs_id=xt.wbs_id and dmc_plan.rn=1
	left join (--PROMISiii-101
		select
			ms.timeline_id,
			ms.wbs_id,
			ms.milestone_date,
			row_number() over(partition by ms.timeline_id,ms.wbs_id order by ms.milestone_date desc) as rn
		from study_milestone_vw ms
		join configuration cf on cf.code='CSRAPP' and lower(cf.value)=lower(ms.milestone_id)
	) csrapp on csrapp.timeline_id=xt.timeline_id and csrapp.wbs_id=xt.wbs_id and csrapp.rn=1
	left join (--PROMISiii-101
		select
			ms.timeline_id,
			ms.wbs_id,
			ms.milestone_date,
			row_number() over(partition by ms.timeline_id,ms.wbs_id order by ms.milestone_date desc) as rn
		from study_milestone_vw ms
		join configuration cf on cf.code='PRCOMPL' and lower(cf.value)=lower(ms.milestone_id)
	) prcompl on prcompl.timeline_id=xt.timeline_id and prcompl.wbs_id=xt.wbs_id and prcompl.rn=1
	left join (--PROMISiii-101
		select
			ms.timeline_id,
			ms.wbs_id,
			ms.milestone_date,
			row_number() over(partition by ms.timeline_id,ms.wbs_id order by ms.milestone_date desc) as rn
		from study_milestone_vw ms
		join configuration cf on cf.code='CDBLOCK' and lower(cf.value)=lower(ms.milestone_id)
	) cdblock on cdblock.timeline_id=xt.timeline_id and cdblock.wbs_id=xt.wbs_id and cdblock.rn=1
	left join (
		select
			ms.timeline_id,
			ms.wbs_id,
			ms.milestone_date,
			row_number() over(partition by ms.timeline_id,ms.wbs_id order by ms.milestone_date desc) as rn
		from study_milestone_vw ms
		join configuration cf on cf.code='FPFVB' and lower(cf.value)=lower(ms.milestone_id)
	) fpfvb  on fpfvb.timeline_id=xt.timeline_id and fpfvb.wbs_id=xt.wbs_id and fpfvb.rn=1
	left join (
		select
			ms.timeline_id,
			ms.wbs_id,
			ms.milestone_date,
			row_number() over(partition by ms.timeline_id,ms.wbs_id order by ms.milestone_date desc) as rn
		from study_milestone_vw ms
		join configuration cf on cf.code='LPLVA' and lower(cf.value)=lower(ms.milestone_id)
	) lplva  on lplva.timeline_id=xt.timeline_id and lplva.wbs_id=xt.wbs_id and lplva.rn=1
where xt.study_id is not null;

drop table study_tmp;

create global temporary table study_tmp
on commit delete rows
as (select * from study_data_vw where 1=0);

create index study_tmp_idx1 on study_tmp(project_id);

create or replace trigger study_data_vw_tr
instead of update or insert on study_data_vw
for each row
begin
	merge into study st
	using (
		select
			:new.id as id,
			:new.project_id as project_id,
			:new.plan_patients as plan_patients,
			:new.actual_patients as actual_patients,
			:new.int_ext_flag as int_ext_flag,
			:new.study_modus_no as study_modus_no,
			:new.study_modus_name as study_modus_name,
			:new.clin_plan_type as clin_plan_type,
			:new.study_unit_count as study_unit_count,
			:new.study_unit_count_plan as study_unit_count_plan,
			:new.therapeutic_group_code as therapeutic_group_code,
			:new.therapeutic_group_desc as therapeutic_group_desc,
			:new.is_timeline_auto_import as is_timeline_auto_import,
			:new.is_study_auto_import as is_study_auto_import,
			:new.volunteer_flag as volunteer_flag,
			:new.study_country_count as study_country_count,
			:new.study_country_count_plan as study_country_count_plan,
			:new.subject_type as subject_type,
			:new.plan_entered_screen as plan_entered_screen,
			:new.act_entered_screen as act_entered_screen,
			:new.fte_avg as fte_avg,
			:new.placeholder as placeholder,
      :new.is_delete as is_delete,
			:new.budget_class as budget_class,
			:new.branch_flag as branch_flag,
      :new.phase_code as phase_code,
			:new.study_name as study_name
		from dual
	) vw
	on (st.id=vw.id and st.project_id=vw.project_id)
	when matched then
		update set
			st.is_obligation=nvl(:new.is_obligation,st.is_obligation),
			st.is_probing=nvl(:new.is_probing,st.is_probing),
			st.is_gpdc_approved=nvl(:new.is_gpdc_approved,st.is_gpdc_approved),
			st.plan_patients=vw.plan_patients,
			st.actual_patients=vw.actual_patients,
			st.int_ext_flag=vw.int_ext_flag,
			st.study_modus_no=vw.study_modus_no,
			st.study_modus_name=vw.study_modus_name,
			st.clin_plan_type=vw.clin_plan_type,
			st.study_unit_count=vw.study_unit_count,
			st.study_unit_count_plan=vw.study_unit_count_plan,
			st.therapeutic_group_code=vw.therapeutic_group_code,
			st.therapeutic_group_desc=vw.therapeutic_group_desc,
			st.is_timeline_auto_import=nvl(vw.is_timeline_auto_import,st.is_timeline_auto_import),
			st.is_study_auto_import=nvl(vw.is_study_auto_import,st.is_study_auto_import),
			st.volunteer_flag=vw.volunteer_flag,
			st.study_country_count=vw.study_country_count,
			st.study_country_count_plan=vw.study_country_count_plan,
			st.subject_type=vw.subject_type,
			st.plan_entered_screen=vw.plan_entered_screen,
			st.act_entered_screen=vw.act_entered_screen,
			st.fte_avg=vw.fte_avg,
      st.is_delete=vw.is_delete,
			st.budget_class=vw.budget_class,
			st.branch_flag=vw.branch_flag,
			st.phase_code=vw.phase_code,
      st.study_name=vw.study_name
	when not matched then
		insert(
			id,
			project_id,
			is_obligation,
			is_probing,
			is_gpdc_approved,
			plan_patients,
			actual_patients,
			int_ext_flag,
			study_modus_no,
			study_modus_name,
			clin_plan_type,
			study_unit_count,
			study_unit_count_plan,
			therapeutic_group_code,
			therapeutic_group_desc,
			volunteer_flag,
			study_country_count,
			study_country_count_plan,
			subject_type,
			plan_entered_screen,
			act_entered_screen,
			is_timeline_auto_import,
			is_study_auto_import,
      is_delete,
			budget_class,
			branch_flag,
      phase_code,
			study_name
			)
		values(
			vw.id,
			vw.project_id,
			nvl(:new.is_obligation,0),
			nvl(:new.is_probing,0),
			nvl(:new.is_gpdc_approved,0),
			vw.plan_patients,
			vw.actual_patients,
			vw.int_ext_flag,
			vw.study_modus_no,
			vw.study_modus_name,
			vw.clin_plan_type,
			vw.study_unit_count,
			vw.study_unit_count_plan,
			vw.therapeutic_group_code,
			vw.therapeutic_group_desc,
			vw.volunteer_flag,
			vw.study_country_count,
			vw.study_country_count_plan,
			vw.subject_type,
			vw.plan_entered_screen,
			vw.act_entered_screen,
			nvl(vw.is_timeline_auto_import,decode(vw.placeholder,1,0,1)),
			nvl(vw.is_study_auto_import,1),
      vw.is_delete,
			vw.budget_class,
			vw.branch_flag,
      vw.phase_code,
			vw.study_name
			);
end;
/