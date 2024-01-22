prompt 
prompt ---->ERROR, FEHLER: Create DB JOB that reads all timelines
declare
begi n--error will be here ;)
for tt in (select id from timeline where TYPE_CODE in ('RAW','CUR','APR') order by 1)
loop
timeline_pkg.receive(tt.id);
log_pkg.log('MANUAL.UPDATE', 'timeline_id',tt.id);
commit;
dbms_lock.sleep(12);
end loop;
end;
prompt 
prompt