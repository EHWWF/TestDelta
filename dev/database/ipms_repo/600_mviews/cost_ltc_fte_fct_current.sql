drop materialized view cost_ltc_fte_fct_current;
create materialized view cost_ltc_fte_fct_current as select * from cost_ltc_fte_fct_vw;
grant select on cost_ltc_fte_fct_current to mycsd;