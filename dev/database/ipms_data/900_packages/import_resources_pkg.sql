create or replace package import_resources_pkg as

	/**
	 * Resources are splitted by the costs source.
	 * functions without any suffix = original ones from FRLive
	 * _ged and _cs are created during CUC project for two new sources: GED and CS
	 */
	function load_resources(p_id in nvarchar2) return number;
	function merge_resources(p_id in nvarchar2) return number;
	function submit_resources(p_id in nvarchar2) return number;

	function load_resources_cs(p_id in nvarchar2) return number;
	function merge_resources_cs(p_id in nvarchar2) return number;
	function submit_resources_cs(p_id in nvarchar2) return number;

	function load_resources_ged(p_id in nvarchar2) return number;
	function merge_resources_ged(p_id in nvarchar2) return number;
	function submit_resources_ged(p_id in nvarchar2) return number;

	procedure merge_sophia_all_resources;
end;
/
create or replace package body import_resources_pkg as

	/*************************************************************************/
	function load_resources(p_id in nvarchar2) return number as
	begin

		/* drop old log */
		delete from import_resources
		where project_id = import_pkg.v_import.project_id
		and year between
			extract(year from import_pkg.v_import.create_date) - 1
			and extract(year from import_pkg.v_import.create_date) + 100;

		/* load data */
		insert into import_resources
			(
			import_id,
			project_id,
			reference_id,
			study_id,
			subfunction_code,
			type_code,
			method_code,
			project_activity_id,
			year,
			month,
			demand
			)
		select
			import_pkg.v_import.id,
			import_pkg.v_import.project_id,
			res.id,
			res.study_id,
			res.subfunction_id,
			res.type_code,
			cmtd.code,
			res.project_activity_id,
			res.year,
			res.month,
			res.demand
		from sophia_all_resources_merge res
		join calculation_method cmtd on (cmtd.code=res.prob_det_code)
		where res.project_id=import_pkg.v_project.code
		and res.view_type=1
		and res.demand is not null
		and res.demand < 999999999999 --sometime by mistake SOphia sends totally incorrect data that blocks the whole import
		and res.year between extract(year from import_pkg.v_import.create_date) - 1
		and extract(year from import_pkg.v_import.create_date) + 100
		;

		/* release tmp space */
		--delete from sophia_all_resources_tmp where project_id=import_pkg.v_project.code and view_type=1;

		return sql%rowcount;
	end;

	/*************************************************************************/
	function merge_resources(p_id in nvarchar2) return number as
	begin
		update import_resources res
		set
			status_code='FAIL',
			status_description='Invalid subfunction: '||res.subfunction_code
		where
			import_id=p_id and status_code='NEW'
			and not exists(select * from subfunction sf where sf.code=res.subfunction_code);

		update import_resources res
		set
			status_code='FAIL',
			status_description='Invalid study: '||res.study_id
		where
			import_id=p_id and status_code='NEW'
			and res.study_id is not null
			and not exists(
				select *
				from study_vw ts
				where ts.hlevel=1
				and ts.project_id=res.project_id
				and ts.timeline_type_code='CUR'
				and res.study_id=ts.study_id
			);

		update import_resources res
		set status_code='READY'
		where import_id=p_id and status_code='NEW';

		return sql%rowcount;
	end;

	/*************************************************************************/
	function submit_resources(p_id in nvarchar2) return number as
	begin
		/* drop old entries */
		delete from resources
		where project_id=import_pkg.v_import.project_id
		and extract(year from start_date) between
			extract(year from import_pkg.v_import.create_date) - 1
			and extract(year from import_pkg.v_import.create_date) + 100;

		/* move data into ipms */
		insert into resources(
			project_id,
			study_id,
			subfunction_code,
			method_code,
			type_code,
			project_activity_id,
			demand,
			start_date,
			finish_date)
		select
			project_id,
			study_id,
			imp.subfunction_code,
			method_code,
			type_code,
			project_activity_id,
			demand,
			to_date(year||'-'||month, 'yyyy-mm') as start_date,
			last_day(to_date(year||'-'||month, 'yyyy-mm')) as finish_date
		from import_resources imp
		join subfunction sub on sub.code=imp.subfunction_code
		where status_code='READY'
		and import_id=p_id;

		update import_resources res set status_code='DONE' where import_id=p_id and status_code='READY';

		return sql%rowcount;
	end;


	/*************************************************************************/
	/******************** CS *************************************************/
	/*************************************************************************/
	function load_resources_cs(p_id in nvarchar2) return number as
	begin

		/* drop old log */
		delete from import_resources_cs
		where project_id = import_pkg.v_import.project_id
		and year between
			extract(year from import_pkg.v_import.create_date) - 1
			and extract(year from import_pkg.v_import.create_date) + 100;

		/* load data */
		insert into import_resources_cs
			(
			import_id,
			project_id,
			reference_id,
			study_id,
			subfunction_code,
			type_code,
			method_code,
			project_activity_id,
			year,
			month,
			demand
			)
		select
			import_pkg.v_import.id,
			import_pkg.v_import.project_id,
			res.id,
			res.study_id,
			res.subfunction_id,
			res.type_code,
			cmtd.code,
			res.project_activity_id,
			res.year,
			res.month,
			res.demand
		from sophia_all_resources_merge res
		join calculation_method cmtd on cmtd.code=res.prob_det_code
		where res.project_id=import_pkg.v_project.code
		and res.view_type=2
		and res.demand is not null
		and res.demand < 999999999999 --sometime by mistake SOphia sends totally incorrect data that blocks the whole import
		and res.year between extract(year from import_pkg.v_import.create_date) - 1
		and extract(year from import_pkg.v_import.create_date) + 100
		;

		/* release tmp space */
		--delete from sophia_all_resources_tmp where project_id=import_pkg.v_project.code and view_type=2;

		return sql%rowcount;
	end;

	/*************************************************************************/
	function merge_resources_cs(p_id in nvarchar2) return number as
	begin
		update import_resources_cs res
		set
			status_code='FAIL',
			status_description='Invalid subfunction: '||res.subfunction_code
		where
			import_id=p_id and status_code='NEW'
			and not exists(select * from subfunction sf where sf.code=res.subfunction_code);

		update import_resources_cs res
		set status_code='READY'
		where import_id=p_id and status_code='NEW';

		return sql%rowcount;
	end;


	/*************************************************************************/
	function submit_resources_cs(p_id in nvarchar2) return number as
	begin
		/* drop old entries */
		delete from resources_cs
		where
			project_id=import_pkg.v_import.project_id
			and extract(year from start_date) between
				extract(year from import_pkg.v_import.create_date) - 1
				and extract(year from import_pkg.v_import.create_date) + 100;

		/* move data into ipms */
		insert into resources_cs(
			project_id, study_id, subfunction_code,
			method_code, type_code, project_activity_id,
			demand,
			start_date, finish_date)
		select
			project_id, study_id, imp.subfunction_code,
			method_code, type_code, project_activity_id,
			demand,
			to_date(year||'-'||month, 'yyyy-mm') as start_date,
			last_day(to_date(year||'-'||month, 'yyyy-mm')) as finish_date
		from import_resources_cs imp
		join subfunction sub on sub.code=imp.subfunction_code
		where status_code='READY' and import_id=p_id;

		update import_resources_cs res set status_code='DONE' where import_id=p_id and status_code='READY';

		return sql%rowcount;
	end;


	/*************************************************************************/
	/****************** GED **************************************************/
	/*************************************************************************/
	function load_resources_ged(p_id in nvarchar2) return number as
	begin

		/* drop old log */
		delete from import_resources_ged
		where project_id = import_pkg.v_import.project_id
		and year between
			extract(year from import_pkg.v_import.create_date) - 1
			and extract(year from import_pkg.v_import.create_date) + 100;

		/* load data */
		insert into import_resources_ged
			(
			import_id,
			project_id,
			reference_id,
			study_id,
			subfunction_code,
			type_code,
			method_code,
			project_activity_id,
			decision_start,
			commit_state,
			year,
			month,
			demand
			)
		select
			import_pkg.v_import.id,
			import_pkg.v_import.project_id,
			res.id,
			res.study_id,
			res.subfunction_id,
			res.type_code,
			cmtd.code,
			res.project_activity_id,
			res.decision_start,
			res.commit_state,
			res.year,
			res.month,
			res.demand
		from sophia_all_resources_merge res
		join calculation_method cmtd on cmtd.code=res.prob_det_code
		where res.project_id=import_pkg.v_project.code
		and res.view_type=3
		and res.demand is not null
		and res.demand < 999999999999 --sometime by mistake SOphia sends totally incorrect data that blocks the whole import
		and res.year between extract(year from import_pkg.v_import.create_date) - 1
		and extract(year from import_pkg.v_import.create_date) + 100
		;

		return sql%rowcount;
	end;

	/*************************************************************************/
	function merge_resources_ged(p_id in nvarchar2) return number as
	begin
		update import_resources_ged res
		set
			status_code='FAIL',
			status_description='Invalid subfunction: '||res.subfunction_code
		where
			import_id=p_id and status_code='NEW'
			and not exists(select * from subfunction sf where sf.code=res.subfunction_code);

		update import_resources_ged res
		set status_code='READY'
		where import_id=p_id and status_code='NEW';

		return sql%rowcount;
	end;


	/*************************************************************************/
	function submit_resources_ged(p_id in nvarchar2) return number as
	begin
		/* drop old entries */
		delete from resources_ged
		where
			project_id=import_pkg.v_import.project_id
			and extract(year from start_date) between
				extract(year from import_pkg.v_import.create_date) - 1
				and extract(year from import_pkg.v_import.create_date) + 100;

		/* move data into ipms */
		insert into resources_ged(
			project_id, study_id, subfunction_code,
			method_code, type_code, project_activity_id, decision_start, commit_state,
			demand,
			start_date, finish_date)
		select
			project_id, study_id, imp.subfunction_code,
			method_code, type_code, project_activity_id, decision_start, commit_state,
			demand,
			to_date(year||'-'||month, 'yyyy-mm') as start_date,
			last_day(to_date(year||'-'||month, 'yyyy-mm')) as finish_date
		from import_resources_ged imp
		join subfunction sub on sub.code=imp.subfunction_code
		where status_code='READY' and import_id=p_id;

		update import_resources_ged res set status_code='DONE' where import_id=p_id and status_code='READY';

		return sql%rowcount;
	end;

	/*************************************************************************/
	procedure merge_sophia_all_resources as
		v_rowcount number:=0;
		v_count_view number;
		v_count_tab number;
		----
		v_where nvarchar2(222):='import_resources_pkg.sophia_all_resources_merge';
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
		----
	begin
		log_pkg.steps(null,v_step_start,v_steps_result);

		merge into sophia_all_resources_merge dest
		using (select id
				, max (decode (seq, 1, project_id)) project_id
				, max (decode (seq, 1, study_id)) study_id
				, max (decode (seq, 1, function_id)) function_id
				, max (decode (seq, 1, subfunction_id)) subfunction_id
				, max (decode (seq, 1, prob_det_code)) prob_det_code
				, max (decode (seq, 1, year)) year
				, max (decode (seq, 1, month)) month
				, max (decode (seq, 1, type_code)) type_code
				, max (decode (seq, 1, project_activity_id)) project_activity_id
				, max (decode (seq, 1, decision_start)) decision_start
				, max (decode (seq, 1, commit_state)) commit_state
				, max (decode (seq, 1, demand)) demand
				, max (decode (seq, 1, view_type)) view_type
				, sum (decode (seq, 1, srccnt, dstcnt)) iud
			 from (select
								id,
								project_id,
								study_id,
								function_id,
								subfunction_id,
								prob_det_code,
								year,
								month,
								type_code,
								project_activity_id,
							 	decision_start,
							 	commit_state,
							 	demand,
								view_type,
								srccnt,
								dstcnt,
								row_number () over (partition by id order by dstcnt nulls last) seq
						from (select
									id,
									project_id,
									study_id,
									function_id,
									subfunction_id,
									prob_det_code,
									year,
									month,
									type_code,
									project_activity_id,
									decision_start,
									commit_state,
									demand,
									view_type,
									count (src) srccnt,
									count (dst) dstcnt
								  from (
											select
													id,
													project_id,
													study_id,
													function_id,
													subfunction_id,
													prob_det_code,
													year,
													month,
													type_code,
													project_activity_id,
												  decision_start,
													commit_state,
													demand,
													view_type,
													1 src,
													to_number(null) dst
											from sophia_all_resources_vw
												union all
											select
													id,
													project_id,
													study_id,
													function_id,
													subfunction_id,
													prob_det_code,
													year,
													month,
													type_code,
													project_activity_id,
													decision_start,
													commit_state,
													demand,
													view_type,
													to_number(null) src,
													2 dst
											 from sophia_all_resources_merge
											 )
								group by
									id,
									project_id,
									study_id,
									function_id,
									subfunction_id,
									prob_det_code,
									year,
									month,
									type_code,
									project_activity_id,
									decision_start,
									commit_state,
									demand,
									view_type
								having count (src) <> count (dst))
								)
		  group by id) diff
	 on (dest.id = diff.id)
		when matched
		then
			 update set
				  dest.project_id = diff.project_id
				  ,dest.study_id = diff.study_id
				  ,dest.function_id = diff.function_id
				  ,dest.subfunction_id = diff.subfunction_id
				  ,dest.prob_det_code = diff.prob_det_code
				  ,dest.year = diff.year
				  ,dest.month = diff.month
				  ,dest.type_code = diff.type_code
				  ,dest.project_activity_id = diff.project_activity_id
					,dest.decision_start=diff.decision_start
					,dest.commit_state=diff.commit_state
					,dest.demand = diff.demand
				  ,dest.view_type = diff.view_type
				  ,dest.update_date = sysdate

			 delete
					where (diff.iud = 0)
		when not matched
		then
			 insert (
						id,
						project_id,
						study_id,
						function_id,
						subfunction_id,
						prob_det_code,
						year,
						month,
						type_code,
						project_activity_id,
						decision_start,
						commit_state,
						demand,
						view_type,
						create_date,
						update_date
						)
			 values (
						diff.id,
						diff.project_id,
						diff.study_id,
						diff.function_id,
						diff.subfunction_id,
						diff.prob_det_code,
						diff.year,
						diff.month,
						diff.type_code,
						diff.project_activity_id,
				 		diff.decision_start,
				 		diff.commit_state,
						diff.demand,
						diff.view_type,
						sysdate,
						sysdate
						);
		v_rowcount := v_rowcount + sql%rowcount;

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, 'rowcount='||v_rowcount,v_steps_result);

	--exception when others then
		--log_pkg.catch(v_where,'rowcount='||v_rowcount||';'||v_log_txt,v_steps_result);
		--raise;
	end;

end;
/