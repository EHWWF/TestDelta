create or replace package project_activities_pkg
as
	--pragma serially_reusable;

	procedure timeline_merge(p_project_id in project.id%type)
	;
	function import_load(p_import in import%rowtype) return number
	;
	function import_merge(p_import in import%rowtype) return number
	;
	function import_submit(p_import in import%rowtype, p_timeline in out xmltype) return number
	;
	procedure import_finish(p_import in import%rowtype)
	;

end;
/
create or replace package body project_activities_pkg
as
	--pragma serially_reusable;
	/*************************************************************************/
	procedure timeline_merge(p_project_id in project.id%type) 
	as
		v_rowcount        number := 0;
		v_where           nvarchar2(99) := 'project_activities_pkg.timeline_merge';
		v_par             nvarchar2(4000) := 'p_project_id=' || p_project_id;
		v_msg_out         nvarchar2(4000);
		v_loop_msg_out    nvarchar2(4000);
		v_step_start      timestamp := systimestamp;
		v_steps_result    nvarchar2(4000);
		v_procedure_start timestamp := systimestamp;
		v_create_user     varchar2(100) := configuration_pkg.get_config_value('P6USER');

	begin

		log_pkg.steps(null, v_step_start, v_steps_result);
		--Mark all existing records as OLD
		update project_activity
		set is_upserted = 0
		where project_id = p_project_id
		;
		v_rowcount := sql%rowcount;
		log_pkg.steps('a' || v_rowcount, v_step_start, v_steps_result);

		-- Updating ProMIS project_activity based on P6 activity ID
		merge into project_activity dst
		using 
			(
			select
				case when wbs_category is null and v_create_user != create_user then 
					N':::' || activity_id
				else 
					artificial_id 
				end artificial_id,
				project_id,
				study_element_id,
				name,
				study_id,
				activity_id,
				plan_start,
				plan_finish,
				actual_start,
				actual_finish,
				wbs_category,
				create_user
			from timeline_project_activity_vw
			where project_id = p_project_id
			and timeline_type_code = 'RAW'
			) src
		on (dst.p6_activity_id = src.activity_id)
		when matched then 
			update set
				dst.project_activity_name = src.name,
				dst.plan_start_date       = src.plan_start,
				dst.plan_finish_date      = src.plan_finish,
				dst.act_start_date        = src.actual_start,
				dst.act_finish_date       = src.actual_finish,
				dst.wbs_category          = src.wbs_category,
				dst.project_activity_id   = src.study_element_id,
				dst.study_id              = src.study_id,
				dst.is_upserted           = 1 --if still exist then mark as NEW=CORRECT
		;
		v_rowcount := sql%rowcount;
		log_pkg.steps('b' || v_rowcount, v_step_start, v_steps_result);

		--delete all that has not been just updated from P6
		delete from project_activity
		where project_id = p_project_id 
		and is_upserted = 0
		;
		v_rowcount := sql%rowcount;
		log_pkg.steps('c' || v_rowcount, v_step_start, v_steps_result);

		--insert all missing
		merge into project_activity dst
		using (
			select
				case when wbs_category is null and v_create_user != create_user
					then N':::' || activity_id
				else artificial_id end artificial_id,
				project_id,
				study_element_id,
				name,
				study_id,
				activity_id,
				plan_start,
				plan_finish,
				actual_start,
				actual_finish,
				wbs_category,
				create_user
			from timeline_project_activity_vw
			where project_id = p_project_id
			and timeline_type_code = 'RAW'
			) src
		on (dst.p6_activity_id = src.activity_id)
		when not matched then 
			insert
				(
				artificial_id,
				is_to_be_deleted,
				project_id,
				project_activity_id,
				project_activity_name,
				study_id,
				p6_activity_id,
				plan_start_date,
				plan_finish_date,
				act_start_date,
				act_finish_date,
				wbs_category,
				create_user,
				is_upserted
				) 
			values 
				(
				src.artificial_id,
				case 
					when src.wbs_category is null and v_create_user != src.create_user 
				then
						--means: End User manually have created Activity with an empty WBS_cat
					1	--thus, mark this record as for potential deletion because the truth must come only from Sophia-MaGIC
				else 
					0
				end,
				src.project_id,
				src.study_element_id,
				src.name,
				src.study_id,
				src.activity_id,
				src.plan_start,
				src.plan_finish,
				src.actual_start,
				src.actual_finish,
				src.wbs_category,
				src.create_user,
				1 --just have been freshly added
				)
		;
		v_rowcount := sql%rowcount;
		log_pkg.steps('d' || v_rowcount, v_step_start, v_steps_result);
		
		--mark Timeline as correct = no conflicts
		update timeline
		set is_pa_conflict = 0
		where id = p_project_id || '-RAW'
		;
		log_pkg.steps('END', v_procedure_start, v_steps_result);
		log_pkg.slog(v_where, v_par, v_steps_result);

	exception
      when DUP_VAL_ON_INDEX then
		  log_pkg.scatch(v_where, v_par, 'Project activities refresh failed. Duplicates found.');
		  update timeline
		  set is_pa_conflict = 1
		  where id = p_project_id || '-RAW';

      when others then
		  log_pkg.steps('ERROR', v_procedure_start, v_steps_result);
		  log_pkg.scatch(v_where, v_par, v_steps_result || ';count=' || v_rowcount);

    end timeline_merge;

	/*************************************************************************/
	function import_load(p_import in import%rowtype) return number
	as
		v_rowcount           number := 0;
		v_where              nvarchar2(99) := 'project_activities_pkg.import_load';
		v_par                nvarchar2(4000) := 'p_import.id=' || p_import.id;
		v_msg_out            nvarchar2(4000);
		v_loop_msg_out       nvarchar2(4000);
		v_step_start         timestamp := systimestamp;
		v_steps_result       nvarchar2(4000);
		v_procedure_start    timestamp := systimestamp;
		v_promis_create_user varchar2(100) := configuration_pkg.GET_CONFIG_VALUE('P6USER');

	begin

		log_pkg.steps(null, v_step_start, v_steps_result);

		if p_import.source = 'PROMIS' then --meansa, Manual import from UI

			insert into import_project_activity 
			(
				import_id,
				artificial_id,
				project_id,
				project_activity_id,
				project_activity_name,
				study_id,
				create_user,
				p6_activity_id,
				plan_start_date,
				plan_finish_date,
				act_start_date,
				act_finish_date,
				status_code
			)
			select
				p_import.id,
				artificial_id,
				project_id,
				project_activity_id,
				project_activity_name,
				study_id,
				create_user,
				p6_activity_id,
				plan_start_date,
				plan_finish_date,
				act_start_date,
				act_finish_date,
				'NEW'
			from project_activity
			where project_id = p_import.project_id
			and wbs_category is null
			and is_to_be_deleted != 1 --copy to manual import only full and correct records
			;
			v_rowcount := sql%rowcount;
			log_pkg.steps('a' || v_rowcount, v_step_start, v_steps_result);

		else

			insert into import_project_activity 
			(
				import_id,
				artificial_id,
				project_id,
				project_activity_id,
				project_activity_name,
				study_id,
				plan_start_date,
				plan_finish_date,
				act_start_date,
				act_finish_date,
				status_code,
				wbs_category,
				create_user
			)
			select
				p_import.id,
				artificial_id,
				pa.project_id,
				pa.project_activity_id,
				pa.project_activity_name,
				pa.study_id,
				pa.plan_start_date,
				pa.plan_finish_date,
				pa.act_start_date,
				pa.act_finish_date,
				'NEW',
				pa.wbs_category,
				v_promis_create_user
			from sophia_project_activities_vw pa
			where pa.project_id = p_import.project_id
			;
			v_rowcount := sql%rowcount;
			log_pkg.steps('b' || v_rowcount, v_step_start, v_steps_result);

		end if;

		log_pkg.steps('END', v_procedure_start, v_steps_result);
		log_pkg.slog(v_where, v_par, v_steps_result || ';count=' || v_rowcount);

		return v_rowcount;

	exception when others then
		log_pkg.steps('ERROR', v_procedure_start, v_steps_result);
		log_pkg.scatch(v_where, v_par, v_steps_result || ';count=' || v_rowcount);
		raise;
	end import_load;

	/*************************************************************************/
	function import_merge(p_import in import%rowtype) return number
	as
		v_rowcount        number := 0;
		v_where           nvarchar2(99) := 'project_activities_pkg.import_merge';
		v_par             nvarchar2(4000) := 'p_import.id=' || p_import.id;
		v_msg_out         nvarchar2(4000);
		v_loop_msg_out    nvarchar2(4000);
		v_step_start      timestamp := systimestamp;
		v_steps_result    nvarchar2(4000);
		v_procedure_start timestamp := systimestamp;
		v_is_pa_conflict  timeline.is_pa_conflict%type;

	begin

		log_pkg.steps(null, v_step_start, v_steps_result);

		select is_pa_conflict
		into v_is_pa_conflict
		from timeline
		where id = p_import.project_id || '-RAW';

		log_pkg.steps('a' || v_rowcount, v_step_start, v_steps_result);

		if v_is_pa_conflict = 1 then
			--stop data merge because conflicts exists
			raise_application_error(-20015, 'Project activities refresh failed. Duplicates found.');
		end if;

		if p_import.source = 'PROMIS' then --Manual import by End User

			delete from import_project_activity
			where import_id = p_import.id;

			v_rowcount := sql%rowcount;
			log_pkg.steps('b' || v_rowcount, v_step_start, v_steps_result);

			insert into import_project_activity 
			(
				import_id,
				artificial_id,
				project_id,
				project_activity_id,
				project_activity_name,
				study_id,
				create_user,
				p6_activity_id,
				plan_start_date,
				plan_finish_date,
				act_start_date,
				act_finish_date,
				status_code,
				wbs_category
			)
			select
				p_import.id,
				artificial_id,
				project_id,
				project_activity_id,
				project_activity_name,
				study_id,
				create_user,
				p6_activity_id,
				plan_start_date,
				plan_finish_date,
				act_start_date,
				act_finish_date,
				case
					when wbs_category is null and is_to_be_deleted = 0
					then 
						'READY'
					else 
						'VOID' --category is not provided or created by End User
				end,
				wbs_category
			from project_activity
			where project_id = p_import.project_id
			--and wbs_category is null 
			--and is_to_be_deleted !=1
			;

			v_rowcount := sql%rowcount;
			log_pkg.steps('c' || v_rowcount, v_step_start, v_steps_result);

		else

			--Check which activities already exist in P6
			merge into import_project_activity dst
			using 
				(
					select
						pact.artificial_id,
						pact.project_id,
						pact.project_activity_id,
						pact.project_activity_name,
						pact.study_id,
						pact.wbs_category,
						pact.create_user,
						pact.p6_activity_id,
						pact.plan_start_date,
						pact.plan_finish_date,
						pact.act_start_date,
						pact.act_finish_date,
						pact.is_manual,
						pact.is_to_be_deleted
					from project_activity pact
					where pact.project_id = p_import.project_id
				) src
			on 
				(
					dst.import_id = p_import.id 
					and dst.artificial_id = src.artificial_id
				)
			when matched then 
				update set
					dst.p6_activity_id = src.p6_activity_id,
					dst.wbs_category = nvl(dst.wbs_category, src.wbs_category),
					dst.is_manual = src.is_manual,
					dst.is_to_be_deleted = src.is_to_be_deleted
			when not matched then 
				insert 
				(
					import_id,
					artificial_id,
					project_id,
					project_activity_id,
					project_activity_name,
					study_id,
					wbs_category,
					create_user,
					p6_activity_id,
					plan_start_date,
					plan_finish_date,
					act_start_date,
					act_finish_date,
					status_code,
					is_manual,
					is_to_be_deleted
				)
				values
				(
					p_import.id,
					src.artificial_id,
					src.project_id,
					src.project_activity_id,
					src.project_activity_name,
					src.study_id,
					src.wbs_category,
					src.create_user,
					src.p6_activity_id,
					src.plan_start_date,
					src.plan_finish_date,
					src.act_start_date,
					src.act_finish_date,
					'OLD',
					src.is_manual,
					src.is_to_be_deleted
				)
			;
			v_rowcount := sql%rowcount;
			log_pkg.steps('d' || v_rowcount, v_step_start, v_steps_result);


			merge into import_project_activity dst
			using 
				(
					select *
					from import_project_activity
					where 
						(
							project_id,
							project_activity_id,
							nvl(study_id, -1), 
							wbs_category
						) 
					in 
						(
							select
								project_id,
								project_activity_id,
								nvl(study_id, -1),
								wbs_category
							from import_project_activity
							where import_id = p_import.id
							and project_id = p_import.project_id
							group by project_id, project_activity_id, nvl(study_id, -1), wbs_category
							having count(*) > 1
						) 
					and import_id = p_import.id 
					and project_id = p_import.project_id 
					and is_manual = 1
				) src
			on 
				(
					src.project_id = dst.project_id
					and src.project_activity_id = dst.project_activity_id
					and nvl(src.study_id, -1) = nvl(dst.study_id, -1)
					and src.wbs_category = dst.wbs_category
				)
			when matched then 
				update set
					dst.p6_activity_id = case when dst.is_manual = 0 then src.p6_activity_id end,
					dst.is_cat_reset   = case when dst.is_manual = 1 then 1 else dst.is_cat_reset end
			;
			v_rowcount := sql%rowcount;
			log_pkg.steps('e' || v_rowcount, v_step_start, v_steps_result);
			
			update import_project_activity set 
				wbs_category = null, 
				is_manual = 0
			where import_id = p_import.id 
			and project_id = p_import.project_id 
			and is_cat_reset = 1
			;
			v_rowcount := sql%rowcount;
			log_pkg.steps('f' || v_rowcount, v_step_start, v_steps_result);

			update import_project_activity
			set project_activity_name = project_activity_name || ' [To be deleted]'
			where import_id = p_import.id 
			and project_id = p_import.project_id 
			and is_to_be_deleted = 1 
			and instr(project_activity_name, ' [To be deleted]') = 0
			;
			v_rowcount := sql%rowcount;
			log_pkg.steps('g' || v_rowcount, v_step_start, v_steps_result);

			update import_project_activity
			set status_code = 'READY'
			where import_id = p_import.id 
			and status_code = 'NEW'
			;
			v_rowcount := sql%rowcount;
			log_pkg.steps('h' || v_rowcount, v_step_start, v_steps_result);

		end if;

		log_pkg.steps('END', v_procedure_start, v_steps_result);
		log_pkg.slog(v_where, v_par, v_steps_result || ';count=' || v_rowcount);

		return v_rowcount;

	exception when others then
		log_pkg.steps('ERROR', v_procedure_start, v_steps_result);
		log_pkg.scatch(v_where, v_par, v_steps_result || ';count=' || v_rowcount);
		raise;
	end import_merge;

	/*************************************************************************/
  function import_submit(p_import in import%rowtype, p_timeline in out xmltype)
    return number as
    v_rowcount           number := 0;
    v_where              nvarchar2(99) := 'project_activities_pkg.import_submit';
    v_par                nvarchar2(4000) := 'p_import.id=' || p_import.id;
    v_msg_out            nvarchar2(4000);
    v_loop_msg_out       nvarchar2(4000);
    v_step_start         timestamp := systimestamp;
    v_steps_result       nvarchar2(4000);
    v_procedure_start    timestamp := systimestamp;
    v_promis_create_user varchar2(100) := configuration_pkg.GET_CONFIG_VALUE('P6USER');

    begin

      log_pkg.steps(null, v_step_start, v_steps_result);

      select decode(existsnode(p_timeline, '//activities', message_pkg.xmlns_ipms), 0,
                    insertChildXML(p_timeline, '/*', 'activities',
                                   xmltype('<activities ' || message_pkg.xmlns_ipms || '/>')), p_timeline)
      into p_timeline
      from dual;

      log_pkg.steps('a', v_step_start, v_steps_result);

      for act in (

      select
        act.project_activity_id,
        act.import_id,
        xmlelement("activity", xmlattributes (nvl(act.p6_activity_id, '#new#') as "id",
                   act.project_activity_id as "studyElementId",
                   decode(act.status_code || act.is_to_be_deleted, 'OLD0', 'true', 'false') as "mustBeDeleted",
                   act.study_id as "studyId",
                   'true' as "restricted",
                   act.project_id || '-RAW' as "timelineId", message_pkg.nsuri_ipms as "xmlns"),
                   xmlforest(act.project_activity_name as "name",
                             'Task Dependent' as "type",
                             get_char_date(act.plan_start_date) as "planStart",
                             get_char_date(act.plan_finish_date) as "planFinish",
                             get_char_date(act.act_start_date) as "actualStart",
                             get_char_date(act.act_finish_date) as "actualFinish",
                             'Auto' as "integrationType"),
                   xmlelement("wbsCategoryName", act.wbs_category)
        )
          as payload
      from import_project_activity act
      where
        act.import_id = p_import.id
        and (act.status_code = 'READY' or status_code = 'OLD' and create_user = v_promis_create_user or
             is_to_be_deleted = 1)
      order by act.project_activity_id
      ) loop

        select insertchildxml(p_timeline, '//timeline/activities', 'activity', act.payload, message_pkg.xmlns_ipms)
        into p_timeline
        from dual;
        v_rowcount := v_rowcount + sql%rowcount;

      end loop;

      update import_project_activity
      set status_code = 'SEND'
      where import_id = p_import.id and status_code in ('READY', 'OLD');

      log_pkg.steps('b' || v_rowcount, v_step_start, v_steps_result);

      /* count affected rows */
      select count(1)
      into v_rowcount
      from import_project_activity
      where import_id = p_import.id and status_code = 'SEND';

      log_pkg.steps('c' || v_rowcount, v_step_start, v_steps_result);


      log_pkg.steps('END', v_procedure_start, v_steps_result);
      log_pkg.slog(v_where, v_par, v_steps_result || ';count=' || v_rowcount);

      return v_rowcount;

      exception when others then
      log_pkg.steps('ERROR', v_procedure_start, v_steps_result);
      log_pkg.scatch(v_where, v_par, v_steps_result);
      raise;

    end import_submit;

	/*************************************************************************/
	procedure import_finish(p_import in import%rowtype)
	as
		v_rowcount        number := 0;
		v_where           nvarchar2(99) := 'project_activities_pkg.import_finish';
		v_par             nvarchar2(4000) := 'p_import.id=' || p_import.id;
		v_msg_out         nvarchar2(4000);
		v_loop_msg_out    nvarchar2(4000);
		v_step_start      timestamp := systimestamp;
		v_steps_result    nvarchar2(4000);
		v_procedure_start timestamp := systimestamp;

	begin

		log_pkg.steps(null, v_step_start, v_steps_result);

		update project_activity set 
			is_manual   = 0,
			artificial_id = project_id || ':' || project_activity_id || ':' || study_id || ':' || wbs_category
		where artificial_id in 
			(
			select 
				artificial_id
			from import_project_activity
			where import_id = p_import.id
			and project_id = p_import.project_id
			and is_cat_reset = 1
			)
		;
		v_rowcount := sql%rowcount;
		log_pkg.steps('a' || v_rowcount, v_step_start, v_steps_result);

		update project_activity set
			is_manual = 1
		where artificial_id in 
			(
			select
				artificial_id
			from import_project_activity
			where import_id = p_import.id
			and project_id = p_import.project_id
			and is_manual = 1 
			and is_cat_reset != 1
			)
		;
		v_rowcount := sql%rowcount;
		log_pkg.steps('b' || v_rowcount, v_step_start, v_steps_result);

		log_pkg.steps('END', v_procedure_start, v_steps_result);
		log_pkg.slog(v_where, v_par, v_steps_result || ';count=' || v_rowcount);

	exception when others then
		log_pkg.steps('ERROR', v_procedure_start, v_steps_result);
		log_pkg.scatch(v_where, v_par, v_steps_result);
		raise;
	end import_finish;

end;
/