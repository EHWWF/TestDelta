BEGIN
DBMS_SCHEDULER.set_attribute( name => '"IPMS_REPO"."COPY_LTC_JOB"', attribute => 'comments', 
value => 'Almost all ProMIS data from IPMS_DATA to IPMS_REPO is being transferred on Materialized View basis, but there are some exceptions that needs a support of DB procedures and this exception applies to LTC data.
DB Job assures that data from ProMIS is being transferred without deleting historical LTC data.');
END; 
/
BEGIN
DBMS_SCHEDULER.set_attribute( name => '"IPMS_REPO"."REFRESH_REPO_JOB"', attribute => 'comments', 
value => 'Moves ProMIS data from IPMS_DATA to IPMS_REPO on force refresh Materialized Views basis. In addition to that also does baseline reading and timeline summarization.');
END; 
/