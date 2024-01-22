alter table latest_estimate_fct add process_status_code nvarchar2(10);
comment on column latest_estimate_fct.process_status_code is 'LE Status Code for the Process';