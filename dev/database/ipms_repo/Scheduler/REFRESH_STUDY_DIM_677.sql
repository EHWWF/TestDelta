BEGIN
dbms_scheduler.create_job (
job_name => 'REFRESH_STUDY_DIM',
job_type => 'PLSQL_BLOCK',
job_action => 'BEGIN DBMS_MVIEW.REFRESH(''STUDY_DIM'',''C''); commit; END;',
start_date => '20-JAN-23 09.30.00.000000000 PM EUROPE/BERLIN',
repeat_interval => 'freq=hourly; interval=1;',
end_date => null,
enabled => true,
comments => 'Job to run every 1 hours.');
END;
/
