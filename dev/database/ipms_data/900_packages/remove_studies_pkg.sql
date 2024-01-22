create or replace package remove_studies_pkg 
as
	/*************************************************************************/
	/**
	* Initiates send of delete study message to SOA mediator
	* Requires timeline ID, from which studies need to be removed
	* Throws no_data_found exception if requirements unmatched.
	* Asynchronous.
	*/
	procedure send(p_timeline_id in timeline.id%type);
	
	/*************************************************************************/	
	/**
	* Process response from SOA mediator after study deletion request has beed sent. Initiates timeline refresh.
	* Callback.
	*/
	procedure send_finish(p_timeline_id in timeline.id%type, p_payload in xmltype);
	
	/*************************************************************************/
	procedure delete(p_timeline_id in timeline.id%type);

end;
/
create or replace package body remove_studies_pkg as

	/*************************************************************************/
	procedure send(p_timeline_id in timeline.id%type)
	is
		v_payload xmltype;
		v_msgid nvarchar2(100);
		v_where nvarchar2(99):='remove_studies_pkg.send';
		v_par nvarchar2(4000):='p_timeline_id='||p_timeline_id;
		v_msg_out nvarchar2(4000);
		v_subject nvarchar2(99):='delete:study';
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
	begin
		log_pkg.steps(null,v_step_start,v_steps_result);

		select
			xmlelement
				("delete", XMLAttributes(message_pkg.nsuri_ipms_soa as "xmlns"),
				xmlelement
					("wbsNodes", XMLAttributes(message_pkg.nsuri_ipms as "xmlns"),
						xmlagg
						(
						xmlelement
							("wbs", XMLAttributes(s.timeline_id as "timelineId", s.wbs_id as "id"),
								xmlelement("code", s.code),
								xmlelement("name", s.name),
								xmlelement("studyPhase", nvl(s.phase,'n.a.'))
							)
						)
					)
				)
			into v_payload
		from study_data_vw s
		where s.timeline_id=p_timeline_id
		and s.is_delete=1;

		remove_studies_pkg.delete(p_timeline_id);

		v_msgid := message_pkg.send(v_subject||':'||p_timeline_id, v_payload,
		get_text('begin remove_studies_pkg.send_finish(''%1'',:1); end;',varchar2_table_typ(p_timeline_id)));

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.slog(v_where, v_par, v_steps_result||v_msg_out);
	exception when others then
		log_pkg.steps('ERROR',v_procedure_start,v_steps_result);
		log_pkg.scatch(v_where, v_par, v_steps_result||v_msg_out);
		raise;
	end;

	/*************************************************************************/
	procedure send_finish(p_timeline_id in timeline.id%type, p_payload in xmltype)
	is
		v_where nvarchar2(99):='remove_studies_pkg.send_finish';
		v_par nvarchar2(4000):='p_timeline_id='||p_timeline_id;
		v_msg_out nvarchar2(4000);
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
	begin
		--validate response
		if message_pkg.is_complete(p_payload)=0 then
			return;
		end if;

		log_pkg.steps(null,v_step_start,v_steps_result);

		update timeline set is_syncing=0 where id=p_timeline_id and is_syncing=1;

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.slog(v_where, v_par, v_steps_result||v_msg_out);
	exception when others then
		log_pkg.steps('ERROR',v_procedure_start,v_steps_result);
		log_pkg.scatch(v_where, v_par, v_steps_result||v_msg_out);
		raise;
	end;

	/*************************************************************************/
	procedure delete(p_timeline_id in timeline.id%type)
	is
		--v_rowcount pls_integer:=0;
		--v_sum_rowcount pls_integer:=0;
		v_where nvarchar2(99):='remove_studies_pkg.delete';
		v_par nvarchar2(4000):='p_timeline_id='||p_timeline_id;
		v_msg_out nvarchar2(4000);
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
	begin
		log_pkg.steps(null,v_step_start,v_steps_result);

--COSTS --needs to be chekced if no past cost records exists
--COSTS_FPS --needs to be chekced if no past cost records exists
--FTE --ok, delete is done later.
--GOAL --ok, no fki
--IMPORT_COSTS --ok, no fki
--IMPORT_COSTS_FPS --ok, no fki
--IMPORT_RESOURCES --ok, no fki
--IMPORT_RESOURCES_CS --ok, no fki
--IMPORT_RESOURCES_GED --ok, no fki
--IMPORT_STUDY --ok, no fki
--IMPORT_STUDY_DATA --ok, no fki
--IMPORT_STUDY_FTE --ok, no fki
--IMPORT_TIMELINE --ok, no fki
--LATEST_ESTIMATE --ok, check is done later
--LTC_ESTIMATE --ok, same as for LE
--LTC_PLAN --ok, no fki
--RESOURCES --ok, no fki
--RESOURCES_CS --ok, no fki
--RESOURCES_GED --ok, no fki
--TIMELINE_WBS --ok, no fki


		for tl in
		(
			select
				s.id,
				s.study_modus_no,
				s.project_id
			from study s
			join timeline_wbs tw on tw.study_id  = s.id
			and tw.timeline_id = p_timeline_id
			and not
				(
					exists (
							select 1 from costs_fps fps
							where fps.study_id = s.id
							and fps.project_id=s.project_id
							and extract(year from fps.start_date) >= extract(year from sysdate) --we have currect yet important data, thus study can not be deleted
							)
					or
					exists (
							select 1 from costs cs
							where cs.study_id = s.id
							and cs.project_id=s.project_id
							and extract(year from cs.start_date) >= extract(year from sysdate) --we have currect yet important data, thus study can not be deleted
							)
				)
			and tw.timeline_type_code = 'RAW' --and still exists in the RAW plan
			and s.is_delete = 1 --marked for deletion from UI ADF
            and s.study_modus_no = 4 -- delete only Study Modus = Cancelled (IPMSSUP-718)
			group by s.id,s.study_modus_no,s.project_id
		)
		loop

			delete from fte t where t.study_id = tl.id;
			delete from resources_ged r where r.study_id = tl.id;
			--if any costs exists then it must be old one because the new costs (sysdate+0123) are being filtered in a main loop SQL
			delete from costs where study_id = tl.id and project_id=tl.project_id;
			delete from costs_fps where study_id = tl.id and project_id=tl.project_id;

			delete from study st where st.id=tl.id;

			begin
				v_msg_out:=v_msg_out||';sid='||tl.id;
			exception when others then null; end;

		end loop;

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.slog(v_where, v_par, v_steps_result||v_msg_out);
	exception when others then
		log_pkg.steps('ERROR',v_procedure_start,v_steps_result);
		log_pkg.scatch(v_where, v_par, v_steps_result||v_msg_out);
		raise;
	end;

end;
/