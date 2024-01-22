create or replace package ltc_bpm_pkg
as
  /*************************************************************************/
  /*************************************************************************/
  /*
  */
  procedure stop_process
    (
      p_user_id        in nvarchar2,
      p_ltc_process_id in number
    )
  ;
  /*************************************************************************/
  /*
  */
  procedure stop_bpm_process_finish
    (
      p_user_id        in nvarchar2,
      p_ltc_process_id in number, --ltc_process.id
      p_payload        in xmltype
    )
  ;
  /*************************************************************************/
  /*
  */
  procedure start_process
    (
      p_user_id        in nvarchar2,
      p_ltc_process_id in number
    )
  ;
  /*************************************************************************/
  /*
  */
  procedure start_bpm_process_finish
    (
      p_user_id        in nvarchar2,
      p_ltc_process_id in number, --ltc_process.id
      p_payload        in xmltype
    )
  ;
  /*************************************************************************/
  procedure restart_process
    (
      p_user_id        in nvarchar2,
      p_ltc_process_id in number
    )
  ;
  /*************************************************************************/
  procedure restart_bpm_process_finish
    (
      p_user_id        in nvarchar2,
      p_ltc_process_id in number, --ltc_process.id
      p_payload        in xmltype
    )
  ;
  /*************************************************************************/
  /*************************************************************************/
