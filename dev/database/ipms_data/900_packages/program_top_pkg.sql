create or replace package program_top_pkg
as
	/**
	* Create Program TOP version based on current TOP and it's values
	*/
	procedure create_version
	(
		p_program_id in varchar2 default null,
		p_name in varchar2 default null,
		p_approval_date in varchar2 default null,
		p_description in varchar2 default null,
		p_project_id in varchar2 default null
	)
	;
	/**
	* Copy Program TOP version to current TOP
	*/
	procedure copy_version_to_current
	(
		p_src_id in number default null,
		p_diff_target_program_id in varchar2 default null --if copy action must be done to diff Program than target program id must be provided
	)
	;
	/**
	* Add missing subcategory code if it was added later to the current TOP
	*/
	procedure add_missing_sub
	(
		p_program_version_id in number
	)
	;
	/**
	* Add missing subcategory code if it was added later to the ALL current TOP versions
	*/
	procedure add_missing_sub_all
	(
		p_subcategory_code in varchar2
	)
	;
	/**
	* Return URL for creating PDF report based on provided parameters
	*/
	function get_pdf_export
	(
		p_project_id in varchar2 default null,
		p_program_id in varchar2 default null,
		p_version in varchar2 default null
	) return varchar2
	;
end;
/
create or replace package body program_top_pkg
as
	/*************************************************************************/
	procedure add_missing_sub_all
	(
		p_subcategory_code in varchar2
	)
	as
		v_where nvarchar2(222) := 'program_top_pkg.add_missing_sub_all';
		v_par nvarchar2(4000) := 'p_subcategory_code=' || p_subcategory_code;
		v_step_start timestamp := systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp := systimestamp;
		v_msg_out nvarchar2(4000);
		v_rowcount number := 0;
	begin
		log_pkg.steps(null, v_step_start, v_steps_result);

		for rr in (
				  select vall.program_version_id
				  from program_top_value vall
				  join program_top_version verr on (verr.id=vall.program_version_id)
				  where verr.version = 'current'
				  group by vall.program_version_id
				  order by 1
				  )
		loop
			if p_subcategory_code is not null then --then do only for one concrete subcategory
				begin
				  insert into program_top_value
				  (
						program_version_id,
						subcategory_code
				  )
				  values
				  (
						rr.program_version_id,
						p_subcategory_code
				  );
				  v_rowcount := v_rowcount + 1;

				exception when others then
				  notice_pkg.catch(v_where, v_par || v_steps_result || 'INSERT;'||v_rowcount);
				end;
			else
				add_missing_sub(rr.program_version_id);
			end if;
			v_rowcount := v_rowcount + 1;
		end loop;

		log_pkg.steps('END', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result || v_msg_out || v_rowcount);

	exception when others then
		log_pkg.steps('ERROR', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result || v_msg_out||v_rowcount);
		notice_pkg.catch(v_where, v_par || v_steps_result || v_msg_out||v_rowcount);
		raise;
	end;

	/*************************************************************************/
	procedure add_missing_sub
	(
		p_program_version_id in number
	)
	as
		v_where nvarchar2(222) := 'program_top_pkg.add_missing_sub';
		v_par nvarchar2(4000) := 'p_program_version_id=' || p_program_version_id;
		v_step_start timestamp := systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp := systimestamp;
		v_msg_out nvarchar2(4000);
		v_rowcount number := 0;
    v_version varchar2(99);
	begin
		log_pkg.steps(null, v_step_start, v_steps_result);

    select version into v_version 
		from program_top_version
    where id = p_program_version_id;

    if v_version = 'current' then -- we can add new positions only to current
      for rr in (
            select code
            from program_top_subcategory
            where is_active=1
              minus
            select subcategory_code as code
            from program_top_value
            where program_version_id = p_program_version_id
            )
      loop
        begin
					insert into program_top_value
					(
						program_version_id,
						subcategory_code
					)
					values
					(
						p_program_version_id,
						rr.code
					);
					v_rowcount := v_rowcount + 1;

        exception when others then
					notice_pkg.catch(v_where, v_par || v_steps_result || 'INSERT;'||v_rowcount);
        end;
      end loop;
    end if;

		log_pkg.steps('END', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result || v_msg_out || v_rowcount);

	exception when others then
		log_pkg.steps('ERROR', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result || v_msg_out||v_rowcount);
		notice_pkg.catch(v_where, v_par || v_steps_result || v_msg_out||v_rowcount);
		raise;
	end;

	/*************************************************************************/
	function get_max_version(p_program_id in nvarchar2, p_project_id in nvarchar2) return number
	as
		v_version number :=0;
	begin
		--select count(1) into v_version --NOT +1 because it starts from 0
		if p_project_id is not null then
			select max(version_nr)+1 into v_version --MAX because deletion can happen
			from program_top_version
			where project_id = p_project_id;
		else
			select max(version_nr)+1 into v_version --MAX because deletion can happen
			from program_top_version
			where program_id = p_program_id;
		end if;

		return v_version;
	exception when others then
		return null;
	end;

	/*************************************************************************/
	procedure create_version
	(
		p_program_id in varchar2 default null,
		p_name in varchar2 default null,
		p_approval_date in varchar2 default null,
		p_description in varchar2 default null,
		p_project_id in varchar2 default null
	)
	as
		v_where nvarchar2(222) := 'program_top_pkg.create_version';
		v_par nvarchar2(4000) := 'p_program_id=' || p_program_id ||
                            ';p_project_id=' ||p_project_id ||
														';p_name=' || p_name ||
                            ';p_approval_date=' || p_approval_date ||
                            ';p_description=' || p_description;
		v_step_start timestamp := systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp := systimestamp;
		v_msg_out nvarchar2(4000);
		v_rowcount number;
		v_new_id nvarchar2(20);
		v_curr_id nvarchar2(20);
    v_version_nr number:=0;
		
	begin
		log_pkg.steps(null, v_step_start, v_steps_result);

		begin
			if p_project_id is not null then
				select id into v_curr_id
				from program_top_version
				where project_id = p_project_id
				and version = 'current'; --only one can be current		
			else
				select id into v_curr_id
				from program_top_version
				where program_id = p_program_id
				and version = 'current'; --only one can be current
			end if;

		exception when others then
		  v_curr_id := null;
		end;

		v_msg_out := v_msg_out || ';v_curr_id=' || v_curr_id;
		log_pkg.steps('a', v_step_start, v_steps_result);

    if v_curr_id is not null then
      v_version_nr := get_max_version(p_program_id, p_project_id);
    end if;

		--insert new tpp version
		insert into program_top_version
		(
			program_id,
			project_id,
			name,
			version,
			approval_date,
			description,
			parent_id,
			version_nr
		)
		values
		(
			p_program_id,
			p_project_id,
			nvl(p_name,'version name'),
			decode(v_curr_id,null,'current','previous'),--means it is the very first insert for this program
			p_approval_date,
			p_description,
			v_curr_id,
			decode(v_curr_id,null,0,v_version_nr)--current always must be 0
		)
		returning id into v_new_id;

		v_msg_out := v_msg_out || ';v_new_id=' || v_new_id;
		log_pkg.steps('b', v_step_start, v_steps_result);

		-- copy over tpp values from current into new tpp version
		if v_curr_id is not null and v_new_id is not null then
		  insert into program_top_value
			(
			  program_version_id,
			  subcategory_code,
			  indication1,
			  indication2,
			  indication3,
			  indication4,
			  indication5,
			  indication6,
			  indication7,
			  indication8
			)
			select
			  v_new_id,
			  subcategory_code,
			  indication1,
			  indication2,
			  indication3,
			  indication4,
			  indication5,
			  indication6,
			  indication7,
			  indication8
			from program_top_value
			where program_version_id = v_curr_id;

			v_rowcount := sql%rowcount;
			log_pkg.steps('c' || v_rowcount, v_step_start, v_steps_result);
		end if;

		if v_new_id is not null then
		  add_missing_sub(v_new_id);
		end if;

		log_pkg.steps('END', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result || v_msg_out);

	exception when others then
		log_pkg.steps('ERROR', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result || v_msg_out);
		notice_pkg.catch(v_where, v_par || v_steps_result || v_msg_out);
		raise;
	end;

	/*************************************************************************/
	procedure copy_version_to_current
	(
		p_src_id in number default null,
		p_diff_target_program_id in varchar2 default null --if copy action must be done to diff Program than target program id must be provided
	)
	as
		v_where nvarchar2(222) := 'program_top_pkg.copy_version_to_current';
		v_par nvarchar2(4000) := 'p_src_id=' || p_src_id||';p_diff_target_program_id='||p_diff_target_program_id;
		v_step_start timestamp := systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp := systimestamp;
		v_msg_out nvarchar2(4000);
		v_rowcount number;
		v_new_id number;
		v_version_nr number :=0;
		v_progam_id nvarchar2(99);
		v_project_id nvarchar2(99);
	begin
		log_pkg.steps(null, v_step_start, v_steps_result);

		--get program_id needed in the next steps
		select program_id, project_id into v_progam_id, v_project_id
		from program_top_version
		where id = p_src_id;
	
		--because of unique index, only one current version is possible,
		--thus, in this case, delete current because new current will be created soon
		if p_diff_target_program_id is null then
			if v_project_id is not null then
				delete program_top_version
				where project_id = v_project_id
				and version = 'current';		
			else
				delete program_top_version
				where program_id = v_progam_id
				and version = 'current';
			end if;
		end if;

		log_pkg.steps('a', v_step_start, v_steps_result);
		-- Insert new masterdata for current TPP version
		--insert new tpp version
		select program_top_v_id_seq.nextval into v_new_id from dual;
		--v_version_nr := get_max_version(v_progam_id);

		insert into program_top_version
		(
			id,
			program_id,
			project_id,
			name,
			version,
			approval_date,
			description,
			parent_id,
			version_nr
		)
		select
			v_new_id,
			nvl(p_diff_target_program_id,program_id),
			decode(p_diff_target_program_id,null,project_id,null),
			name,
			'current',
			approval_date,
			description,
			decode(p_diff_target_program_id,null,p_src_id,null),
			0--it is new current, NO version nr
		from program_top_version
		where id = p_src_id
		;

		v_msg_out := v_msg_out || ';v_new_id=' || v_new_id||';v_version_nr='||v_version_nr||';v_progam_id='||v_progam_id||';v_project_id='||v_project_id;
		log_pkg.steps('b', v_step_start, v_steps_result);

		-- copy over source values from current into new current version
		if v_new_id is not null and p_src_id is not null then
		  insert into program_top_value
			(
			  program_version_id,
			  subcategory_code,
			  indication1,
			  indication2,
			  indication3,
			  indication4,
			  indication5,
			  indication6,
			  indication7,
			  indication8
			)
			select
			  v_new_id,
			  subcategory_code,
			  indication1,
			  indication2,
			  indication3,
			  indication4,
			  indication5,
			  indication6,
			  indication7,
			  indication8
			from program_top_value
			where program_version_id = p_src_id;

			v_rowcount := sql%rowcount;
			log_pkg.steps('c' || v_rowcount, v_step_start, v_steps_result);
		end if;

		if v_new_id is not null then
		  add_missing_sub(v_new_id);
		end if;

		log_pkg.steps('END', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result || v_msg_out);

	exception when others then
		log_pkg.steps('ERROR', v_procedure_start, v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result || v_msg_out);
		notice_pkg.catch(v_where, v_par || v_steps_result || v_msg_out);
		raise;
	end;

	/*************************************************************************/
	function get_pdf_export
	(
		p_project_id in varchar2 default null,
		p_program_id in varchar2 default null,
		p_version in varchar2 default null
	) return varchar2
	as
		/*
		v_where nvarchar2(222) := 'program_top_pkg.get_pdf_export';
		v_par nvarchar2(4000) := 'p_program_id=' || p_program_id||';p_project_id='||p_project_id;
		v_step_start timestamp := systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp := systimestamp;
		v_msg_out nvarchar2(4000);
		*/
		v_sbe_code project.sbe_code%type;
		v_prj_code project.code%type;
		v_prg_code program.code%type;
		v_url varchar2(4000);
		v_code configuration.code%type := 'TOP-EXP-NONC-URL';
	begin
		--log_pkg.steps(null, v_step_start, v_steps_result);
			if p_project_id is not null then
				begin
					select sbe_code, code into v_sbe_code, v_prj_code from project where id=p_project_id;
					
					if v_sbe_code = 'ONC' then
						v_code := 'TOP-EXP-ONC-URL';
					end if;
				exception when others then
					null;
				end;
			end if;

			if p_program_id is not null then
				begin
					select code into v_prg_code from program where id=p_program_id;

				exception when others then
					null;
				end;
			end if;
		--select c.value into v_url from configuration c where c.code=v_code;
		select c.url into v_url from help_bundle c where c.code=v_code;
		v_url := replace(v_url,'#ProgramId#',v_prg_code);
		v_url := replace(v_url,'#ProjectId#',v_prj_code);
		v_url := replace(v_url,'#Version#',p_version);

		--log_pkg.steps('END', v_procedure_start, v_steps_result);
		--log_pkg.log(v_where, v_par, v_steps_result || v_msg_out);
		
		return v_url;
		
	exception when others then
		--log_pkg.steps('ERROR', v_procedure_start, v_steps_result);
		--log_pkg.log(v_where, v_par, v_steps_result || v_msg_out);
		--notice_pkg.catch(v_where, v_par || v_steps_result || v_msg_out);
		return null;
	end;

end;
/
