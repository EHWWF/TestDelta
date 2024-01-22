create or replace package generic_timelines_pkg as

  /**
   * Returns most specific duration for specified phase.
   */
  function get_phase_duration(p_sbe in nvarchar2, p_ds_type in nvarchar2, p_phase in nvarchar2) return number;

  /**
   * Returns true if milestones are in the sequence else false.
   */
  function is_milestones_in_sequence(p_id in nvarchar2, p_timeline_type in nvarchar2 default 'CUR') return number;

  /**
   * Returns true if generic timeline calculation is possible else false.
   * Note that is_generic_timeline_possible and calculate_generic_timelines must have the same conditions
   * for filtering out projects
   */
  function is_generic_timeline_possible(p_id in nvarchar2, p_timeline_type in nvarchar2) return number;

  /**
   * Calculates generic timelines and stores them into GENERIC_TIMELINE table for the specified project
   */
  procedure calculate_generic_timeline(p_id in nvarchar2);

  /**
   * Calculates generic timelines and stores them into GENERIC_TIMELINE table for all projects
   * Note that is_generic_timeline_possible and calculate_generic_timelines must have the same conditions
   * for filtering out projects
   */
  procedure calculate_generic_timelines;

end;
/
create or replace package body generic_timelines_pkg
as

  /*************************************************************************/
  function get_phase_duration(p_sbe in nvarchar2, p_ds_type in nvarchar2, p_phase in nvarchar2) return number
  as
    v_duration number(10,0);
  begin
    select duration into v_duration
	from (
		select duration
		from phase_duration
		where (sbe_code = p_sbe or sbe_code is null)
		and (substance_type_code = p_ds_type or substance_type_code is null)
		and phase_code = p_phase
		order by sbe_code, substance_type_code
    ) where rownum < 2;

    return v_duration;

  exception when no_data_found then
    return 0;
  end;

  /*************************************************************************/
  function is_milestones_in_sequence(p_id in nvarchar2, p_timeline_type in nvarchar2 default 'CUR') return number
  as
    v_previous_date date := null;
  begin
    -- iterate through milestones and check if actual and planned dates are in sequence
    for milestone in (
      select
        pm.phase_code,
		pm.milestone_code,
		tm.actual_date,
		tm.plan_date
      from phase ph
      join phase_milestone pm on ph.code = pm.phase_code and pm.category = 'GT'
      join project p on p.id = p_id
      join project_area_milestone pam on pam.milestone_code = pm.milestone_code and pam.area_code = p.area_code
      left outer join milestone_vw tm on pm.milestone_code = tm.milestone_code
       and tm.timeline_type_code = p_timeline_type and tm.project_id = p.id
      order by ph.ordering
    ) loop
      if milestone.actual_date is not null then
        if v_previous_date is not null then
          if trunc(milestone.actual_date) < v_previous_date then
            return 0;
          end if;
        end if;
        v_previous_date := trunc(milestone.actual_date);
      else
        if milestone.plan_date is not null then
          if v_previous_date is not null then
            if trunc(milestone.plan_date) < v_previous_date then
              return 0;
            end if;
          end if;
          v_previous_date := trunc(milestone.plan_date);
        end if;
      end if;
    end loop;

    return 1;

  end;

  /*************************************************************************/
  function is_generic_timeline_possible(p_id in nvarchar2, p_timeline_type in nvarchar2) return number
  as
      v_project_rec project%rowtype;
  begin

    --Note that calculate_generic_timelines must have the same conditions for filtering out projects
    select * into v_project_rec from project where id = p_id;

    if v_project_rec.area_code is null or
		(
			v_project_rec.area_code != 'PRE-POT' and
			v_project_rec.area_code != 'POST-POT' and
			v_project_rec.area_code != 'D2-PRJ' and
			v_project_rec.area_code != 'D3-TR' and
            v_project_rec.area_code != 'SAMD'-- PROMIS 604
		) then
      return 0;
    end if;

    if v_project_rec.state_code in (6, 10) then
      return 0;
    end if;

    if nvl(v_project_rec.sbe_code,v_project_rec.proposed_sbe_code) is null or v_project_rec.substance_type_code is null then
      return 0;
    end if;

    if generic_timelines_pkg.is_milestones_in_sequence(p_id, p_timeline_type) = 0 then
      return 0;
    end if;

    return 1;

  end;

  /*************************************************************************/
	procedure calculate_generic_timeline(p_id in nvarchar2)
	as
		v_project_rec project%rowtype;
		v_source_pid nvarchar2(20);
		v_current_phase phase.code%type;
		v_prev_phase phase.code%type;
		v_milestone_code nvarchar2(10);
		v_sbe_code nvarchar2(10);
		v_count number;
		v_phase_start number := -1;
		v_gap_start number;
		v_gap_start_date date;
		v_factor number := 1.0;
		v_forward_factor number := 1.0;
		v_date date;
		v_duration number;
		v_no_milestones number := 1;
		v_timeline_type nvarchar2(3) := 'CUR';

		v_where nvarchar2(222) := 'generic_timelines_pkg.calculate_generic_timeline';
		v_par nvarchar2(4000) := 'p_id='||p_id;
		v_rowcount number := 0;
		v_step_start timestamp := systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp := systimestamp;
		v_msg_out nvarchar2(4000);

    begin

		log_pkg.steps(null, v_step_start, v_steps_result);

		select * into v_project_rec from project where id = p_id;
		v_sbe_code := nvl(v_project_rec.sbe_code,v_project_rec.proposed_sbe_code);

      --v_rowcount := sql%rowcount;
		log_pkg.steps('a',v_step_start,v_steps_result);

		-- Use RAW plan if no CUR plan is available, Project Area = PRE-POT|POST-POT|D2-PRJ, Project Status = prepared and Project is inactive
		if
			(
				v_project_rec.area_code = 'PRE-POT' or
				v_project_rec.area_code = 'POST-POT' or
				v_project_rec.area_code = 'D2-PRJ'
                or v_project_rec.area_code = 'SAMD' --PROMIS 604
			)
			and v_project_rec.state_code = 0
			and v_project_rec.is_active = 0
		then
		  select nvl(tm.type_code,'RAW') into v_timeline_type
		  from project p
		  left outer join (
							select
								project_id,
								decode(type_code, 'CUR', 'CUR', 'RAW') type_code,
								decode(type_code, 'CUR', 1, 2) type_rank
							from timeline
							order by type_rank
						) tm on tm.project_id = p.id
		  where p.id = p_id
		  and rownum < 2
		  ;
		end if;

		-- Update GT calculation date to avoid taking the same project as one with the oldest GT calculation date
		update project set
			gt_calculation_date = sysdate,
			gt_timeline_type = v_timeline_type
		where id = p_id;

		if generic_timelines_pkg.is_generic_timeline_possible(p_id, v_timeline_type) = 0 then
		  return;
		end if;

      --v_rowcount := sql%rowcount;
      log_pkg.steps('b',v_step_start,v_steps_result);

		-- Development project category is NI
		if v_project_rec.category_code = 'NI' and (v_project_rec.area_code = 'PRE-POT' or v_project_rec.area_code = 'POST-POT') then
		  begin
			select id into v_source_pid
			from (
			  select p1.id
			  from project p1, project p2
			  where p2.id = v_project_rec.id
			  and p1.program_id=p2.program_id
			  and p1.category_code = 'NM'
			  order by p1.gt_calculation_date
			) where rownum<2;

			delete from generic_timeline where project_id = v_project_rec.id;

			insert into generic_timeline(project_id, milestone_code, generic_date)
			select v_project_rec.id, milestone_code, generic_date
			from generic_timeline
			where project_id = v_source_pid;

			return;

		  exception
			when no_data_found then
			  notice_pkg.debug('calculate_generic_timeline', timeline_pkg.get_summary(v_project_rec.id) || ' No NM project is found for the NI project');
		  end;
		end if;

		log_pkg.steps('c',v_step_start,v_steps_result);

		-- Check that required milestone is given if project has no current phase
		if v_project_rec.phase_code is null then
		  v_current_phase := '9'; --n/a (pre D2/D3 based on project type)

		  v_milestone_code:= null;
		  if v_project_rec.area_code = 'D2-PRJ' then
			-- D2 project: D2 date has to be provided
			v_milestone_code:= 'D2';
		  end if;

		  if v_project_rec.area_code = 'D3-TR' then
			-- D3 Transition project: PCC date has to be provided
			v_milestone_code:= 'PCC';
		  end if;

		  if v_milestone_code is not null then
			-- Check if required milestone is specified for D2 or D3 transition project
			select count(*) into v_count
			from milestone_vw tm
			where tm.timeline_type_code = v_timeline_type
			and tm.milestone_code = v_milestone_code
			and tm.project_id = v_project_rec.id
			and (tm.actual_date is not null or tm.plan_date is not null);

			if v_count = 0 then
			  return;
			end if;
		  else
			-- Check if at least one milestone is specified for development project
			select count(*) into v_count
			from milestone_vw tm, project p, project_area_milestone pam
			where tm.timeline_type_code = v_timeline_type
			and tm.milestone_code = pam.milestone_code
			and pam.area_code = p.area_code
			and tm.project_id = p.id
			and p.id = v_project_rec.id
			and (tm.actual_date is not null or tm.plan_date is not null);

			if v_count = 0 then
			  return;
			end if;

		  end if;
		else
		  v_current_phase := v_project_rec.phase_code;
		  -- check if current phase is longer than configured
		  v_duration := generic_timelines_pkg.get_phase_duration(v_sbe_code, v_project_rec.substance_type_code, v_project_rec.phase_code);

		  select case when nvl(sum(milestone_date),0)>0 then 1.5
				 else 1.0 end into v_forward_factor
		  from (
			select rownum, code, name, id, milestone_code,
			  decode(rownum,
				1, -TO_NUMBER(nvl(TO_CHAR(add_months(milestone_date, v_duration),'YYYYMMDD'),99999999)),
				2, TO_NUMBER(nvl(TO_CHAR(milestone_date,'YYYYMMDD'),0))) milestone_date from (
			  select ph.code, ph.name, p.id, pm.milestone_code, tm.milestone_date from phase ph
			  join phase_milestone pm on pm.phase_code=ph.code and pm.category = 'GT'
			  join project p on p.id = v_project_rec.id
			  join project_area_milestone pam on pam.area_code = p.area_code and pam.milestone_code = pm.milestone_code
			  left outer join milestone_vw tm on tm.project_id = p.id and tm.timeline_type_code = v_timeline_type and tm.milestone_code = pm.milestone_code
			  where ph.ordering >= (select ph2.ordering from phase ph2 where ph2.code = v_project_rec.phase_code)
			  order by ph.ordering
			) where rownum <= 2
		  );

		end if;

		log_pkg.steps('d',v_step_start,v_steps_result);

		-- Project is in Launch phase
		if v_current_phase = '7' then
		  return;
		end if;

		-- Retrieve order of current phase
		select nvl(ordering,-1) into v_phase_start from phase where code = v_current_phase;

		-- Project is on hold or terminated
		if v_project_rec.state_code in (2, 5) then
		  -- Remove existing future decision dates
		  delete from generic_timeline
		  where project_id = v_project_rec.id
		  and milestone_code in (
			select pm.milestone_code
			from phase_milestone pm
			join phase ph on ph.code = pm.phase_code
			join project_area_milestone pam on pam.milestone_code = pm.milestone_code and pam.area_code = v_project_rec.area_code
			where ph.ordering > v_phase_start
			and pm.category = 'GT'
		  );
		  return;
		end if;

		-- Delete generic timeline for the current project
		delete from generic_timeline where project_id = v_project_rec.id;
		v_rowcount := sql%rowcount;
		log_pkg.steps('e'||v_rowcount,v_step_start,v_steps_result);

		v_gap_start := -1;
		-- Get milestones with dates and phase duration for the current project
		for v_milestone in (
		  select
			ph.ordering,
			ph.name ph_name,
			generic_timelines_pkg.get_phase_duration(v_sbe_code, v_project_rec.substance_type_code, pm.phase_code) ph_duration,
			pm.phase_code,
			pm.milestone_code,
			nvl(tm.actual_date, tm.plan_date) milestone_date
		  from milestone_vw tm
		  join phase_milestone pm on pm.milestone_code = tm.milestone_code and pm.category = 'GT'
		  join project_area_milestone pam on pam.milestone_code = pm.milestone_code and pam.area_code = v_project_rec.area_code
		  join phase ph on ph.code = pm.phase_code
		  where tm.timeline_type_code = v_timeline_type
		  and tm.project_id = v_project_rec.id
		  and (tm.actual_date is not null or tm.plan_date is not null)
		  order by ph.ordering
		) loop
		  v_factor := 1.0;
		  if v_gap_start > -1 then
			-- Gap detected: calculate duration factor real vs configured for it
			select sum(generic_timelines_pkg.get_phase_duration(v_sbe_code, v_project_rec.substance_type_code, pm.phase_code)) into v_duration
			from phase_milestone pm
			join project_area_milestone pam on pam.milestone_code = pm.milestone_code and pam.area_code = v_project_rec.area_code
			left outer join milestone_vw tm on pm.milestone_code = tm.milestone_code and tm.timeline_type_code = v_timeline_type and tm.project_id = v_project_rec.id
			join phase ph on ph.code = pm.phase_code and ph.ordering >= v_gap_start and ph.ordering < v_milestone.ordering
			where pm.category = 'GT';

			if v_duration > 1 then
			  v_factor := months_between(v_milestone.milestone_date,v_gap_start_date) / v_duration;
			end if;
		  end if;

		  v_date := v_milestone.milestone_date;
		  -- do backward calculation either from first or subsequent milestone
		  for v_empty_milestone in (
			select pm.phase_code, pm.milestone_code, ph.ordering, generic_timelines_pkg.get_phase_duration(v_sbe_code, v_project_rec.substance_type_code, pm.phase_code) ph_duration
			from phase_milestone pm
			join project_area_milestone pam on pam.milestone_code = pm.milestone_code and pam.area_code = v_project_rec.area_code
			left outer join milestone_vw tm on pm.milestone_code = tm.milestone_code and tm.timeline_type_code = v_timeline_type and tm.project_id = v_project_rec.id
			join phase ph on ph.code = pm.phase_code and ph.ordering > v_gap_start and ph.ordering < v_milestone.ordering
			where pm.category = 'GT' order by ph.ordering desc
		  ) loop

			v_date := add_months(v_date, -(v_factor * v_empty_milestone.ph_duration));
			if v_empty_milestone.ordering >= v_phase_start then
			  insert into generic_timeline(project_id, milestone_code, generic_date)
			  VALUES(v_project_rec.id, v_empty_milestone.milestone_code, v_date);
			end if;
		  end loop;

		  v_gap_start := v_milestone.ordering;
		  v_gap_start_date := v_milestone.milestone_date;
		  v_prev_phase := v_milestone.phase_code;
		  v_no_milestones := 0;
		end loop;

      --v_rowcount := sql%rowcount;
		log_pkg.steps('f',v_step_start,v_steps_result);

		if v_no_milestones = 1 then
		  -- No milestones: calculate start date from the current phase if available
		  -- start date of the current phase is calculated assuming that current date is middle of the phase
		  v_gap_start_date := add_months(sysdate, -generic_timelines_pkg.get_phase_duration(v_sbe_code, v_project_rec.substance_type_code, v_current_phase)/2);

		  -- map current phase to milestone
		  begin
			select pm.milestone_code, ph.ordering into v_milestone_code, v_gap_start
			from phase ph
			join phase_milestone pm on ph.code=pm.phase_code and pm.category='GT'
			join project_area_milestone pam on pam.milestone_code = pm.milestone_code and pam.area_code = v_project_rec.area_code
			where ph.code=v_current_phase;
		  exception when no_data_found then
			--dbms_output.put_line('  Impossible to map current phase ' || v_current_phase || ' to project related milestone.');
			return;
		  end;

		  --dbms_output.put_line('  insertGT pid=' || v_project_rec.id || ' mc=' || v_milestone_code || ' date=' || v_gap_start_date);
		  insert into generic_timeline(project_id, milestone_code, generic_date) VALUES(v_project_rec.id, v_milestone_code, v_gap_start_date);
		  v_prev_phase := v_current_phase;

		  v_date := v_gap_start_date;
		  -- do backward calculation from derived milestone
		  for v_empty_milestone in (
			select pm.phase_code, pm.milestone_code, ph.ordering, generic_timelines_pkg.get_phase_duration(v_sbe_code, v_project_rec.substance_type_code, pm.phase_code) ph_duration
			from phase_milestone pm
			join project_area_milestone pam on pam.milestone_code = pm.milestone_code and pam.area_code = v_project_rec.area_code
			left outer join milestone_vw tm on pm.milestone_code = tm.milestone_code and tm.timeline_type_code = v_timeline_type and tm.project_id = v_project_rec.id
			join phase ph on ph.code = pm.phase_code and ph.ordering > -1 and ph.ordering < v_gap_start
			where pm.category = 'GT'
			order by ph.ordering desc
		  ) loop

			v_date := add_months(v_date, -v_empty_milestone.ph_duration);
			if v_empty_milestone.ordering >= v_phase_start then
			  --dbms_output.put_line('  insertGT pid=' || v_project_rec.id || ' mc=' || v_empty_milestone.milestone_code || ' date=' || v_date);
			  insert into generic_timeline(project_id, milestone_code, generic_date)
			  VALUES(v_project_rec.id, v_empty_milestone.milestone_code, v_date);
			end if;
		  end loop;

		end if;

      --v_rowcount := sql%rowcount;
		log_pkg.steps('g',v_step_start,v_steps_result);

		-- do forward calculation from last or derived milestone
		v_date := v_gap_start_date;

		for v_empty_milestone in (
		  select pm.phase_code, pm.milestone_code, ph.ordering
		  from phase_milestone pm
		  join project_area_milestone pam on pam.milestone_code = pm.milestone_code and pam.area_code = v_project_rec.area_code
		  left outer join milestone_vw tm on pm.milestone_code = tm.milestone_code and tm.timeline_type_code = v_timeline_type and tm.project_id = v_project_rec.id
		  join phase ph on ph.code = pm.phase_code and ph.ordering > v_gap_start
		  where pm.category = 'GT'
		  order by ph.ordering
		) loop
		  v_duration := generic_timelines_pkg.get_phase_duration(v_sbe_code, v_project_rec.substance_type_code, v_prev_phase);
		  v_prev_phase := v_empty_milestone.phase_code;
		  v_date := add_months(v_date, v_forward_factor * v_duration);
		  if v_empty_milestone.ordering >= v_phase_start then
			--dbms_output.put_line('  insertGT pid=' || v_project_rec.id || ' mc=' || v_empty_milestone.milestone_code || ' date=' || v_date);
			insert into generic_timeline(project_id, milestone_code, generic_date)
			VALUES(v_project_rec.id, v_empty_milestone.milestone_code, v_date);
		  end if;
		end loop;

      log_pkg.steps('END.', v_procedure_start, v_steps_result);
      log_pkg.log(v_where, v_par, v_steps_result || v_msg_out);

	exception when others then
      log_pkg.steps('ERROR.', v_procedure_start, v_steps_result);
      log_pkg.log(v_where, v_par, v_steps_result || v_msg_out);
      notice_pkg.catch(v_where, v_par || v_steps_result || v_msg_out);
      raise;
    end;

  /*************************************************************************/
  procedure calculate_generic_timelines
  as
    v_count number := 0;
    v_failed number := 0;
  begin
    for project_rec in (
		--Note that is_generic_timeline_possible must have the same conditions for filtering out projects
		select p.id
		from project p
		where p.area_code is not null
		and p.state_code not in (6, 10)
		and
			(
				p.area_code = 'PRE-POT' or
				p.area_code = 'POST-POT' or
				p.area_code = 'D2-PRJ' or
				p.area_code = 'D3-TR' or
                p.area_code = 'SAMD'--PROMIS 604
			)
		and nvl(p.sbe_code,p.proposed_sbe_code) is not null
		and p.substance_type_code is not null
    )
	loop
      v_count := v_count + 1;
      begin
        generic_timelines_pkg.calculate_generic_timeline(project_rec.id);
      exception when others then
        v_failed := v_failed + 1;
      end;
    end loop;

    if v_failed != 0 then
      log_pkg.log('calculate_generic_timelines', 'Recalculation of generic timelines from CUR plans due to configuration changes', 'Failed for ' || v_failed || ' from ' || v_count || ' project(s)');
    else
      log_pkg.log('calculate_generic_timelines', 'Recalculation of generic timelines from CUR plans due to configuration changes', 'Finished without errors for '|| v_count ||' project(s)');
    end if;

  end;

end;
/