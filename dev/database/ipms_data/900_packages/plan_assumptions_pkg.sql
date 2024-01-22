create or replace package plan_assumptions_pkg as

  /**
   * Initiates planning assumption request.
   * Requires unlocked request in status 'new'.
   * Throws no_data_found exception if requirements unmatched.
   * Asynchronous.
   * Sends execute/estimate message and locks instance.
   */
  procedure starts(p_id in nvarchar2);

  /**
   * Terminates planning assumption request.
   * Requires unlocked request in status 'new','run'
   * Throws no_data_found exception if requirements unmatched.
   * Asynchronous.
   * Sends terminate/estimate message and locks instance.
   */
  procedure stop(p_id in nvarchar2);

  /**
   * Restarts planning assumption request.
   * Requires unlocked request in status 'run'
   * Throws no_data_found exception if requirements unmatched.
   * Asynchronous.
   * Sends terminate/estimate message and locks instance.
   */
  procedure restart(p_id in nvarchar2);

  /**
   * Completes planning assumption request startup.
   * Unlocks instance.
   * Changes status into 'run'.
   * Callback.
   */
  procedure starts_bpm_finish(p_id in nvarchar2, p_payload in xmltype);

  /**
   * Completes planning assumption request termination.
   * Unlocks instance.
   * Changes status into 'fin'.
   * Callback.
   */
  procedure stop_bpm_finish(p_id in nvarchar2, p_payload in xmltype);

  /**
   * Completes planning assumption request restart - starts new request.
   * Unlocks instance.
   * Callback.
   */
  procedure restart_bpm_finish(p_id in nvarchar2, p_payload in xmltype);

  /**
   * Returns summary of planning assumption request.
   */
  function get_summary(p_id in nvarchar2)
    return nvarchar2;

  /**
 * Returns subject of planning assumption.
 */
  function get_subject(p_id in nvarchar2)
    return nvarchar2;

