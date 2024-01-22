begin
for r in (select constraint_name from user_constraints where table_name='LTC_VALUE' and constraint_type='P') loop
execute immediate 'alter table ltc_value drop constraint '||r.constraint_name;
end loop;
end;
/
alter table ltc_value drop constraint LTC_VALUE_UK;
alter table ltc_value add constraint ltcv_pk primary key (ltcp_id,function_code);
