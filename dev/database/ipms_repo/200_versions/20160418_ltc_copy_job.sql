create table promis_task (
	id nvarchar2(20) not null primary key,
	create_date date default sysdate);

comment on table promis_task is 'The table is used for having task initations that should be done from IPMS_REPO. NOw it is only for LTC, for future use it can be extended to use - execute immediate.';
comment on column promis_task.id is 'Reference to LTC instance.';
grant insert on ipms_repo.promis_task to ipms_data;

begin
	dbms_scheduler.create_job (
	job_name => 'COPY_LTC_JOB',
	job_type => 'plsql_block',
	job_action => 'begin job_pkg.insert_new_ltc; commit; end;',
	start_date => sysdate+5/1440,
	repeat_interval => 'freq=minutely; interval=1;',
	end_date => null,
	enabled => true,
	comments => 'Copy LTC data from IPMS_DATA to IPMS_REPO ASAP.');
end;
/
