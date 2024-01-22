insert into configuration(code, name, value)
select 'LTC-TAG-ID', 'Specific TAG ID for which data will be collected at specific time. Related to BAY_PROMIS-541', '62' from dual
where not exists(select 1 from configuration where code = 'LTC-TAG-ID');

insert into configuration(code, name, value)
select 'LTC-TAG-SCN', 'Specific timestamp value represented as a system change number. Related to BAY_PROMIS-541', '11564074960579' from dual
where not exists(select 1 from configuration where code = 'LTC-TAG-SCN');

commit;