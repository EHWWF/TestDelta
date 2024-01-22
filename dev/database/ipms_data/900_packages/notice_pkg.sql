create or replace package notice_pkg as

	/**
	 * Logs information message.
	 * Can log message for user, role or all users within program/project.
	 */
	procedure information(p_subject in nvarchar2, p_summary in nvarchar2, p_details in clob default null,
		p_project in nvarchar2 default null, p_program in nvarchar2 default null);

	/**
	 * Logs info warning.
	 * Can log message for user, role or all users within program/project.
	 */
	procedure warning(p_subject in nvarchar2, p_summary in nvarchar2, p_details in clob default null,
		p_project in nvarchar2 default null, p_program in nvarchar2 default null);

	/**
	 * Logs error message.
	 * Can log message for user, role or all users within program/project.
	 */
	procedure error(p_subject in nvarchar2, p_summary in nvarchar2, p_details in clob default null,
		p_project in nvarchar2 default null, p_program in nvarchar2 default null);

	/**
	 * Logs debug message.
	 * Can log message for user, role or all users within program/project.
	 */
	procedure debug(p_subject in nvarchar2, p_summary in nvarchar2, p_details in clob default null,
		p_project in nvarchar2 default null, p_program in nvarchar2 default null);

	/**
	 * Logs exception message.
	 * Gathers data from current session.
	 */
	procedure catch(p_subject in nvarchar2, p_summary in nvarchar2,
		p_project in nvarchar2 default null, p_program in nvarchar2 default null);

	/**
	 * Safely removes old data.
	 */
	procedure cleanup;

end;
/
create or replace package body notice_pkg as

	/*************************************************************************/
	function get_error_details return clob as
	begin
		return 'Error Stack:' || Chr(10)
			|| DBMS_UTILITY.FORMAT_ERROR_STACK() || Chr(10)
			||'Error Backtrace:' || Chr(10)
			|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE();
	end;

	/*************************************************************************/
	procedure cleanup as
	begin
		delete from notice where (sysdate - create_date) > 60;
	end;

	/*************************************************************************/
	procedure save
	(
		p_severity in nvarchar2,
		p_subject in nvarchar2,
		p_summary in nvarchar2,
		p_details in clob default null,
		p_project in nvarchar2 default null,
		p_program in nvarchar2 default null
	) 
	as
	begin
		--insert into notice(subject,severity_code,content,details)
		--values(p_subject,p_severity,p_summary,p_details);
		log_pkg.slog(p_subject,p_summary,null,p_severity,'NOTICE');
	end;

	/*************************************************************************/
	procedure information
	(
		p_subject in nvarchar2,
		p_summary in nvarchar2,
		p_details in clob default null,
		p_project in nvarchar2 default null,
		p_program in nvarchar2 default null
	) 
	as
	begin
		save('INFO', p_subject, p_summary, p_details, p_project, p_program);
	end;

	/*************************************************************************/
	procedure warning
	(
		p_subject in nvarchar2,
		p_summary in nvarchar2,
		p_details in clob default null,
		p_project in nvarchar2 default null,
		p_program in nvarchar2 default null
	) 
	as
	begin
		save('WARN', p_subject, p_summary, p_details, p_project, p_program);
	end;

	/*************************************************************************/
	procedure error
	(
		p_subject in nvarchar2,
		p_summary in nvarchar2,
		p_details in clob default null,
		p_project in nvarchar2 default null,
		p_program in nvarchar2 default null
	) 
	as
	begin
		save('ERROR', p_subject, p_summary, p_details, p_project, p_program);
	end;

	/*************************************************************************/
	procedure catch
	(
		p_subject in nvarchar2,
		p_summary in nvarchar2,
		p_project in nvarchar2 default null,
		p_program in nvarchar2 default null
	) 
	as
		pragma autonomous_transaction;
	begin
		log_pkg.scatch(p_subject,p_summary,null,'NOTICE');
		--error(p_subject, p_summary, get_error_details, p_project, p_program);
		--commit;
	end;

	/*************************************************************************/
	procedure debug(p_subject in nvarchar2, p_summary in nvarchar2, p_details in clob default null,
		p_project in nvarchar2 default null, p_program in nvarchar2 default null) as
		pragma autonomous_transaction;
	begin
		save('DEBUG', p_subject, p_summary, p_details, p_project, p_program);
		commit;
	end;

end;
/