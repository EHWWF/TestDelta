declare
	v_count number;
begin
	select count(1)
	into v_count
	from user_scheduler_jobs
	where job_name = upper('CLEANUP_JOB');

	if v_count = 1 then
		dbms_scheduler.drop_job (
			job_name => 'CLEANUP_JOB',
			force => true
		);
		commit;
	end if;
end;
/