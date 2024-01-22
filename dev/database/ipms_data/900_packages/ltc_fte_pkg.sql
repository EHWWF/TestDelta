create or replace package ltc_fte_pkg
as
	/*************************************************************************/
	/*
		Freeze TAG specific data and submit data to Reporting.
	*/
	procedure freeze
	(
		p_user_id in nvarchar2,
		p_ltc_tag_id in ltc_tag.id%type
	)
	;
	/*************************************************************************/
	/*
	*/
	procedure unfreeze
	(
		p_user_id in nvarchar2,
		p_ltc_tag_id in ltc_tag.id%type
	)
	;

	/*************************************************************************/
	/*
		Submit report to ipms_repo
	*/
	procedure submit_report
	(
		p_user_id in nvarchar2,
		p_ltc_tag_id in ltc_tag.id%type
	)
	;
	/*************************************************************************/
	/*
		Calculate Probabilistic
	*/
	procedure calc_prob
	(
		p_user_id in nvarchar2,
		p_ltc_tag_id in ltc_tag.id%type
	)
	;
	/*************************************************************************/
	/*
		Return: 1/0/null
		1=newer version of forecast exists, thus, User can not add new process to the Tag without recalculating the whole TAG
		0=no new Forecast, thus, User can continue with the action
		null=EXCEPTION
	*/
	/*************************************************************************/
	function is_newer_forecast
	(
		p_user_id in nvarchar2,
		p_ltc_tag_id in ltc_tag.id%type
	)
	return number
	;
	/*************************************************************************/
	/*
	*/
