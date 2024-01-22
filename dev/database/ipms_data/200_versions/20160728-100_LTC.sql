alter table ltc_instance disable all triggers;
alter table ltc_instance add (stage_number number(3) default 0);
alter table ltc_instance add (update_date date);
comment on column ltc_instance.stage_number is 'The number is used for showing the stage at ADF Train component. 0,10,20,30,40. More details see LTC_PKG.get_ltc_stage_number';
alter table ltc_instance enable all triggers;
grant update on ltc_instance to ipms_repo;