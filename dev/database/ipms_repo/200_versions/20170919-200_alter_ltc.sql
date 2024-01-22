alter table cost_ltc_fte_fct add estimate_type_code nvarchar2(10);
comment on column cost_ltc_fte_fct.estimate_type_code is 'LTC Estimate could have two types of Sheets: LTC or FTE.';
update cost_ltc_fte_fct set estimate_type_code='LTC' where estimate_type_code is null;
commit;