end;
/
create or replace package body ltc_fte_pkg
as
	/*************************************************************************/
	/*
	*/
	procedure freeze
	(
		p_user_id in nvarchar2,
		p_ltc_tag_id in ltc_tag.id%type
	)
	as
		v_where nvarchar2(222):='ltc_fte_pkg.freeze';
		v_par nvarchar2(4000):=
			'p_user_id='||p_user_id||
			';p_ltc_tag_id='||p_ltc_tag_id;
		--v_rowcount number:=0;
		v_step_start timestamp:=systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:=systimestamp;
		v_msg_out nvarchar2(4000);
		v_ltc_start_year ltc_tag.start_year%type;

	begin
		log_pkg.steps(null,v_step_start,v_steps_result);

		update ltc_tag set
			is_frozen=1,
			update_user_id=p_user_id
		where id=p_ltc_tag_id
		;

		ltc_fte_pkg.submit_report(p_user_id,p_ltc_tag_id);

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result||v_msg_out);

	exception when others then
		log_pkg.steps('ERROR',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result||v_msg_out);
		notice_pkg.catch(v_where,v_par||v_steps_result||v_msg_out);
		raise;
	end;

	/*************************************************************************/
	/*
	*/
	procedure unfreeze
	(
		p_user_id in nvarchar2,
		p_ltc_tag_id in ltc_tag.id%type
	)
	as
		v_where nvarchar2(222):='ltc_fte_pkg.unfreeze';
		v_par nvarchar2(4000):=
			'p_user_id='||p_user_id||
			';p_ltc_tag_id='||p_ltc_tag_id;
		--v_rowcount number:=0;
		v_step_start timestamp:=systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:=systimestamp;
		v_msg_out nvarchar2(4000);
		v_ltc_start_year ltc_tag.start_year%type;

	begin
		log_pkg.steps(null,v_step_start,v_steps_result);

		update ltc_tag set
			is_frozen=0,
			update_user_id=p_user_id
		where id=p_ltc_tag_id
		;

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result||v_msg_out);

	exception when others then
		log_pkg.steps('ERROR',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result||v_msg_out);
		notice_pkg.catch(v_where,v_par||v_steps_result||v_msg_out);
		raise;
	end;

	/*************************************************************************/
	/*
	*/
	procedure submit_report
	(
		p_user_id in nvarchar2,
		p_ltc_tag_id in ltc_tag.id%type
	)
	as
		v_where nvarchar2(222):='ltc_fte_pkg.submit_report';
		v_par nvarchar2(4000):=
			'p_user_id='||p_user_id||
			';p_ltc_tag_id='||p_ltc_tag_id;
		--v_rowcount number:=0;
		v_step_start timestamp:=systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:=systimestamp;
		v_msg_out nvarchar2(4000);
		v_ltc_start_year ltc_tag.start_year%type;
		v_new_ltci_id number;

	begin
		log_pkg.steps(null,v_step_start,v_steps_result);

		update ltc_tag set
			submit_report_date=sysdate,
			submit_report_user_id=p_user_id,
			update_user_id=p_user_id
		where id=p_ltc_tag_id
		;
		
		select timestamp_to_scn(sysdate) into v_new_ltci_id from dual;
		insert into ipms_repo.promis_task(id,ltc_process_id,project_id,ltc_tag_id) 
		values (v_new_ltci_id,null,null,p_ltc_tag_id);

		log_pkg.steps('END.',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result||v_msg_out);

	exception when others then
		log_pkg.steps('ERROR.',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result||v_msg_out);
		notice_pkg.catch(v_where,v_par||v_steps_result||v_msg_out);
		raise;
	end;

	/*************************************************************************/
	/*
	*/
	procedure calc_prob
	(
		p_user_id in nvarchar2,
		p_ltc_tag_id in ltc_tag.id%type
	)
	as
		v_where nvarchar2(222):='ltc_fte_pkg.calc_prob';
		v_par nvarchar2(4000):=
			'p_user_id='||p_user_id||
			';p_ltc_tag_id='||p_ltc_tag_id;
		--v_rowcount number:=0;
		v_step_start timestamp:=systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:=systimestamp;
		v_msg_out nvarchar2(4000);
		v_ltc_start_year ltc_tag.start_year%type;

	begin
		log_pkg.steps(null,v_step_start,v_steps_result);

		update ltc_tag set
			calculate_prob_date=sysdate,
			calculate_prob_user_id=p_user_id,
			update_user_id=p_user_id
		where id=p_ltc_tag_id
		;
		ltc_fte_pkg.submit_report(p_user_id,p_ltc_tag_id);

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result||v_msg_out);

	exception when others then
		log_pkg.steps('ERROR',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result||v_msg_out);
		notice_pkg.catch(v_where,v_par||v_steps_result||v_msg_out);
		raise;
	end;
	/*************************************************************************/
	/*
	*/
	function is_newer_forecast
	(
		p_user_id in nvarchar2,
		p_ltc_tag_id in ltc_tag.id%type
	)
	return number
	as
		v_where nvarchar2(222):='ltc_fte_pkg.is_newer_forecast';
		v_par nvarchar2(4000):=
			'p_user_id='||p_user_id||
			';p_ltc_tag_id='||p_ltc_tag_id;
		--v_rowcount number:=0;
		v_step_start timestamp:=systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:=systimestamp;
		v_msg_out nvarchar2(4000);
		v_ltc_start_year ltc_tag.start_year%type;
		v_forecast_year number;
		v_forecast_month number;
		v_forecast_number number;
		v_forecast_version number;

	begin
		log_pkg.steps(null,v_step_start,v_steps_result);

		select forecast_year,forecast_month,forecast_number,forecast_version
		into v_forecast_year,v_forecast_month,v_forecast_number,v_forecast_version
		from ltc_tag
		where id=p_ltc_tag_id;

		if v_forecast_year||v_forecast_month||v_forecast_number||v_forecast_version is not null then
			if configuration_pkg.get_config_number('LAST-FCT-YEAR')<>nvl(v_forecast_year,-1) then
				return 1;
			end if;
			if configuration_pkg.get_config_number('LAST-FCT-MONTH')<>nvl(v_forecast_month,-1) then
				return 1;
			end if;
			if configuration_pkg.get_config_number('LAST-FCT-NUM')<>nvl(v_forecast_number,-1) then
				return 1;
			end if;
			if configuration_pkg.get_config_number('LAST-FCT-VER')<>nvl(v_forecast_version,-1) then
				return 1;
			end if;
		end if;
		
		return 0;

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result||v_msg_out);

	exception when others then
		log_pkg.steps('ERROR',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, v_par, v_steps_result||v_msg_out);
		notice_pkg.catch(v_where,v_par||v_steps_result||v_msg_out);
		return null;-- when OTHERS then return null - 
		raise;
	end;

	/*************************************************************************/
	/*
	*/
end;
/