end;
/
create or replace package body ltc_bpm_pkg
as

  /*************************************************************************/
  /*
  */
  procedure start_process
    (
      p_user_id        in nvarchar2,
      p_ltc_process_id in number
    )
  as
    v_where nvarchar2(222) := 'ltc_bpm_pkg.start_process';
    v_par   nvarchar2(4000) :=
    'p_user_id=' || p_user_id || ';p_ltc_process_id=' || p_ltc_process_id;
    begin

      -- Initial prefill from profit and FPS
      for r in (select ltc_tag_id
                from ltc_process
                where id = p_ltc_process_id) loop

        ltc_sheet_pkg.prefill(r.ltc_tag_id, p_ltc_process_id, null, null, 0);
        ltc_sheet_pkg.prefill_fps(r.ltc_tag_id, p_ltc_process_id);

        --Update ltc_project in order to change flag that all prefil was done.
        update ltc_project
        set is_initially_prefiled = 1
        where is_initially_prefiled = 0
              and ltc_process_id in
                  (
                    select ltcprj.ltc_process_id
                    from ltc_project ltcprj
                      join ltc_process ltcp on (ltcprj.ltc_process_id = ltcp.id)
                      join project prj on (prj.id = ltcprj.project_id)
                    where r.ltc_tag_id = ltcp.ltc_tag_id
                          and p_ltc_process_id = ltcprj.ltc_process_id
                  );

        ltc_sheet_pkg.recalculate(r.ltc_tag_id, p_ltc_process_id);
      end loop;

      update ltc_process
      set
        sync_date      = sysdate,
        status_code    = 'RUN',
        update_user_id = p_user_id
      where id = p_ltc_process_id;

      task_pkg.create_ltc(p_ltc_process_id);

      --stop_bpm_process(p_user_id,p_ltc_process_id); -- Use this line when want to use real BPM process. Comment everything else in this procedure.

      log_pkg.log(v_where, v_par);

      exception when others then
      notice_pkg.catch(v_where, v_par);
      raise;
    end;

  /*************************************************************************/
  /*
  */
  procedure stop_process
    (
      p_user_id        in nvarchar2,
      p_ltc_process_id in number
    )
  as
    v_where nvarchar2(222) := 'ltc_bpm_pkg.stop_process';
    v_par   nvarchar2(4000) :=
    'p_user_id=' || p_user_id || ';p_ltc_process_id=' || p_ltc_process_id;
    begin

      update ltc_process
      set
        sync_date         = sysdate,
        status_code       = 'FIN',
        update_user_id    = p_user_id,
        terminate_date    = sysdate,
        terminate_user_id = p_user_id
      where id = p_ltc_process_id;

      task_pkg.revoke_ltc(p_ltc_process_id);

      --stop_bpm_process(p_user_id,p_ltc_process_id); -- Use this line when want to use real BPM process. Comment everything else in this procedure.

      log_pkg.log(v_where, v_par);

      exception when others then
      notice_pkg.catch(v_where, v_par);
      raise;
    end;

  /*************************************************************************/
  /*
  */
  procedure restart_process
    (
      p_user_id        in nvarchar2,
      p_ltc_process_id in number
    )
  as
    v_where       nvarchar2(222) := 'ltc_bpm_pkg.restart_process';
    v_par         nvarchar2(4000) :=
    'p_user_id=' || p_user_id || ';p_ltc_process_id=' || p_ltc_process_id;
    v_status_code nvarchar2(10);

    begin

      select status_code
      into v_status_code
      from ltc_process
      where id = p_ltc_process_id;


      if v_status_code = 'RUN'
      then
        stop_process(p_user_id, p_ltc_process_id);
        start_process(p_user_id, p_ltc_process_id);

      elsif v_status_code = 'FIN'
        then
          for r in (select ltc_tag_id
                    from ltc_process
                    where id = p_ltc_process_id) loop
            ltc_sheet_pkg.prefill(r.ltc_tag_id, p_ltc_process_id, null, null, 0);
            ltc_sheet_pkg.recalculate(r.ltc_tag_id, p_ltc_process_id);
          end loop;
      end if;

      log_pkg.log(v_where, v_par);

      exception when others then

      notice_pkg.catch(v_where, v_par);
      raise;
    end;

  /*************************************************************************/
  /*
  */
  procedure stop_bpm_process
    (
      p_user_id        in nvarchar2,
      p_ltc_process_id in number, --ltc_process.id
      p_callback       in varchar2 default null
    )
  as
    v_where           nvarchar2(222) := 'ltc_bpm_pkg.stop_bpm_process';
    v_par             nvarchar2(4000) :=
    'p_user_id=' || p_user_id || ';p_ltc_process_id=' || p_ltc_process_id || ';p_callback=' || p_callback;
    v_rowcount        number := 0;
    v_step_start      timestamp := systimestamp;
    v_steps_result    nvarchar2(4000);
    v_procedure_start timestamp := systimestamp;
    v_msg_out         nvarchar2(4000);
    v_msg_id          ltc_process.sync_id%type;
    --v_ltc_tag_id number;

    begin
      log_pkg.steps(null, v_step_start, v_steps_result);

      select sync_id
      into v_msg_id
      from ltc_process
      where id = p_ltc_process_id
            and status_code in ('RUN', 'NEW');

      if v_msg_id is not null
      then -- does not make sense to terminate without knowing msg ID
        v_msg_id := message_pkg.terminate(v_msg_id, 'EstimateLTC',
                                          get_text(
                                              'begin ltc_bpm_pkg.stop_bpm_process_finish(''%1'',''%2'',:1);%3 end;',
                                              varchar2_table_typ(p_user_id, p_ltc_process_id, p_callback)));

        if v_msg_id is not null
        then -- do not update to NULL if something went wrong with BPM termination
          update ltc_process
          set
            is_syncing     = 1,
            sync_id        = v_msg_id,
            update_user_id = p_user_id
          where id = p_ltc_process_id;
        else
          v_msg_out := 'ERROR. Missing MSG ID after message_pkg.terminate!!!';
        end if;

      else
        v_msg_out := 'ERROR. Missing MSG ID!!!';

        --Nevertheless, the Termination of the Process must be DONE because it was started incorrectly
        update ltc_process
        set
          sync_date         = sysdate,
          is_syncing        = 0,
          status_code       = 'FIN',
          update_user_id    = p_user_id,
          terminate_date    = sysdate,
          terminate_user_id = p_user_id
        where id = p_ltc_process_id
        --returning ltc_tag_id into v_ltc_tag_id
        ;

        /*
              update ltc_tag
              set is_meeting_allowed=1,update_user_id=p_user_id
              where id=v_ltc_tag_id
              and is_meeting_allowed=0
              ;
        */

      end if;

      --v_rowcount := sql%rowcount;
      --log_pkg.steps('a'||v_rowcount,v_step_start,v_steps_result);

      log_pkg.steps('END.', v_procedure_start, v_steps_result);
      log_pkg.log(v_where, v_par, v_steps_result || v_msg_out);

      exception when others then
      log_pkg.steps('ERROR.', v_procedure_start, v_steps_result);
      log_pkg.log(v_where, v_par, v_steps_result || v_msg_out);
      notice_pkg.catch(v_where, v_par || v_steps_result || v_msg_out);
      raise;
    end;

  /*************************************************************************/
  procedure stop_bpm_process_finish
    (
      p_user_id        in nvarchar2,
      p_ltc_process_id in number, --ltc_process.id
      p_payload        in xmltype
    )
  as
    v_where nvarchar2(222) := 'ltc_bpm_pkg.stop_bpm_process_finish';
    v_par   nvarchar2(4000) := 'p_user_id=' || p_user_id || ';p_ltc_process_id=' || p_ltc_process_id;

    begin
      -- validate response
      if message_pkg.is_complete(p_payload) = 0
      then
        return;
      end if;

      update ltc_process
      set
        sync_date         = sysdate,
        is_syncing        = 0,
        status_code       = 'FIN',
        update_user_id    = p_user_id,
        terminate_date    = sysdate,
        terminate_user_id = p_user_id
      where id = p_ltc_process_id
      --returning ltc_tag_id into v_ltc_tag_id
      ;
      --update latest_estimates_tag let set let.is_meeting_allowed=1 where id=l_let_id and let.is_meeting_allowed=0;

      log_pkg.log(v_where, v_par, 'BPM:Terminated.');

      exception when others then
      notice_pkg.catch(v_where, v_par);
      raise;
    end;

  /*************************************************************************/
  procedure start_bpm_process
    (
      p_user_id        in nvarchar2,
      p_ltc_process_id in number, --ltc_process.id
      p_callback       in varchar2 default null
    )
  as
    v_where           nvarchar2(222) := 'ltc_bpm_pkg.start_bpm_process';
    v_par             nvarchar2(4000) :=
    'p_user_id=' || p_user_id || ';p_ltc_process_id=' || p_ltc_process_id || ';p_callback=' || p_callback;
    --v_rowcount number:=0;
    --v_step_start timestamp:= systimestamp;
    --v_steps_result nvarchar2(4000);
    --v_procedure_start timestamp:= systimestamp;
    --v_msg_out nvarchar2(4000);
    v_msg_id          ltc_process.sync_id%type;
    --v_ltc_tag_id number;
    v_payload         xmltype;

    v_step_start      timestamp := systimestamp;
    v_steps_result    nvarchar2(4000);
    v_procedure_start timestamp := systimestamp;
    v_msg_out         nvarchar2(4000);

    begin
      log_pkg.steps(null, v_step_start, v_steps_result);

      -- Initial prefill from profit
      for r in (select ltc_tag_id
                from ltc_process
                where id = p_ltc_process_id) loop
        ltc_sheet_pkg.prefill(r.ltc_tag_id, p_ltc_process_id, null, null, 0);
        ltc_sheet_pkg.recalculate(r.ltc_tag_id, p_ltc_process_id);
      end loop;

      --get XML Payload
      select message_pkg.xml(
          '<estimate ' || message_pkg.xmlns_ipms_soa || ' componentName="EstimateLTC">' ||
          '<process id="' || p_ltc_process_id || '" ' || message_pkg.xmlns_ipms || '>' ||
          get_element('name', ltcp.name) || --not needed but let's keep for consistency as we haev it at LE
          get_element('terminationDate', get_char_date(ltcp.termination_date)) ||
          get_element('tag', ltctag.name) ||
          get_element('processName', ltcp.name) ||
          '</process>' ||
          '<programs ' || message_pkg.xmlns_ipms || '/>' ||
          '</estimate>')
      into v_payload
      from ltc_process ltcp
        join ltc_tag ltctag on (ltcp.ltc_tag_id = ltctag.id)
      where ltcp.id = p_ltc_process_id
            and ltcp.status_code in ('NEW', 'RUN');

      --collect programs
      for prg in
      (
      select prj.program_id
      from ltc_project ltcprj
        join project prj on (prj.id = ltcprj.project_id)
      where ltcprj.ltc_process_id = p_ltc_process_id
      group by prj.program_id
      )
      loop
        v_payload := v_payload.appendchildxml('//programs', program_pkg.xml(prg.program_id, 2), message_pkg.xmlns_ipms);
      end loop;

      --send request
      v_msg_id := message_pkg.send
      (
          'estimate_ltc:' || p_ltc_process_id,
          v_payload,
          get_text('begin ltc_bpm_pkg.start_bpm_process_finish(''%1'',''%2'',:1);%3 end;',
                   varchar2_table_typ(p_user_id, p_ltc_process_id, p_callback))
      );

      --change status
      update ltc_process
      set
        status_code    = 'PLAN',
        is_syncing     = 1,
        sync_id        = v_msg_id,
        update_user_id = p_user_id
      where id = p_ltc_process_id;

      log_pkg.steps('END.', v_procedure_start, v_steps_result);
      log_pkg.log(v_where, v_par, v_steps_result || v_msg_out);

      exception when others then
      log_pkg.steps('ERROR.', v_procedure_start, v_steps_result);
      log_pkg.log(v_where, v_par, v_steps_result || v_msg_out);
      notice_pkg.catch(v_where, v_par || v_steps_result || v_msg_out);
      raise;
    end;

  /*************************************************************************/
  procedure start_bpm_process_finish
    (
      p_user_id        in nvarchar2,
      p_ltc_process_id in number, --ltc_process.id
      p_payload        in xmltype
    )
  as
    v_where   nvarchar2(222) := 'ltc_bpm_pkg.start_bpm_process_finish';
    v_par     nvarchar2(4000) := 'p_user_id=' || p_user_id || ';p_ltc_process_id=' || p_ltc_process_id;
    v_msg_out nvarchar2(4000);

    begin
      -- validate response
      if message_pkg.is_accept(p_payload) = 1
      then
        -- process started, setup data
        update ltc_process
        set
          sync_date      = sysdate,
          is_syncing     = 0,
          status_code    = 'RUN',
          update_user_id = p_user_id
        where id = p_ltc_process_id
        --returning ltc_tag_id into v_ltc_tag_id
        ;

        --TODO !!! setup(l_tag_id, p_ltc_process_id, null);
        v_msg_out := 'BPM:Started.';

      elsif message_pkg.is_complete(p_payload) = 1
        then
          -- process completed immediatelly afer startup
          update ltc_process
          set
            sync_date         = sysdate,
            is_syncing        = 0,
            status_code       = 'FIN',
            update_user_id    = p_user_id,
            terminate_date    = sysdate,
            terminate_user_id = p_user_id
          where id = p_ltc_process_id;

          v_msg_out := 'BPM:Finished.';

      end if;

      log_pkg.log(v_where, v_par, v_msg_out);

      exception when others then
      notice_pkg.catch(v_where, v_par);
      raise;
    end;

  /*************************************************************************/
  procedure restart_bpm_process
    (
      p_user_id        in nvarchar2,
      p_ltc_process_id in number, --ltc_process.id
      p_callback       in varchar2 default null
    )
  as
    v_where           nvarchar2(222) := 'ltc_bpm_pkg.restart_bpm_process';
    v_par             nvarchar2(4000) :=
    'p_user_id=' || p_user_id || ';p_ltc_process_id=' || p_ltc_process_id || ';p_callback=' || p_callback;
    --v_rowcount number:=0;
    --v_step_start timestamp:= systimestamp;
    --v_steps_result nvarchar2(4000);
    --v_procedure_start timestamp:= systimestamp;
    --v_msg_out nvarchar2(4000);
    v_msg_id          ltc_process.sync_id%type;
    --v_ltc_tag_id number;
    v_payload         xmltype;

    v_step_start      timestamp := systimestamp;
    v_steps_result    nvarchar2(4000);
    v_procedure_start timestamp := systimestamp;
    v_msg_out         nvarchar2(4000);
    v_status_code     nvarchar2(10);

    begin
      log_pkg.steps(null, v_step_start, v_steps_result);

      select
        sync_id,
        status_code
      into v_msg_id, v_status_code
      from ltc_process
      where id = p_ltc_process_id
      --and status_code ='RUN'
      ;

      if v_msg_id is not null
      then -- doe snot make sense to terminate without knowing msg ID
        if v_status_code = 'RUN'
        then
          v_msg_id := message_pkg.terminate(v_msg_id, 'EstimateLTC',
                                            get_text(
                                                'begin ltc_bpm_pkg.restart_bpm_process_finish(''%1'',''%2'',:1);%3 end;',
                                                varchar2_table_typ(p_user_id, p_ltc_process_id, p_callback)));

          if v_msg_id is not null
          then -- do not update to NULL if something went wrong with BPM termination
            update ltc_process
            set
              is_syncing     = 1,
              sync_id        = v_msg_id,
              update_user_id = p_user_id
            where id = p_ltc_process_id;
          else
            v_msg_out := 'ERROR. Missing MSG ID after message_pkg.terminate!!!';
          end if;

        elsif v_status_code = 'FIN'
          then
            for r in (select ltc_tag_id
                      from ltc_process
                      where id = p_ltc_process_id) loop
              ltc_sheet_pkg.prefill(r.ltc_tag_id, p_ltc_process_id, null, null, 0);
              ltc_sheet_pkg.recalculate(r.ltc_tag_id, p_ltc_process_id);
            end loop;
            v_msg_out := 'DEBUG. Running prefill and recalculate for finished process.';
        else
          v_msg_out := 'WARNING. Just skip termination, because it is not running.';
        end if;
      else
        v_msg_out := 'ERROR. Missing MSG ID!!!';
      end if;

      log_pkg.steps('END.', v_procedure_start, v_steps_result);
      log_pkg.log(v_where, v_par, v_steps_result || v_msg_out);

      exception when others then
      log_pkg.steps('ERROR.', v_procedure_start, v_steps_result);
      log_pkg.log(v_where, v_par, v_steps_result || v_msg_out);
      notice_pkg.catch(v_where, v_par || v_steps_result || v_msg_out);
      raise;
    end;

  /*************************************************************************/
  procedure restart_bpm_process_finish
    (
      p_user_id        in nvarchar2,
      p_ltc_process_id in number, --ltc_process.id
      p_payload        in xmltype
    )
  as
    v_where           nvarchar2(222) := 'ltc_bpm_pkg.restart_bpm_process_finish';
    v_par             nvarchar2(4000) := 'p_user_id=' || p_user_id || ';p_ltc_process_id=' || p_ltc_process_id;
    v_msg_out         nvarchar2(4000);
    v_step_start      timestamp := systimestamp;
    v_steps_result    nvarchar2(4000);
    v_procedure_start timestamp := systimestamp;

    begin
      log_pkg.steps(null, v_step_start, v_steps_result);

      --validate response
      if message_pkg.is_complete(p_payload) = 0
      then
        return;
      end if;

      --start new process now
      update ltc_process
      set
        is_syncing     = 0,
        update_user_id = p_user_id
      where id = p_ltc_process_id;

      ltc_bpm_pkg.start_bpm_process(p_user_id, p_ltc_process_id, null);

      log_pkg.steps('END.', v_procedure_start, v_steps_result);
      log_pkg.log(v_where, v_par, v_steps_result || v_msg_out);

      exception when others then
      log_pkg.steps('ERROR.', v_procedure_start, v_steps_result);
      log_pkg.log(v_where, v_par, v_steps_result || v_msg_out);
      notice_pkg.catch(v_where, v_par || v_steps_result || v_msg_out);
      raise;
    end;

  /*************************************************************************/
  /*
  */



end;
/