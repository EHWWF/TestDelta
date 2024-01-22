create or replace package goal_pkg as

	--after INSERT or UPDATE on the TABLE.GOAL -> trigger goal_atr calls this procedure
	--and also after CUR timeline synchronization
		procedure update_ref_date_after_st(p_id number,
													p_project_id nvarchar2,
													p_plan_reference nvarchar2,
													p_study_id nvarchar2,
													p_target_date date,
													v_plan_reference_date in out date,
													v_status in out nvarchar2,
													v_ref_date_type in out nvarchar2);

	--After changing configuration_pkg.get_config_value('GOAL_TRACK') from 0--->1 this procedure must be run.												
		procedure update_ref_date_after_config;

end;
/
create or replace package body goal_pkg as

	/*************************************************************************/
		procedure update_ref_date_after_st(p_id number,
													p_project_id nvarchar2,
													p_plan_reference nvarchar2,
													p_study_id nvarchar2,
													p_target_date date,
													v_plan_reference_date in out date,
													v_status in out nvarchar2,
													v_ref_date_type in out nvarchar2)
	as
		v_wbs_id nvarchar2(100);
		v_plan_finish date;
		v_plan_finish_trun date;
		v_actual_finish date;
		v_actual_finish_trunk date;
		v_target_date_trunk date;
		v_where nvarchar2(99):='goal_pkg.update_ref_date_after_st';

	begin

		if p_plan_reference is not null then--Study_Element_id must be Always provided
			if p_study_id is not null then
				select wbs_id into v_wbs_id
				from timeline_wbs
				where project_id=p_project_id
				and study_id=p_study_id
				and timeline_type_code='CUR';
				
				select plan_finish, actual_finish
				into v_plan_finish, v_actual_finish
				from timeline_activity
				where project_id=p_project_id
				and timeline_type_code='CUR'
				and parent_wbs_id=v_wbs_id
				and study_element_id=p_plan_reference;
			else
				select plan_finish, actual_finish
				into v_plan_finish, v_actual_finish
				from timeline_activity
				where project_id=p_project_id
				and timeline_type_code='CUR'
				and parent_wbs_id is null
				and study_element_id=p_plan_reference;
			end if;

			--calculate STATUS
			--1	On Track
			--referenced plan activity planned finish date is ON OR BEFORE the goal’s Target  Date (only Month)
			--2	At Risk
			--referenced plan activity planned finish date is delayed, meaning AFTER the goal’s Target Date (only Month)
			--3	Achieved
			--referenced plan activity actual finish date is ON OR BEFORE the goal’s Target Date (only Month)
			--4	Not Achieved
			--referenced plan activity actual finish date is AFTER the goal’s Target Date (only Month)
			--5 Withdrawn -- only could be set from UI

			v_actual_finish_trunk:=trunc(v_actual_finish, 'MONTH');
			v_plan_finish_trun:=trunc(v_plan_finish, 'MONTH');
			v_target_date_trunk:=trunc(p_target_date, 'MONTH');

			if v_actual_finish_trunk is not null and v_actual_finish_trunk <= v_target_date_trunk then
				if v_status is null then v_status := '3'; end if;
				v_plan_reference_date:=v_actual_finish;
				v_ref_date_type:='A';
			elsif v_actual_finish_trunk is not null and v_actual_finish_trunk > v_target_date_trunk then
				if v_status is null then v_status := '4'; end if;
				v_plan_reference_date:=v_actual_finish;
				v_ref_date_type:='A';
			elsif v_plan_finish_trun is not null and v_plan_finish_trun <= v_target_date_trunk then
				if v_status is null then v_status := '1'; end if;
				v_plan_reference_date:=v_plan_finish;
				v_ref_date_type:='P';
			elsif v_plan_finish_trun is not null and v_plan_finish_trun > v_target_date_trunk then
				if v_status is null then v_status := '2'; end if;
				v_plan_reference_date:=v_plan_finish;
				v_ref_date_type:='P';
			else
				v_plan_reference_date:=null;
				v_ref_date_type:=null;
				if v_status is null then v_status:='1'; end if;--default
			end if;

		else
			v_plan_reference_date:=null;
			v_ref_date_type:=null;
			if v_status is null then v_status:='1'; end if;--default
		end if;

	exception when others then
		v_plan_reference_date:=null;
		v_ref_date_type:=null;
		if v_status is null then v_status:='1'; end if;--default
		/*
		log_pkg.log(v_where,'OTHERS.p_id='||p_id||';p_project_id='||p_project_id||
								';p_plan_reference='||p_plan_reference||';p_study_id='||p_study_id||
								';p_target_date='||p_target_date||';v_wbs_id='||v_wbs_id,sqlerrm);
		*/
		notice_pkg.error(v_where,
								'p_id='||p_id||';p_project_id='||p_project_id||
								';p_plan_reference='||p_plan_reference||';p_study_id='||p_study_id||
								';p_target_date='||p_target_date||';v_wbs_id='||v_wbs_id||';sqlerrm='||sqlerrm);
	end;

	/*************************************************************************/
	procedure update_ref_date_after_config
	as
		v_plan_reference_date date;
		v_goal_status nvarchar2(22);
		v_ref_date_type nvarchar2(11);
		v_where nvarchar2(99):='goal_pkg.update_ref_date_after_config';
		v_type nvarchar2(99);
	begin
		if configuration_pkg.get_config_value('GOAL_TRACK')='1' then--the rule should work only when changing from 0->1
			for rr in (select *
							from goal
							where plan_reference is not null --study_element_id
							order by id
							)
			loop
				goal_pkg.update_ref_date_after_st(rr.id,rr.project_id,rr.plan_reference,rr.study_id,
				rr.target_date,v_plan_reference_date,v_goal_status,v_ref_date_type);

					if v_plan_reference_date is null then
						--means: unset
						v_goal_status:='1';--1=default=null
					end if;

					update goal
					set
						plan_reference_date=v_plan_reference_date,
						status=nvl(v_goal_status,'1'),
						ref_date_type=v_ref_date_type
					where id=rr.id
					and (
						nvl(plan_reference_date,sysdate)<>nvl(v_plan_reference_date,sysdate)
						or
						nvl(status,'#')<>nvl(v_goal_status,'#')
						or
						nvl(ref_date_type,'#')<>nvl(v_ref_date_type,'#')
						);
					v_type:='Full.';
				
				log_pkg.log(v_where,'goal_id='||rr.id||';v_plan_reference_date='||v_plan_reference_date||';v_ref_date_type='||v_ref_date_type||';v_goal_status='||v_goal_status,'Goal updated.'||v_type);
				--just to make sure, set to NULL for the next loop run
				v_plan_reference_date:=null;
				v_ref_date_type:=null;
				v_goal_status:=null;
					v_type:=null;
			end loop;
		else
			log_pkg.log(v_where,'GOAL_TRACK=0','No Action!');
		end if;

	exception when others then
		log_pkg.log(v_where,'OTHERS',sqlerrm);
	end;

end;
/