end;
/
create or replace package body plan_assumptions_pkg as

  /*************************************************************************/
  function get_summary(p_id in nvarchar2)
    return nvarchar2 as
    v_request nvarchar2(200);
    begin
      select 'Planning Assumptions Request [' || id || ',' || name || ']'
      into v_request
      from plan_assumption_request
      where id = p_id;

      return v_request;

      exception when no_data_found then
      return 'Planning Assumptions Request [' || nvl(p_id, '-') || ']';
    end;

  /*************************************************************************/
  function get_subject(p_id in nvarchar2)
    return nvarchar2 as
    begin
      return 'assumptions:' || p_id;
    end;

  /*************************************************************************/
  procedure send(p_id in nvarchar2, p_payload in xmltype, p_callback varchar2) as
    msgid   nvarchar2(20);
    subject nvarchar2(50);
    begin
      /* check status */
      select get_subject(par.id)
      into subject
      from plan_assumption_request par
      where par.id = p_id and par.is_syncing = 0;

      /* send request */
      msgid := message_pkg.send(subject, p_payload, p_callback);

      /* mark busy */
      update plan_assumption_request
      set is_syncing = 1, sync_id = msgid
      where id = p_id;
    end;

  /*************************************************************************/
  procedure starts(p_id in nvarchar2)
  as
    v_where nvarchar2(222) := 'plan_assumptions_pkg.starts';
    v_par   nvarchar2(4000) :=
    'p_id=' || p_id;
    begin

      update plan_assumption_request
      set sync_date = sysdate, status_code = 'RUN'
      where id = p_id;

      task_pkg.create_pa(p_id);

      --starts_bpm(p_id); -- Use this line to start real BPM process

      log_pkg.log(v_where, v_par);

      exception when others then
      notice_pkg.catch(v_where, v_par);
      raise;
    end;


  /*************************************************************************/
  procedure starts_bpm(p_id in nvarchar2, p_callback in varchar2 default null) as
    payload xmltype;
    begin
      /* setup the request */
      select message_pkg.xml(
          '<greenList ' || message_pkg.xmlns_ipms_soa || '><processFC id="' || p_id || '" ' || message_pkg.xmlns_ipms ||
          '>' ||
          get_element('name', par.name) ||
          get_element('forecastNumberPeriod', par.forecast_no) ||
          get_element('terminationDate', get_char_date(par.termination_date)) ||
          '</processFC><programs ' || message_pkg.xmlns_ipms || '/></greenList>')
      into payload
      from plan_assumption_request par
      where par.id = p_id and par.status_code in ('NEW', 'RUN');

      --adding directly only unique user role combinatin at virtaual Progfram-D2
      select payload.appendchildxml('//programs', xmltype(
          '<program id="' || id || '" ' || message_pkg.xmlns_ipms || '>' ||
          decode(2, 0, '', get_element('code', code)) ||
          decode(2, 0, '', get_element('name', name)) || '<roles programId="' || id || '"/></program>'
      ), message_pkg.xmlns_ipms)
      into payload
      from program prg
      where code = 'RESERVED-PT-D2-PRJ' or code = 'RESERVED-PT-SAMD';--PROMIS 604

      for rr in (
      select distinct
        user_id,
        role_code
      from user_role ur
      where ur.program_id in (select program_id
                              from project
                              where planning_enabled = 'green'
                              group by program_id
      )
      ) loop
        payload := payload.appendchildxml('//roles', xmltype('<role userId="' || rr.user_id
                                                             || '" roleId="' || utl_i18n.escape_reference(rr.role_code)
                                                             || '" ' || message_pkg.xmlns_ipms || '/>'),
                                          message_pkg.xmlns_ipms);
      end loop;

      /* send request */
      send(p_id, payload,
           get_text('begin plan_assumptions_pkg.starts_bpm_finish(''%1'',:1);%2 end;',
                    varchar2_table_typ(p_id, p_callback)));

      /* change status */
      update plan_assumption_request
      set status_code = 'PLAN'
      where id = p_id;

      notice_pkg.debug(get_subject(p_id), get_summary(p_id) || ' starting.');
      log_pkg.log(get_subject(p_id), get_summary(p_id), 'Starting.');
    end;


  /*************************************************************************/
  procedure stop(p_id in nvarchar2)
  as
    v_where nvarchar2(222) := 'plan_assumptions_pkg.stop';
    v_par   nvarchar2(4000) :=
    'p_id=' || p_id;
    begin

      update plan_assumption_request
      set sync_date = sysdate, status_code = 'FIN'
      where id = p_id;

      task_pkg.REVOKE_PA(p_id);

      -- stop_bpm(p_id); -- Use this line to stop real BPM process

      log_pkg.log(v_where, v_par);

      exception when others then
      notice_pkg.catch(v_where, v_par);
      raise;
    end;

  /*************************************************************************/
  procedure stop_bpm(p_id in nvarchar2, p_callback in varchar2 default null) as
    msg_id plan_assumption_request.sync_id%type;
    begin
      select sync_id
      into msg_id
      from plan_assumption_request
      where id = p_id and status_code in ('RUN', 'NEW');

      msg_id := message_pkg.terminate(msg_id, 'ProvideAssumptions',
                                      get_text('begin plan_assumptions_pkg.stop_bpm_finish(''%1'',:1);%2 end;',
                                               varchar2_table_typ(p_id, p_callback)));

      update plan_assumption_request
      set is_syncing = 1, sync_id = msg_id
      where id = p_id;

      notice_pkg.debug(get_subject(p_id), get_summary(p_id) || ' terminating.');
      log_pkg.log(get_subject(p_id), get_summary(p_id), 'Terminating.');
    end;

  /*************************************************************************/
  procedure restart(p_id in nvarchar2)
  as
    v_where nvarchar2(222) := 'plan_assumptions_pkg.restart';
    v_par   nvarchar2(4000) :=
    'p_id=' || p_id;
    begin


      task_pkg.revoke_pa(p_id);
      task_pkg.create_pa(p_id);

      --restart_bpm(p_id); -- Use this line to restart real BPM process

      log_pkg.log(v_where, v_par);

      exception when others then
      notice_pkg.catch(v_where, v_par);
      raise;
    end;

  /*************************************************************************/
  procedure restart_bpm(p_id in nvarchar2, p_callback in varchar2 default null) as
    msg_id plan_assumption_request.sync_id%type;
    begin
      select sync_id
      into msg_id
      from plan_assumption_request
      where id = p_id and status_code = 'RUN';

      msg_id := message_pkg.terminate(msg_id, 'ProvideAssumptions',
                                      get_text('begin plan_assumptions_pkg.restart_bpm_finish(''%1'',:1);%2 end;',
                                               varchar2_table_typ(p_id, p_callback)));

      update plan_assumption_request
      set is_syncing = 1, sync_id = msg_id
      where id = p_id;

      notice_pkg.debug(get_subject(p_id), get_summary(p_id) || ' restarting.');
    end;

  /*************************************************************************/
  procedure starts_bpm_finish(p_id in nvarchar2, p_payload in xmltype) as
    begin
      /* validate result */
      if message_pkg.is_accept(p_payload) = 1
      then
        /* process started, setup data */
        update plan_assumption_request
        set sync_date = sysdate, is_syncing = 0, status_code = 'RUN'
        where id = p_id;

        /* notify */
        notice_pkg.information(get_subject(p_id), get_summary(p_id) || ' started.');
      elsif message_pkg.is_complete(p_payload) = 1
        then
          /* process completed immediatelly afer startup */
          update plan_assumption_request
          set sync_date = sysdate, is_syncing = 0, status_code = 'FIN'
          where id = p_id;

          /* notify */
          notice_pkg.information(get_subject(p_id), get_summary(p_id) || ' finished.');
      end if;
    end;

  /*************************************************************************/
  procedure stop_bpm_finish(p_id in nvarchar2, p_payload in xmltype) as
    begin
      /* validate response */
      if message_pkg.is_complete(p_payload) = 0
      then
        return;
      end if;

      /* update data */
      update plan_assumption_request
      set sync_date = sysdate, is_syncing = 0, status_code = 'FIN'
      where id = p_id;

      /* notify */
      notice_pkg.information(get_subject(p_id), get_summary(p_id) || ' terminated.');
    end;

  /*************************************************************************/
  procedure restart_bpm_finish(p_id in nvarchar2, p_payload in xmltype) as
    begin
      /* validate response */
      if message_pkg.is_complete(p_payload) = 0
      then
        return;
      end if;

      /* start new process now */
      update plan_assumption_request
      set is_syncing = 0
      where id = p_id;
      starts_bpm(p_id);
    end;

end;
/