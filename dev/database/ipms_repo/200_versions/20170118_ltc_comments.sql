create or replace view cost_ltc_comments_dim_vw as
select
	lp.ltci_id,
	lp.wbs_id,
	lv.function_code,
	lv.comments
from ipms_data.ltc_value lv
join ipms_data.ltc_plan lp on (lv.ltcp_id=lp.id)
where lv.comments is not null
;
create table cost_ltc_comments_dim as select * from cost_ltc_comments_dim_vw where ltci_id in (select ltci_id from cost_ltc_fct);
create unique index cost_ltc_comments_dim_unidx on cost_ltc_comments_dim (ltci_id,wbs_id,function_code);
prompt --
prompt --
prompt --ERROR, FEHLER: it just a note for deployment that manual task must be done, see: 20170118_Manual_ltc_comments.txt
prompt --
prompt --
prompt --