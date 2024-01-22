create or replace package task_pkg
as
  /*************************************************************************/

/*
* Creates tasks to provide latest estimates values
 */
  procedure create_le(p_lep_id in nvarchar2);
  /*
* Revokes tasks to provide latest estimates values
 */
  procedure revoke_le(p_lep_id in nvarchar2);

  /*
* Creates tasks to provide long term cost estimates values
 */
  procedure create_ltc(p_ltcpc_id in nvarchar2);
  /*
* Revokes tasks to provide long term cost estimates values
 */
  procedure revoke_ltc(p_ltcpc_id in nvarchar2);

  /*
* Creates tasks to provide planning assumtions
 */
  procedure create_pa(p_pa_id in nvarchar2);
  /*
* Revokes tasks to provide planning assumtions
 */
  procedure revoke_pa(p_pa_id in nvarchar2);

  /*
* Creates task to assign project ID
 */
  procedure create_aid(p_id in nvarchar2);
  /*
  * Revokes task to assign project ID
   */
  procedure revoke_aid(p_id in nvarchar2);

end;
/
create or replace package body task_pkg
as

  procedure create_le(p_lep_id in nvarchar2) as
    begin

      insert into task (task_number, title, definition_name, state, task_created_date, process_id, program_id)
        select
          min('LE-' || lepr.process_id || '-' || prg.id) as                                     task_number,
          'Provide Latest Estimates (' || let.name || '-' || lep.name || '-' || prg.name || ')' title,
          'ProvideLatestEstimates1'                                                             definition_name,
          'ASSIGNED'                                                                            state,
          sysdate                                                                               task_created_date,
          lepr.process_id                                as                                     process_id,
          prg.id                                         as                                     program_id

        from
          latest_estimates_project lepr
          join project prj on prj.id = lepr.project_id
          join program prg on prg.id = prj.program_id
          join latest_estimates_process lep on lep.id = lepr.process_id
          join latest_estimates_tag let on let.id = lep.let_id
        where
          lepr.process_id = p_lep_id
        group by let.name, lep.name, lepr.process_id, prg.id, prg.name;
    end;

  procedure revoke_le(p_lep_id in nvarchar2) as
    begin

      update task
      set state = 'COMPLETED'
      where definition_name = 'ProvideLatestEstimates1' and process_id = p_lep_id and state='ASSIGNED';

    end;


  procedure create_ltc(p_ltcpc_id in nvarchar2) as
    begin

      insert into task (task_number, title, definition_name, state, task_created_date, process_id, program_id)
        select
          min('LTC-' || ltcp.ltc_process_id || '-' || prg.id) as                              task_number,
          'Provide LTC (' || ltct.name || '-' || ltcpc.name || '-' || prg.name || ')' title,
          'ProvideLTC'                                                                        definition_name,
          'ASSIGNED'                                                                          state,
          sysdate                                                                             task_created_date,
          ltcp.ltc_process_id                                 as                              process_id,
          prg.id                                              as                              program_id

        from
          ltc_project ltcp
          join project prj on prj.id = ltcp.project_id
          join program prg on prg.id = prj.program_id
          join ltc_process ltcpc on ltcpc.id = ltcp.ltc_process_id
          join ltc_tag ltct on ltct.id = ltcpc.ltc_tag_id
        where
          ltcp.ltc_process_id = p_ltcpc_id
        group by ltct.name, ltcpc.name, ltcp.ltc_process_id, prg.id, prg.name;
    end;

  procedure revoke_ltc(p_ltcpc_id in nvarchar2) as
    begin

      update task
      set state = 'COMPLETED'
      where definition_name = 'ProvideLTC' and process_id = p_ltcpc_id and state='ASSIGNED';

    end;

  procedure create_pa(p_pa_id in nvarchar2) as
    begin

      insert into task (task_number, title, definition_name, state, task_created_date, assumption_request_id)
        select
          'PA-' || pa.id as         task_number,
          'Provide Planning Assumptions' title,
          'ProvidePlanningAssumptions'   definition_name,
          'ASSIGNED'                     state,
          sysdate                        task_created_date,
          pa.id                          assumption_request_id
        from
          plan_assumption_request pa
        where
          pa.id = p_pa_id;
    end;

  procedure revoke_pa(p_pa_id in nvarchar2) as
    begin

      update task
      set state = 'COMPLETED'
      where definition_name = 'ProvidePlanningAssumptions' and assumption_request_id = p_pa_id and state='ASSIGNED';

    end;

  procedure create_aid(p_id in nvarchar2) as
    begin

      insert into task (task_number, title, definition_name, state, task_created_date, project_id)
        select
          'AID-' || prj.id as         task_number,
          'Assign Project ID ('||prj.name||')' title,
          'AssignProjectID'   definition_name,
          'ASSIGNED'                     state,
          sysdate                        task_created_date,
          prj.id                          project_id
        from
          project prj
        where
          prj.id = p_id;
    end;

  procedure revoke_aid(p_id in nvarchar2) as
    begin

      update task
      set state = 'COMPLETED'
      where definition_name = 'AssignProjectID' and assumption_request_id = p_id and state='ASSIGNED';

    end;

end;
/