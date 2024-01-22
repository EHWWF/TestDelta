create or replace view timeline_expense_vw as
select
	tl.project_id,
	tl.id as timeline_id,
	tl.type_code timeline_type_code,
	nullif(xt.wbs_id, tl.reference_id) as wbs_id, 
	xt.function_code as function_code, 
	xt.cost_type as cost_type, 
	decode(xt.cost_type, 'Internal Cost', N'INT', 'External Cost - ECG', N'ECG', 'External Cost - CRO', N'CRO', 'External Cost - OEC', N'OEC') as cost_type_code,
	xt.code,
	to_number(xt.plan_cost, '999999999999.99999999') as plan_cost,
	xt.comments as comments
from
	timeline tl,
	xmltable(
		xmlnamespaces(default 'http://xmlns.bayer.com/ipms'),
		'/timeline/expenses/expense' passing tl.details
		columns 
			wbs_id			nvarchar2(20)	path '@wbsId',
			function_code	nvarchar2(20)	path 'functionCode',
			cost_type		nvarchar2(100)	path 'costType',
			code 			nvarchar2(20)	path 'code',
			name 			nvarchar2(100)	path 'name',
			plan_cost						path 'planCost',
			comments		nvarchar2(4000)	path 'comments'
	) xt
where tl.details is not null;
create table timeline_expense as select * from timeline_expense_vw;
alter table timeline_expense add (create_date date default sysdate);
alter table timeline_expense add (update_date date);
create index timeline_expense_tml_id_idx on timeline_expense (timeline_id);
create index timeline_expense_wbs_id_idx on timeline_expense (wbs_id);