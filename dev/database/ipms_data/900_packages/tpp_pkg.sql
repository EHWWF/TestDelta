create or replace package tpp_pkg
as
	/**
	* Create TPP version based on current TPP and it's values
	* Synchronous.
	* Locks instance.
	*/
	procedure create_tpp_version
	(
		p_id in nvarchar2,
		p_name in varchar2 default null,
		p_approval_date in varchar2 default null,
		p_description in varchar2 default null
	)
	;
	/**
	* Copy TPP version to current TPP
	* Synchronous.
	* Locks instance.
	*/
	procedure copy_version_to_current
	(
		p_src_tpp_id in target_product_profile.id%type
	)
	;	
	/**
	* Get PDF URL for exporting data
	*/
	function get_pdf_export
	(
		p_project_id in varchar2 default null,
		p_version in varchar2 default null
	) return varchar2
	;
end;
/
create or replace package body tpp_pkg
as
	/*************************************************************************/
	function get_summary(p_id in nvarchar2) return nvarchar2
	as
		v_info nvarchar2(300);
	begin
		select 'Tpp['||name||','||approval_date||']'
		into v_info
		from target_product_profile
		where id = p_id;

		return v_info;

	exception when no_data_found then
		return 'Tpp['||nvl(p_id,'-')||']';
	end;

	/*************************************************************************/
	function get_subject(p_id in nvarchar2) return nvarchar2
	as
	begin
		return 'tpp:'||p_id;
	end;

	/*************************************************************************/
	function get_max_version(p_id in nvarchar2) return nvarchar2
	as
		v_max_version nvarchar2(200);
	begin
		select nvl(max(to_number(version)),0)
		into v_max_version
		from target_product_profile
		where project_id = p_id and version != 'Current';

		return v_max_version + 1;
	end;

	/*************************************************************************/
	procedure create_tpp_version
	(
		p_id in nvarchar2,
		p_name in varchar2 default null,
		p_approval_date in varchar2 default null,
		p_description in varchar2 default null
	)
	as
		v_where nvarchar2(222) := 'tpp_pkg.create_tpp_version';
		v_par nvarchar2(4000) := 'p_id=' || p_id ||
								';p_name=' || p_name ||
								';p_approval_date=' || p_approval_date ||
								';p_description=' || p_description;
		v_step_start timestamp := systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp := systimestamp;
		v_msg_out nvarchar2(4000);
		v_user_id nvarchar2(55) := 'TODO_PROCEDURE';
		v_rowcount number;

		v_max_version nvarchar2(200);
		v_new_tpp_id nvarchar2(20);
		v_curr_tpp_id nvarchar2(20);
		v_indication nvarchar2(2000);
		v_references nvarchar2(2000);
	begin
		log_pkg.steps(null, v_step_start, v_steps_result);
		select
			id,
			indication,
			references
		into
			v_curr_tpp_id,
			v_indication,
			v_references
		from target_product_profile
		where project_id = p_id
		and version = 'Current';

		v_max_version := get_max_version(p_id);
		log_pkg.steps('a', v_step_start, v_steps_result);
		/* insert new tpp version*/
		insert into target_product_profile
		(
			project_id,
			name,
			version,
			approval_date,
			description,
			indication,
			references
		)
		values
		(
			p_id,
			p_name,
			v_max_version,
			p_approval_date,
			p_description,
			v_indication,
			v_references
		)
		returning id into v_new_tpp_id;
		log_pkg.steps('b', v_step_start, v_steps_result);
		-- copy over tpp values from current into new tpp version
		insert into tpp_values
		(
			tpp_id,
			subcategory_code,
			key_edv_proposition,
			standard_of_care,
			targeted_profile,
			upside,
			targeted_in,
			key_driver,
			unique_selling_point
		)
		select
			v_new_tpp_id,
			subcategory_code,
			key_edv_proposition,
			standard_of_care,
			targeted_profile,
			upside,
			targeted_in,
			key_driver,
			unique_selling_point
		from tpp_values
		where tpp_id = v_curr_tpp_id;

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
		p_src_tpp_id in target_product_profile.id%type
	)
	as
		v_where nvarchar2(222) := 'tpp_pkg.copy_version_to_current';
		v_par nvarchar2(4000) := 'p_src_tpp_id=' || p_src_tpp_id;
		v_step_start timestamp := systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp := systimestamp;
		v_msg_out nvarchar2(4000);
		v_user_id nvarchar2(55) := 'TODO_PROCEDURE';
		v_rowcount number;

		v_dst_tpp_id target_product_profile.id%type;
		v_src_tpp target_product_profile%rowtype;
	begin
		log_pkg.steps(null, v_step_start, v_steps_result);
		-- Save source TPP masterdata
		select * into v_src_tpp
		from target_product_profile
		where id=p_src_tpp_id;

		-- Delete data of current TPP version
		delete from target_product_profile
		where project_id=v_src_tpp.project_id
		and version='Current';
		log_pkg.steps('a', v_step_start, v_steps_result);
		-- Insert new masterdata for current TPP version
		insert into target_product_profile
		(
			name,
			project_id,
			version,
			indication,
			references,
			approval_date
		)
		values
		(
			v_src_tpp.name,
			v_src_tpp.project_id,
			'Current',
			v_src_tpp.indication,
			v_src_tpp.references,
			v_src_tpp.approval_date
		)
		returning id into v_dst_tpp_id;
		log_pkg.steps('b', v_step_start, v_steps_result);
		-- Copy new values for current TPP version
		insert into tpp_values
		(
			tpp_id,
			subcategory_code,
			key_edv_proposition,
			standard_of_care,
			targeted_profile,
			upside,
			targeted_in,
			key_driver,
			unique_selling_point
		)
		select
			v_dst_tpp_id,
			subcategory_code,
			key_edv_proposition,
			standard_of_care,
			targeted_profile,
			upside,
			targeted_in,
			key_driver,
			unique_selling_point
		from tpp_values
		where tpp_id = v_src_tpp.id;

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
		v_url varchar2(4000);
	begin
		--log_pkg.steps(null, v_step_start, v_steps_result);
		select c.url into v_url from help_bundle c where c.code='TPP-EXPURL';
		v_url := replace(v_url,'#ProjectId#',p_project_id);
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
