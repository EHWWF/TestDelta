alter table ltc_plan disable all triggers;
alter table ltc_plan add (update_date date);
alter table ltc_plan enable all triggers;