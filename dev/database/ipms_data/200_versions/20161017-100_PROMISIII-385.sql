alter table ltc_value drop constraint ltcv_pk;
alter table ltc_value add constraint ltcv_pk primary key (id);
