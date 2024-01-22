create or replace package log_pkg as
--pragma serially_reusable;
	g_done nvarchar2(99):='Procedure completed.';-- PREFIX text stating that procedure completed as expected.

	/*************************************************************************/
	/**
	 * Logs the event.
	 */
	procedure log
	(
		p_subject in nvarchar2 default null,
		p_summary in nvarchar2 default null,
		p_details in nvarchar2 default null
	)
	;

	/*************************************************************************/
	/**
	 * Safely removes old data.
	 */
	procedure cleanup;

	/*************************************************************************/
	--Collecting and measuring steps during procedure run
	procedure steps
	(
		p_where nvarchar2,
		p_step_start in out timestamp,
		p_steps_result in out nvarchar2
	);

	/*************************************************************************/
	/**
	 * Logs exception message.
	 * Gathers data from current session.
	 */
	procedure catch
	(
		p_subject in nvarchar2 default null,
		p_summary in nvarchar2 default null,
		p_details in nvarchar2 default null
	)
	;

	/*************************************************************************/
	/**
	 * Logs the event.
	 */
	procedure slog
	(
		p_subject in nvarchar2 default null,
		p_parameters in nvarchar2 default null,
		p_details in nvarchar2 default null,
		p_severity in nvarchar2 default null,
		p_user_id in nvarchar2 default null
	)
	;
	/*************************************************************************/
	/**
	 * Logs exception message.
	 * Gathers data from current session.
	 */
	procedure scatch
	(
		p_subject in nvarchar2 default null,
		p_parameters in nvarchar2 default null,
		p_details in nvarchar2 default null,
		p_user_id in nvarchar2 default null
	)
	;

end;
/
create or replace package body log_pkg as
--pragma serially_reusable;
	/*************************************************************************/
	procedure cleanup as
	begin
		delete from log where (sysdate - event_date) > 365/4;
	end;

	/*************************************************************************/
	procedure steps
	(
		p_where nvarchar2,
		p_step_start in out timestamp,
		p_steps_result in out nvarchar2
	)
	as
		v_linterval_diff interval day to second;
	begin
		v_linterval_diff := systimestamp - p_step_start;
		if p_where is null and p_steps_result is null then --means BEGIN
			p_steps_result := 'BEGIN';
		else
			p_steps_result := p_steps_result||';'||p_where;--just collect steps
		end if;

		if trunc(extract(second from v_linterval_diff)) > 0 then--log time if was at all
			p_steps_result := p_steps_result||'='||trunc(extract(minute from v_linterval_diff)*60+extract(second from v_linterval_diff));
		end if;
		p_step_start := systimestamp;--reset step for the next calculation
	end;

	/*************************************************************************/
	procedure when_others
	(
		p_subject in nvarchar2,
		p_summary in nvarchar2
	)
	as
	begin
		insert into sys_log
		(
			create_user_id,
			severity,
			subject,
			parameters,
			content,
			error_stack
		)
		values
		(
			'ERROR',
			'ERROR',
			substr(p_subject,1,4000),
			substr(p_summary,1,4000),--parameters
			'LOG_ERROR',--p_details
			'Error_Stack:'||chr(10)||dbms_utility.format_error_stack()
		)
		;
		commit;
	end;

	/*************************************************************************/
	procedure log
	(
		p_subject in nvarchar2,
		p_summary in nvarchar2,--parameters
		p_details in nvarchar2
	) 
	as
	begin
		insert into sys_log
		(
			create_user_id,
			severity,
			subject,
			parameters,
			content
		)
		values
		(
			user_pkg.get_current_user,
			'DEBUG',
			p_subject,
			p_summary,--parameters
			p_details
		)
		;

	exception when others then
		when_others(p_subject,p_summary);
	end;

	/*************************************************************************/
	procedure slog
	(
		p_subject in nvarchar2,
		p_parameters in nvarchar2,--parameters
		p_details in nvarchar2,
		p_severity in nvarchar2,
		p_user_id in nvarchar2
	) 
	as
		pragma autonomous_transaction;
	begin
		insert into sys_log
		(
			create_user_id,
			severity,
			subject,
			parameters,
			content
		)
		values
		(
			nvl(p_user_id,user_pkg.get_current_user),
			nvl(p_severity,'DEBUG'),
			p_subject,
			p_parameters,--parameters
			p_details
		)
		;
		commit;
	exception when others then
		when_others(p_subject,p_parameters);
	end;

	/*************************************************************************/
	procedure catch
	(
		p_subject in nvarchar2,
		p_summary in nvarchar2,
		p_details in nvarchar2
	)
	as
		pragma autonomous_transaction;
	begin
		insert into sys_log
		(
			create_user_id,
			severity,
			subject,
			parameters,
			content,
			error_stack
		)
		values
		(
			nvl(user_pkg.get_current_user,'ERROR'),
			'ERROR',
			p_subject,
			p_summary,--parameters
			p_details,
			'Error_Stack:'||chr(10)||dbms_utility.format_error_stack()||chr(10)||
			'Error_Backtrace:'||chr(10)||dbms_utility.format_error_backtrace()
		)
		;
		commit;
	exception when others then
		when_others(p_subject,p_summary);
	end;

	/*************************************************************************/
	procedure scatch
	(
		p_subject in nvarchar2,
		p_parameters in nvarchar2,--parameters
		p_details in nvarchar2,
		p_user_id in nvarchar2
	)
	as
		pragma autonomous_transaction;
	begin
		insert into sys_log
		(
			create_user_id,
			severity,
			subject,
			parameters,
			content,
			error_stack
		)
		values
		(
			nvl(user_pkg.get_current_user,'ERROR'),
			'ERROR',
			p_subject,
			p_parameters,--parameters
			p_details,
			'Error_Stack:'||chr(10)||dbms_utility.format_error_stack()||chr(10)||
			'Error_Backtrace:'||chr(10)||dbms_utility.format_error_backtrace()
		)
		;
		commit;
	exception when others then
		when_others(p_subject,p_parameters);
	end;

end;
/