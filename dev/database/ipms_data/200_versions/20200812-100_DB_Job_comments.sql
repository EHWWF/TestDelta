BEGIN
DBMS_SCHEDULER.set_attribute( name => '"IPMS_DATA"."CACHEMDS_JOB"', attribute => 'comments', 
value => 'Refreshes frequently used data for SOA processes.As a result BPEL does not have to call for every process P6 WS for configuration data instead call SOA local file only. In addition to that also refresh configuration data stored in ProMIS DB, e.g. study templates.');
END; 
/
BEGIN
DBMS_SCHEDULER.set_attribute( name => '"IPMS_DATA"."EXPORT_JOB"', attribute => 'comments', 
value => 'Export data job that initiates refresh of the data for all Materialized Views with the prefix: "EXPORT", e.g.: "EXPORT_GOAL".');
END; 
/
BEGIN
DBMS_SCHEDULER.set_attribute( name => '"IPMS_DATA"."FUNCTION_SUB_STATUS"', attribute => 'comments', 
value => 'Every day (at midnight), Functions and Subfunctions that have "valid_to" date provided, are being validated with new current date and "Active" flag is being updated (accordingly).
Based on this job ProMIS can use later "Valid_to" or simply "Active=true" for retrieving valid Functions/Subfunctions.');
END; 
/
BEGIN
DBMS_SCHEDULER.set_attribute( name => '"IPMS_DATA"."IMPORT_CLOSE_SLOT_JOB"', attribute => 'comments', 
value => 'DB Job that closes data import window.
Regular (batch) data imports from external systems to ProMIS being executed within concrete time slots only. The time slot is being controlled by two related DB Jobs. One DB Job opens the slot (data import window) "IMPORT_OPEN_SLOT_JOB" and another DB Job closes "IMPORT_CLOSE_SLOT_JOB". Implemented solution assures that data import is not being done while Business working hours.');
END; 
/
BEGIN
DBMS_SCHEDULER.set_attribute( name => '"IPMS_DATA"."IMPORT_OPEN_SLOT_JOB"', attribute => 'comments', 
value => 'DB Job that opens data import window.
Regular (batch) data imports from external systems to ProMIS being executed within concrete time slots only. The time slot is being controlled by two related DB Jobs. One DB Job opens the slot (data import window) "IMPORT_OPEN_SLOT_JOB" and another DB Job closes "IMPORT_CLOSE_SLOT_JOB". Implemented solution assures that data import is not being done while Business working hours.');
END; 
/
BEGIN
DBMS_SCHEDULER.set_attribute( name => '"IPMS_DATA"."PURGE_BIG_FDA_JOB"', attribute => 'comments', 
value => 'Some of ProMIS Flashbacks needs manual purge because RETENTION setting is not always working correctly (not assuring automatic purge based on Flashback setting).
That applies for Flashback that are important from data import perspective but at the same time consume a lot of table space.
DB Jobs triggers (force) data purge on selected Flashbacks.');
END; 
/
BEGIN
DBMS_SCHEDULER.set_attribute( name => '"IPMS_DATA"."QPLAN_NOTIFY_JOB"', attribute => 'comments', 
value => 'DB Job that daily (in the mornings) initiates email notification (report) on FPS integrations.
As a result Users are able to get Morning reports on the list of projects that were send to FPS.');
END; 
/
BEGIN
DBMS_SCHEDULER.set_attribute( name => '"IPMS_DATA"."QPLAN_RELEASE_JOB"', attribute => 'comments', 
value => 'DB Job, based on defined schedule (now it is hourly), gathers/collects all projects that needs to be transferred to FPS, prepares data integration package and send to FPS.
Initially ProMIS was sending immediately all Project data changes to FPS but later FPS initiated the change to assure - "package/batch based data integration".
');
END; 
/
BEGIN
DBMS_SCHEDULER.set_attribute( name => '"IPMS_DATA"."SYS_GUID_JOB"', attribute => 'comments', 
value => 'Business Activity Log (BAL) is being collected with every End User interaction with ProMIS. 
Every User action (activity) has unique activity id and related data, e.g. program and/or project id.
There are some cases (activities) that BAL is not able to send context data and because of that supporting (asynchronous) DB Job is needed in order to collect missing data based on committed DB transactions.');
END; 
/