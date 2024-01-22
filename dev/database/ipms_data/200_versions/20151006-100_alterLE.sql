alter table latest_estimates_tag add (CY_PROB_PREFILL_TAG_ID NVARCHAR2(45),NY_PROB_PREFILL_TAG_ID NVARCHAR2(45));
update prefill_type set is_active=1 where code='xLEp';
commit;
alter table latest_estimates_tag add (year number(10));
update latest_estimates_tag set year= extract(year from sysdate);
alter table latest_estimates_tag modify (year number(10) not null);