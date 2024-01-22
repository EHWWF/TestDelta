alter table project_audit disable all triggers;	
alter table project_audit add (
	record_type 
		varchar2(20) 
		default 'IPMS'
		not null 
		check (record_type in ('IPMS','FPS')) 
);
alter table project_audit enable all triggers;