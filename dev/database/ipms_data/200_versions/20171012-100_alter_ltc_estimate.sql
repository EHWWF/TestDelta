alter table ltc_estimate drop constraint LTC_ESTIMATE_SCOPE_CODE_CHK;
update ltc_estimate set scope_code='-' where type_code='FTE';
commit;
alter table ltc_estimate add constraint LTC_ESTIMATE_SCOPE_CODE_CHK check(type_code='LTC' and scope_code in ('INT','EXT') or type_code='FTE' and scope_code = '-');