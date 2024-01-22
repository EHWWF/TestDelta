create or replace package import_qplan_pkg as

	/**
	 * Launches import from FPS
	 */
	procedure launch(p_id in nvarchar2);

	/**
	 * Finishes import from FPS and submits data to ProMIS
	 */
	procedure finish(p_id in nvarchar2);
	procedure finish(p_id in nvarchar2, p_payload xmltype);

	/** 
	 * Finishes reading timeline from ProMIS (loads data for import)
	 */
	procedure load_promis_data(p_id in nvarchar2, p_payload xmltype);

	/** 
	 * Finishes reading timeline from FPS (merges timeline into table import_timeline)
	 */
	procedure merge_fps_timeline(p_id in nvarchar2, p_payload xmltype);

	/** 
	 * Finishes reading study placeholders from FPS (merges studies into table import_study_data)
	 */
	procedure merge_fps_placeholder_studies(p_id in nvarchar2, p_payload xmltype);
	
	--cleaning data from 0001-01-01 empty dates
	function clean_date(p_date nvarchar2) return date;

end;
/
create or replace package body import_qplan_pkg as

	v_import import%rowtype;
	v_null_date nvarchar2(33):='0001-01-01T00:00:00';

	/*************************************************************************/
	function get_subject(p_id in nvarchar2 := null) return nvarchar2 as
	begin
		return 'import:'||nvl(v_import.id, p_id);
	end;

	/*************************************************************************/
	function get_summary return nvarchar2 as
	begin
		if v_import.project_id is not null then
			return 'Import['||v_import.id||'] of '||project_pkg.get_summary(v_import.project_id);
		else
			return 'Import['||v_import.id||']';
		end if;
	end;

	/*************************************************************************/
	procedure catch(p_id in nvarchar2, p_error in nvarchar2) as
	begin
		if v_import.id is null and p_id is not null then
			select * into v_import from import where id=p_id;
		end if;
		notice_pkg.catch(get_subject, get_summary||' failed.', p_error);
		update import set status_code='FAIL', timestamp_log=substr(timestamp_log||'sqlerrm='||p_error, 1, 4000) where id=p_id;
	end;

	/*************************************************************************/
	procedure catch(p_id in nvarchar2, p_payload in xmltype) as
		v_error nvarchar2(4000);
	begin
		if v_import.id is null and p_id is not null then
			select * into v_import from import where id=p_id;
		end if;
		v_error := 'Error '|| p_payload.extract('/error/code/text()', message_pkg.xmlns_ipms).getStringVal() || ' in message '||p_payload.extract('/error/@id', 'xmlns="http://xmlns.bayer.com/ipms"').getStringVal();
		notice_pkg.error(get_subject, get_summary||' failed.', v_error);
		update import set status_code='FAIL', timestamp_log=substr(timestamp_log||'sqlerrm='||v_error, 1, 4000) where id=p_id;
	end;

	/*************************************************************************/
	function clean_date(p_date nvarchar2) return date
    as
        pragma autonomous_transaction;
	begin
		return to_date(substr(replace(p_date,v_null_date),1,10),'yyyy-mm-dd');
	end;

    /*************************************************************************/
	/** Internal import functions *********************************************/
	function load_promis_timeline return number as
	begin

		-- Remove previous import entries as well as obsolete hierachy
		delete from import_timeline itl
		where itl.project_id=v_import.project_id
			and exists (
				select *
				from import i
				where i.id=itl.import_id
                and i.source=v_import.source
			)
			and id not in (
				select id
				from import_timeline
				start with wbs_id is null and not (
					bitand(v_import.type_mask, import_pkg.type_plan) > 0 and type_code='PLAN'
					or
					bitand(v_import.type_mask, import_pkg.type_actuals) > 0 and type_code='ACT'
				)
				connect by prior import_id=import_id and prior project_id=project_id and prior parent_wbs_id=wbs_id
			);

		insert into import_timeline(
			import_id,
			project_id,
			timeline_id,
			reference_id,
			name,
			study_id,
			study_element_id,
			parent_wbs_id,
			activity_id,
			activity_type,
			type_code,
			old_start_date,
			old_finish_date,
			status_code
			)
		with
			type_code as (
				select 'PLAN' as type_code from dual where bitand(v_import.type_mask, import_pkg.type_plan) > 0
				union all
				select 'ACT' as type_code from dual where bitand(v_import.type_mask, import_pkg.type_actuals) > 0
			)
		select
			v_import.id as import_id,
			ta.project_id,
			ta.timeline_id,
			tc.type_code||ta.activity_id||to_char(rownum) as reference_id,
			ta.name,
			ts.study_id,
			ta.study_element_id,
			ta.parent_wbs_id,
			ta.activity_id,
			ta.type as activity_type,
			tc.type_code,
			decode(tc.type_code, 'ACT', actual_start, plan_start) as start_date,
			decode(tc.type_code, 'ACT', actual_finish, plan_finish) as finish_date,
			'OLD'
		from timeline_activity ta
		left join study_vw ts on ta.timeline_id=ts.timeline_id and ts.wbs_id=ta.parent_wbs_id
		cross join type_code tc
		where ta.project_id = v_import.project_id
			and ta.timeline_type_code='RAW'
			and lower(ta.integration_type)='auto';

		/* merge wbs */
		insert into import_timeline(import_id,project_id,timeline_id,parent_wbs_id,wbs_id,study_id,sequence_number,code,name,status_code,old_start_date,old_finish_date)
		select v_import.id,tw.project_id,tw.timeline_id,tw.parent_wbs_id,tw.wbs_id,tw.study_id,tw.sequence_number,tw.code,tw.name,'OLD',tw.start_date,tw.finish_date
		from import imp
		join timeline tl on tl.project_id=imp.project_id and tl.type_code='RAW'
		join timeline_wbs tw on tw.timeline_id=tl.id
		where imp.id=v_import.id and bitand(imp.type_mask,import_pkg.type_plan)=import_pkg.type_plan;

		return sql%rowcount;
	end;

	/*************************************************************************/
	function load_promis_studies return number
    as
	begin

		delete from import_study_data
		where project_id = v_import.project_id;

		insert into import_study_data (
			import_id,
			project_id,
			study_id,
			wbs_id,
			placeholder,
			name,
			old_start_date,
			old_finish_date,
			status_code,
			status_description,
			is_existing
		)
		with src as (
			select wbs_id, milestone_type, max(milestone_date) milestone_date, count(1) count
            from milestone_vw
			where project_id=v_import.project_id
            and timeline_type_code='RAW'
            and milestone_type in ('Start Milestone','Finish Milestone')
			group by wbs_id, milestone_type
        )
		select
			max(v_import.id) import_id,
			max(sd.project_id) project_id,
			max(sd.study_id) study_id,
			sd.wbs_id,
			max(sd.placeholder) placeholder,
			max(sd.name) name,
	  		case when max(sm.count)=1 then max(sm.milestone_date) else null end start_date,
      		case when max(fm.count)=1 then max(fm.milestone_date) else null end finish_date,
			case when max(sm.count)>1 or max(fm.count)>1 then 'FAIL' else 'OLD' end,
      		case when max(sm.count)>1 or  max(fm.count)>1 then 'More than one start or finish milestone exists for a study' end,
			1
      	from study_data_vw sd
		left join src sm on sm.milestone_type='Start Milestone' and sm.wbs_id=sd.wbs_id
		left join src fm on fm.milestone_type='Finish Milestone' and fm.wbs_id=sd.wbs_id
		where sd.project_id = v_import.project_id  and sd.timeline_type_code = 'RAW'
		group by sd.wbs_id;

		return sql%rowcount;

	end;

	/*************************************************************************/
	procedure submit(p_type_code nvarchar2 default null)
    as
		v_tlid timeline.id%type;
		v_timeline xmltype;
	begin

		select id into v_tlid from timeline
		where project_id = v_import.project_id
        and type_code='RAW'
        ;

		v_timeline := timeline_pkg.xml(v_tlid);

		if bitand(v_import.type_mask, import_pkg.type_actuals+import_pkg.type_plan) > 0 then

			update import_timeline set status_code = 'SEND'
			where import_id=v_import.id and project_id=v_import.project_id
				and status_code in ('READY', 'SEND')
				and not(action_code='SKIP');

			select v_timeline.appendChildXML('/*',
				xmlelement("activities",
					xmlattributes(message_pkg.nsuri_ipms as "xmlns"),
					(
					select
						xmlagg(
						xmlelement("activity",
							xmlattributes(
								act.parent_wbs_id as "wbsId",
								act.activity_id as "id",
								act.study_element_id as "studyElementId",
								v_tlid as "timelineId",
								decode(act.action_code,'APPLY','false','true')  as "restricted"
							),
							xmlforest(
								act.activity_type as "type",
								get_char_date(act.new_start_date) as evalname(decode(act.type_code, 'PLAN', 'planStart', 'actualStart')),
								get_char_date(act.new_finish_date) as evalname(decode(act.type_code, 'PLAN', 'planFinish', 'actualFinish'))
							)
						))
						from import_timeline act
						where import_id = v_import.id and status_code = 'SEND'
					)
				))
				into v_timeline
				from dual;

		end if;


		if bitand(v_import.type_mask, import_pkg.type_study) > 0 then

			select v_timeline.appendChildXML('/*',
				xmlconcat(
					xmlelement("wbsNewPlaceholders",
						xmlattributes(message_pkg.nsuri_ipms as "xmlns"),
						(select
							xmlagg(
							xmlelement("wbs",
								xmlattributes(
									'#MISSING#' as "id",
									study_id AS "studyId",
									v_tlid AS "timelineId",
									decode(placeholder, 1, 'true', 'false') as "placeholder"
								),
								xmlforest(
									import_id||'-'||rownum as "code",
									name as "name",
									get_char_date(start_date) as "startDate",
									get_char_date(finish_date) as "finishDate"
								)
							))
						from import_study_data
						where import_id = v_import.id and project_id = v_import.project_id
							and status_code = 'READY' and action_code='ACCEPT' and is_existing=0
						)
					),
					xmlelement("wbsNodes",
						xmlattributes(message_pkg.nsuri_ipms as "xmlns"),
						(select
							xmlagg(
							xmlelement("wbs",
								xmlattributes(
									wbs_id as "id",
									study_id AS "studyId",
									v_tlid AS "timelineId",
									decode(placeholder, 1, 'true', 'false') as "placeholder"
								),
								xmlforest(
									name as "name",
									get_char_date(start_date) as "startDate",
									get_char_date(finish_date) as "finishDate"
								)
							))
						from import_study_data
						where import_id = v_import.id and project_id = v_import.project_id
							and status_code = 'READY' and action_code='ACCEPT'  and is_existing=1
						)
					)
				)
			)
			into v_timeline
			from dual;

		end if;


		if p_type_code is not null then
			if (v_timeline.existsNode('//activity', message_pkg.xmlns_ipms) = 1) then
				notice_pkg.debug(get_subject, get_summary||' sending timeline '||p_type_code);
				timeline_pkg.send(v_tlid, v_timeline, null);
			end if;
			return;
		end if;

		if (v_timeline.existsNode('//activity | //wbs', message_pkg.xmlns_ipms) = 1) then
			notice_pkg.debug(get_subject, get_summary||' sending timeline');
			timeline_pkg.send(v_tlid, v_timeline, 'import_qplan_pkg.finish('''||v_import.id||''',:1);');
			update import set is_syncing=1,status_code='SEND' where id=v_import.id;
		else
			notice_pkg.information(get_subject, get_summary||' finished.');
			update import set status_code='VOID' where id=v_import.id;
		end if;

	exception when others then
		catch(v_import.id, sqlerrm);
	end;

	/*************************************************************************/
	procedure merge_fps_timeline(p_id in nvarchar2, p_payload xmltype)
    as
		v_cnt number := 0;
		v_tlid timeline.id%type;
	begin

		if message_pkg.is_error(p_payload) = 1 then
			catch(p_id, p_payload);
			return;
		end if;
		if message_pkg.is_complete(p_payload) = 0 then
			return;
		end if;

		update import set is_syncing=0, sync_date=sysdate where id=p_id;
		select * into v_import from import where id=p_id and status_code='NEW';


		merge into import_timeline im
		using(
			with
				type_code as (
					select 'PLAN' as type_code from dual where bitand(v_import.type_mask, import_pkg.type_plan) > 0
					union all
					select 'ACT' as type_code from dual where bitand(v_import.type_mask, import_pkg.type_actuals) > 0
				)
			select
				v_import.project_id as project_id,
				type_code||v_import.id||to_char(rownum) as reference_id,
				study_element_id,
				date_status,
				type_code,
				case
					when type_code='PLAN' then clean_date(plan_start)
					when type_code='ACT' and date_status in ('In Progress', 'Finished') then clean_date(actual_start)
				end as start_date,
				case
					when type_code='PLAN' then clean_date(plan_finish)
					when type_code='ACT' and date_status in ('Finished') then clean_date(actual_finish)
				end as finish_date
			from xmltable(
					'//*:activity' passing p_payload
					columns
						study_element_id nvarchar2(100) path '@studyElementId',
						date_status varchar(100) path '*:dateStatus',
						plan_start varchar(100) path '*:planStart',
						plan_finish varchar(100) path '*:planFinish',
						actual_start varchar(100) path '*:actualStart',
						actual_finish varchar(100) path '*:actualFinish'
				) tl
				cross join type_code
		) xs
		on (
			im.project_id=xs.project_id
			and
			im.study_element_id=xs.study_element_id
			and
			im.type_code = xs.type_code
		)
		when matched then
			update set
				im.new_start_date = decode(im.activity_type, 'Start Milestone', xs.start_date),
				im.new_finish_date = decode(im.activity_type, 'Finish Milestone', xs.finish_date),
				im.status_code = 'READY',
				im.date_status=xs.date_status
		when not matched then
			insert (
				im.import_id,
				im.project_id,
				im.reference_id,
				im.study_element_id,
				im.date_status,
				im.type_code,
				im.new_start_date,
				im.new_finish_date,
				im.status_code,
				im.status_description,
				im.action_code
			)
			values (
				v_import.id,
				xs.project_id,
				xs.reference_id,
				xs.study_element_id,
				xs.date_status,
				xs.type_code,
				xs.start_date,
				xs.finish_date,
				'FAIL',
				'Matching study element id not found: '||xs.study_element_id,
				'SKIP'
			);

		--Remove all old nodes which are not related with importing activities
		delete from import_timeline tm2
        where tm2.import_id=v_import.id
        and tm2.status_code='OLD'
		and 'READY' not in
        (
            select status_code
            from import_timeline tm
            where tm.import_id=v_import.id
			connect by tm.parent_wbs_id = prior tm.wbs_id and tm.import_id=v_import.id
            start with tm.wbs_id=tm2.wbs_id and tm.import_id=v_import.id
        );

		update import_timeline set
            status_code='OLD'
		where import_id=v_import.id
        and status_code='READY'
        and activity_type is not null
        and new_start_date is null
        and new_finish_date is null
        ;

		select count(1) into v_cnt
        from import_timeline
		where import_id = v_import.id
        and status_code = 'READY'
        ;

		if (v_cnt > 0) then
			update import set status_code='READY' where id=v_import.id;

			if bitand(v_import.type_mask, import_pkg.type_actuals) > 0 then
				--submit ACT dates to P6 in the background
				update import_timeline set
                    action_code='ACCEPT',
                    status_description='Actual dates accepted automatically'
                where import_id=v_import.id
                and type_code='ACT'
                and status_code='READY'
                ;

                submit('ACT');
			end if;
		else
			update import set
                status_code=decode(is_manual, 0, 'VOID','DONE')
            where id=v_import.id
            ;
			notice_pkg.debug(get_subject, get_summary||' empty.');
		end if;

	exception when others then
		catch(p_id, sqlerrm);
	end;


	/**************************************************************************************************************/
	procedure merge_fps_placeholder_studies(p_id in nvarchar2, p_payload xmltype) as
		v_cnt number;
	begin
		if message_pkg.is_error(p_payload) = 1 then
			catch(p_id, p_payload);
			return;
		end if;
		if message_pkg.is_complete(p_payload) = 0 then
			return;
		end if;

		update import set is_syncing=0, sync_date=sysdate
		where id=p_id;

		select * into v_import from import
		where id=p_id and status_code='NEW';

		merge into import_study_data im
		using (
			select
				v_import.project_id as project_id, study_id,
				decode(placeholder, 'true', 1, 0) as placeholder,
				name,
				to_date(substr(replace(start_date,v_null_date),1,10),'yyyy-mm-dd') start_date,
				to_date(substr(replace(finish_date,v_null_date),1,10),'yyyy-mm-dd') finish_date
			from xmltable(
					'//*:wbs' passing p_payload
					columns
						study_id nvarchar2(100) path '@studyId',
						name nvarchar2(100) path '*:name',
						placeholder varchar(100) path '@placeholder',
						start_date varchar(100) path '*:startDate',
						finish_date varchar(100) path '*:finishDate'
			) ts
		) xs
		on (
			im.import_id = v_import.id
			and im.project_id=xs.project_id
			and im.study_id=xs.study_id
		)
		when matched then
			update set
				im.name = xs.name,
				im.start_date = xs.start_date,
				im.finish_date = xs.finish_date,
				im.status_code = decode(im.placeholder, xs.placeholder, 'READY', 'FAIL'),
				im.status_description = decode(im.placeholder, xs.placeholder, null, 'Study is not a placeholder: '||xs.study_id),
				im.action_code='SKIP'
			where im.status_code <> 'FAIL'
		when not matched then
			insert (
				im.import_id,
				im.project_id, im.study_id,
				im.name, im.placeholder,
				im.start_date, im.finish_date,
				im.status_code,
				im.is_existing,
				im.action_code
			)
			values (
				v_import.id,
				xs.project_id, xs.study_id,
				xs.name, xs.placeholder,
				xs.start_date, xs.finish_date,
				'READY',
				0,
				'SKIP'
			);

		delete from import_study_data where import_id=v_import.id and status_code='OLD';

		select count(*) into v_cnt from import_study_data
		where import_id = v_import.id and status_code = 'READY';

		if (v_cnt > 0) then
			update import set status_code='READY' where id=v_import.id;
		else
			update import set status_code=decode(is_manual, 0, 'VOID','DONE') where id=v_import.id;
			notice_pkg.debug(get_subject, get_summary||' empty.');
		end if;

	exception when others then
		catch(p_id, sqlerrm);
	end;

    /*************************************************************************/
	procedure load_promis_data(p_id in nvarchar2, p_payload xmltype) as
		v_cnt number;
	begin
		if message_pkg.is_error(p_payload) = 1 then
			catch(p_id, p_payload);
			return;
		end if;
		if message_pkg.is_complete(p_payload) = 0 then
			return;
		end if;

		update import set is_syncing=0, sync_date=sysdate
		where id=p_id;

		select * into v_import from import
		where id=p_id and status_code='NEW';


		if bitand(v_import.type_mask, import_pkg.type_actuals+import_pkg.type_plan) > 0 then
			notice_pkg.information(get_subject, get_summary||' timeline from FPS/QuickPlan.');

			v_cnt := load_promis_timeline();
			qplan_pkg.receive_timeline(v_import.project_id, 'import_qplan_pkg.merge_fps_timeline('||v_import.id||', :1);');
			update import set is_syncing=1 where id=v_import.id;

		elsif bitand(v_import.type_mask, import_pkg.type_study) > 0 then
			notice_pkg.information(get_subject, get_summary||' study placeholders from FPS/QuickPlan.');

			v_cnt := load_promis_studies;
			qplan_pkg.receive_placeholder_studies(v_import.project_id, 'import_qplan_pkg.merge_fps_placeholder_studies('||v_import.id||', :1);');
			update import set is_syncing=1 where id=v_import.id;
		end if;


	exception when others then
		catch(p_id, sqlerrm);
	end;

	/*************************************************************************/
	procedure launch(p_id in nvarchar2) 
	as
		v_tlid timeline.id%type;
		v_where nvarchar2(222) := 'ltc_import.launch';
		v_par nvarchar2(4000) := 'p_id=' || p_id;
		--v_rowcount number := 0;
		v_step_start timestamp := systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp := systimestamp;
		--v_msg_out nvarchar2(4000);
	begin
		log_pkg.steps(null, v_step_start, v_steps_result);

		select * into v_import from import
		where id=p_id 
		and status_code='NEW';

		select id into v_tlid 
		from timeline
		where project_id = v_import.project_id 
		and type_code='RAW';

		timeline_pkg.receive(v_tlid, 'begin import_qplan_pkg.load_promis_data('||v_import.id||',:1); end;');
		update import set is_syncing=1 where id=p_id;

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.slog(v_where,v_par||';v_tlid='||v_tlid,v_steps_result);

	exception when others then
		log_pkg.scatch(v_where,v_par||';v_tlid='||v_tlid,v_steps_result);
		catch(p_id, sqlerrm);
	end;

	/*************************************************************************/
	procedure finish(p_id in nvarchar2) as
	begin

		select * into v_import from import
		where id=p_id and source='FPS' and status_code='READY';

		submit;

	exception when others then
		catch(p_id, sqlerrm);
	end;

	/*************************************************************************/
	procedure finish(p_id in nvarchar2, p_payload xmltype) as
	begin
		if message_pkg.is_error(p_payload) = 1 then
			catch(p_id, p_payload);
			return;
		end if;
		if message_pkg.is_complete(p_payload)=0 then
			return;
		end if;

		update import set is_syncing=0, sync_date=sysdate where id=p_id;
		select * into v_import from import where id=p_id;

		--Refreshing P6 data in PROMIS to have updated activity dates locally
		timeline_pkg.receive(p_payload.extract('//timeline/@id',message_pkg.xmlns_ipms).getStringVal());

		update import_timeline set status_code='DONE' where import_id=p_id and status_code='SEND';
		update import set status_code='DONE' where id=p_id;

		notice_pkg.information(get_subject, get_summary||' finished.');
		log_pkg.log(get_subject, get_summary, 'Finished.');

	end;

end;
/