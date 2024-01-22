prompt 
prompt ---->It always creates double views, at first dummy (that always works) and only then overwrites with correct one
prompt 
-------------------------------------------------
-------------------------------------------------
create or replace view bal_project_audit_his_vw as
select 
	11 as bac, -- FPS
	cast ('messagefps' as nvarchar2(30)) as ba_code,
	upper('project_audit') as table_name_his,
	--prg.name as program_name,
	p.program_id,
	p.name as project_name,
	p.code as project_code,
	p.id as project_id,
	pa.create_date,
	pa.change_comment,
	cast ('PROMIS' as nvarchar2(30)) as log_user_id,
	rawtohex(pa.id) as id,
	null as gu_id
from project_audit pa
join project p on p.id=pa.project_id
--join program prg on prg.id = p.program_id
where (upper(record_type) = upper('FPS') )
;
-------------------------------------------------
-------------------------------------------------
create or replace view bal_program_his_vw as
select * from bal_project_audit_his_vw where 1=0;
-------------------------------------------------
-------------------------------------------------
create or replace view bal_program_his_vw as
select
	1 as bac, --Program
	guid.ba_code,
	upper('program_his') as table_name_his,
	--prg.name as program_name,
	prg.id as program_id,
	null as project_name,
	null as project_code,
	null as project_id,
	guid.create_date,
	null as change_comment,
	guid.user_id as log_user_id,
	max(prg.rid||prg.startscn||prg.endscn) as id,
	guid.id as gu_id
from program_his prg
join sys_guid_transaction tr on (prg.xid = tr.transaction_id) 
join sys_guid guid on (guid.id=tr.guid)
where guid.ba_code in ('programcreate','programdelete','programedit','programroles','programteam')
group by
	guid.ba_code,
	--prg.name,
	prg.id,
	guid.create_date,
	guid.user_id,
	guid.id
;
-------------------------------------------------
-------------------------------------------------
create or replace view bal_project_his_vw as
select * from bal_project_audit_his_vw where 1=0;
-------------------------------------------------
-------------------------------------------------
create or replace view bal_project_his_vw as
select
	--5=Project Timeline, 2=Project Master data,8=Planning Assumptions Request
	decode(guid.ba_code,'planningassumptionsprovide',8,'timelinepublish',5,'importstudy',5,'importtimelinefps',5,'importtimelineplansophia',5,2) bac,
	guid.ba_code,
	upper('project_his') as table_name_his,
	--prg.name as program_name,
	prj.program_id,
	prj.name as project_name,
	prj.code as project_code,
	prj.id as project_id,
	guid.create_date,
	null as change_comment,
	guid.user_id as log_user_id,
	max(prj.rid||prj.startscn||prj.endscn) as id,
	guid.id as gu_id
from project_his prj
join sys_guid_transaction tr on (prj.xid = tr.transaction_id)
join sys_guid guid on (guid.id=tr.guid)
--join program prg on (prj.program_id=prg.id)
where guid.ba_code in 
	(
	'projectcreate',
	'projectdelete',
	'projectedit',
	'projecteditid',
	'projectforecast',
	'projectimportd1',
	'projectlead',
	'projectmove',
	'projectrelease',
	'projectreleasefps',
	'projectrestore',
	'projecttypify',
	'timelinepublish',
	'importstudy',
	'importtimelinefps',
	'importtimelineplansophia',
	'planningassumptionsprovide'
	)
group by 
	decode(guid.ba_code,'planningassumptionsprovide',8,'timelinepublish',5,'importstudy',5,'importtimelinefps',5,'importtimelineplansophia',5,2),
	guid.ba_code,
	--prg.name,
	prj.program_id,
	prj.name,
	prj.code,
	prj.id,
	guid.create_date,
	guid.user_id,
	guid.id
;
-------------------------------------------------
-------------------------------------------------
create or replace view bal_tpp_his_vw as
select * from bal_project_audit_his_vw where 1=0;
-------------------------------------------------
-------------------------------------------------
create or replace view bal_tpp_his_vw as
select 
	3 bac, --Project TPP
	guid.ba_code,
	upper('target_product_profile_his') as table_name_his,
	--prg.name as program_name,
	prj.program_id,
	prj.name as project_name,
	prj.code as project_code,
	prj.id as project_id,
	guid.create_date,
	null as change_comment,
	guid.user_id as log_user_id,
	max(tpp.rid||tpp.startscn||tpp.endscn) as id,
	guid.id as gu_id
from target_product_profile_his tpp
join sys_guid_transaction tr on (tpp.xid = tr.transaction_id)
join sys_guid guid on (guid.id=tr.guid)
join project prj on prj.id = tpp.project_id 
--join program prg on prg.id = prj.program_id 
where guid.ba_code = 'tppedit'
group by
	guid.ba_code,
	--prg.name,
	prj.program_id,
	prj.name,
	prj.code,
	prj.id,
	guid.create_date,
	guid.user_id,
	guid.id
;
-------------------------------------------------
-------------------------------------------------
create or replace view bal_goal_his_vw as
select * from bal_project_audit_his_vw where 1=0;
-------------------------------------------------
-------------------------------------------------
create or replace view bal_goal_his_vw as
select
	4 bac, --Project Goals
	guid.ba_code,
	upper('goal_his') as table_name_his,
	--prg.name as program_name,
	prj.program_id,
	prj.name as project_name,
	prj.code as project_code,
	prj.id as project_id,
	guid.create_date,
	null as change_comment,
	guid.user_id as log_user_id,
	max(gl.rid||gl.startscn||gl.endscn) as id,
	guid.id as gu_id
from goal_his gl
join sys_guid_transaction tr on (gl.xid = tr.transaction_id)
join sys_guid guid on (guid.id=tr.guid)
join project prj on prj.id = gl.project_id
--join program prg on prg.id = prj.program_id
where guid.ba_code in ('goalscreate','goalsdelete','goalsedit')
group by
	guid.ba_code,
	--prg.name,
	prj.program_id,
	prj.name,
	prj.code,
	prj.id,
	guid.create_date,
	guid.user_id,
	guid.id
;
-------------------------------------------------
-------------------------------------------------
create or replace view bal_le_process_his_vw as
select * from bal_project_audit_his_vw where 1=0;
-------------------------------------------------
-------------------------------------------------
create or replace view bal_le_process_his_vw as
select 
	6 as bac, --LE Process
	guid.ba_code,
	upper('latest_estimates_process_his') as table_name_his,
	--prg.name as program_name,
	prj.program_id,
	prj.name as project_name,
	prj.code as project_code,
	prj.id as project_id,
	guid.create_date,
	null as change_comment,
	guid.user_id as log_user_id,
	max(lep.rid||lep.startscn||lep.endscn||rawtohex(prj.id)) as id,
	guid.id as gu_id
from latest_estimates_process_his lep
join sys_guid_transaction tr on (lep.xid = tr.transaction_id)
join sys_guid guid on (guid.id=tr.guid)
join latest_estimate le on le.process_id = lep.id
join project prj on prj.id = le.project_id
--join program prg on prg.id = prj.program_id
where guid.ba_code in (
	'estimatesprocessdelete',
	'estimatesprocessstart',
	'estimatesprocessterminate',
	'estimatesprocessupdate',
	'estimatesprovide',
	'estimatestagmeetingfinalize',
	'estimatestagcreate',
	'estimatestagfreeze')
group by
	guid.ba_code,
	--prg.name,
	prj.program_id,
	prj.name,
	prj.code,
	prj.id,
	guid.create_date,
	guid.user_id,
	guid.id
;
-------------------------------------------------
-------------------------------------------------
create or replace view bal_le_his_vw as
select * from bal_project_audit_his_vw where 1=0;
-------------------------------------------------
-------------------------------------------------
create or replace view bal_le_his_vw as
select 
	6 as bac, --LE Process
	guid.ba_code,
	upper('latest_estimate_his') as table_name_his,
	--prg.name as program_name,
	prj.program_id,
	prj.name as project_name,
	prj.code as project_code,
	prj.id as project_id,
	guid.create_date,
	null as change_comment,
	guid.user_id as log_user_id,
	max(le.rid||le.startscn||le.endscn) as id,
	guid.id as gu_id
from latest_estimate_his le
join sys_guid_transaction tr on (le.xid = tr.transaction_id)
join sys_guid guid on (guid.id=tr.guid)
join project prj on prj.id = le.project_id 
--join program prg on prg.id = prj.program_id
where guid.ba_code in (
	'estimatesprocessdelete',
	'estimatesprocessstart',
	'estimatesprocessterminate',
	'estimatesprocessupdate',
	'estimatesprovide',
	'estimatestagmeetingfinalize',
	'estimatestagcreate',
	'estimatestagfreeze')
group by
	guid.ba_code,
	--prg.name,
	prj.program_id,
	prj.name,
	prj.code,
	prj.id,
	guid.create_date,
	guid.user_id,
	guid.id
;
-------------------------------------------------
-------------------------------------------------
create or replace view bal_le_tag_his_vw as
select * from bal_project_audit_his_vw where 1=0;
-------------------------------------------------
-------------------------------------------------
create or replace view bal_le_tag_his_vw as
select 
	6 as bac, --LE Process
	guid.ba_code,
	upper('latest_estimates_tag_his') as table_name_his,
	--prg.name as program_name,
	prj.program_id,
	prj.name as project_name,
	prj.code as project_code,
	prj.id as project_id,
	guid.create_date,
	null as change_comment,
	guid.user_id as log_user_id,
	max(let.rid||let.startscn||let.endscn||rawtohex(prj.id)) as id,
	guid.id as gu_id
from latest_estimates_tag_his let
join sys_guid_transaction tr on (let.xid = tr.transaction_id)
join sys_guid guid on (guid.id=tr.guid)
join latest_estimates_process lep on lep.let_id=let.id
join latest_estimate le on le.process_id = lep.id
join project prj on prj.id = le.project_id
--join program prg on prg.id = prj.program_id
where guid.ba_code in (
	'estimatesprocessdelete',
	'estimatesprocessstart',
	'estimatesprocessterminate',
	'estimatesprocessupdate',
	'estimatesprovide',
	'estimatestagmeetingfinalize',
	'estimatestagcreate',
	'estimatestagfreeze')
group by
	guid.ba_code,
	--prg.name,
	prj.program_id,
	prj.name,
	prj.code,
	prj.id,
	guid.create_date,
	guid.user_id,
	guid.id
;
-------------------------------------------------
-------------------------------------------------
create or replace view bal_ltc_instance_his_vw as
select * from bal_project_audit_his_vw where 1=0;
-------------------------------------------------
-------------------------------------------------
create or replace view bal_ltc_instance_his_vw as
select 
	7 as bac, --LTC planning
	guid.ba_code,
	upper('ltc_instance_his') as table_name_his,
	--prg.name as program_name,
	prj.program_id,
	prj.name as project_name,
	prj.code as project_code,
	prj.id as project_id,
	guid.create_date,
	null as change_comment,
	guid.user_id as log_user_id,
	max(li.rid||li.startscn||li.endscn) as id,
	guid.id as gu_id
from ltc_instance_his li
join sys_guid_transaction tr on (li.xid = tr.transaction_id)
join sys_guid guid on (guid.id=tr.guid)
join project prj on prj.id = li.project_id
--join program prg on prg.id = prj.program_id
where guid.ba_code = 'ltcprovide'
group by
	guid.ba_code,
	--prg.name,
	prj.program_id,
	prj.name,
	prj.code,
	prj.id,
	guid.create_date,
	guid.user_id,
	guid.id
;
-------------------------------------------------
-------------------------------------------------
create or replace view bal_plan_assumption_his_vw as
select * from bal_project_audit_his_vw where 1=0;
-------------------------------------------------
-------------------------------------------------
create or replace view bal_plan_assumption_his_vw as
select 
	8 bac, --Planning Assumptions Request
	guid.ba_code,
	upper('plan_assumption_request_his') as table_name_his,
	--null as program_name,
	null as program_id,
	null as project_name,
	null as project_code,
	null as project_id,
	guid.create_date,
	null as change_comment,
	guid.user_id as log_user_id,
	max(par.rid||par.startscn||par.endscn) as id,
	guid.id as gu_id
from plan_assumption_request_his par 
join sys_guid_transaction tr on (par.xid = tr.transaction_id)
join sys_guid guid on (guid.id=tr.guid)
group by
	guid.ba_code,
	guid.create_date,
	guid.user_id,
	guid.id
;
-------------------------------------------------
-------------------------------------------------
create or replace view bal_reference_his_vw as
select * from bal_project_audit_his_vw where 1=0;
-------------------------------------------------
-------------------------------------------------
create or replace view bal_reference_his_vw as
select 
	9 bac, --References
	guid.ba_code,
	upper('reference_his') as table_name_his,
	--null as program_name,
	null as program_id,
	null as project_name,
	null as project_code,
	null as project_id,
	guid.create_date,
	null as change_comment,
	guid.user_id as log_user_id,
	max(re.rid||re.startscn||re.endscn) as id,
	guid.id as gu_id
from reference_his re 
join sys_guid_transaction tr on (re.xid = tr.transaction_id)
join sys_guid guid on (guid.id=tr.guid)
group by
	guid.ba_code,
	guid.create_date,
	guid.user_id,
	guid.id
;
-------------------------------------------------
-------------------------------------------------
create or replace view bal_program_sandbox_his_vw as
select * from bal_project_audit_his_vw where 1=0;
-------------------------------------------------
-------------------------------------------------
create or replace view bal_program_sandbox_his_vw as
select
	10 as bac, --Sandbox Plan
	guid.ba_code,
	upper('program_sandbox_his') as table_name_his,
	--prg.name as program_name,
	ps.program_id,
	null as project_name,
	null as project_code,
	null as project_id,
	guid.create_date,
	null as change_comment,
	guid.user_id as log_user_id,
	max(ps.rid||ps.startscn||ps.endscn) as id,
	guid.id as gu_id
from program_sandbox_his ps
join sys_guid_transaction tr on (ps.xid = tr.transaction_id)
join sys_guid guid on (guid.id=tr.guid)
--join program prg on prg.id = ps.program_id
where guid.ba_code in ('sandboxplancreate','sandboxplandelete','sandboxplanmodify')
group by
	guid.ba_code,
	--prg.name,
	ps.program_id,
	guid.create_date,
	guid.user_id,
	guid.id
;
-------------------------------------------------
-------------------------------------------------
create or replace view bal_timeline_his_vw as
select * from bal_project_audit_his_vw where 1=0;
-------------------------------------------------
-------------------------------------------------
create or replace view bal_timeline_his_vw as
select
	10 as bac, --Sandbox Plan
	guid.ba_code,
	upper('timeline_his') as table_name_his,
	--prg.name as program_name,
	prj.program_id,
	prj.name as project_name,
	prj.code as project_code,
	prj.id as project_id,
	guid.create_date,
	null as change_comment,
	guid.user_id as log_user_id,
	max(tl.rid||tl.startscn||tl.endscn) as id,
	guid.id as gu_id
from timeline_his tl
join sys_guid_transaction tr on (tl.xid = tr.transaction_id)
join sys_guid guid on (guid.id=tr.guid)
join project prj on prj.id = tl.project_id
--join program prg on prg.id = prj.program_id
where guid.ba_code in ('sandboxplancreate','sandboxplandelete','sandboxplanmodify','sandboxplanimportactuals')
group by
	guid.ba_code,
	--prg.name,
	prj.program_id,
	prj.name,
	prj.code,
	prj.id,
	guid.create_date,
	guid.user_id,
	guid.id
;
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
create or replace view global_ba_log_guid_vw as
select 
	1 bac,
	'x' ba_code,
	'x' table_name_his,
	'x' program_name,
	'x' program_id,
	'x' project_name,
	'x' project_code,
	'x' project_id,
	sysdate create_date,
	'x' change_comment,
	'x' log_user_id,
	'x' id,
	'x' gu_id
from dual
;
-------------------------------------------------
-------------------------------------------------
create or replace view global_ba_log_guid_vw as
select 
	ba.bac,
	ba.ba_code,
	ba.table_name_his,
	prgm.name as program_name,
	ba.program_id,
	ba.project_name,
	ba.project_code,
	ba.project_id,
	ba.create_date,
	ba.change_comment,
	ba.log_user_id,
	substr(ba.id,1,124) as id,
	gu_id
from (
	-------------------------------------------------
	select * from bal_program_his_vw
	-------------------------------------------------
		union all
	-------------------------------------------------
	select * from bal_project_his_vw
	-------------------------------------------------
		union all
	-------------------------------------------------
	select * from bal_tpp_his_vw
	-------------------------------------------------
		union all
	-------------------------------------------------
	select * from bal_goal_his_vw
	-------------------------------------------------
		union all
	-------------------------------------------------
	select * from bal_le_process_his_vw
	-------------------------------------------------
		union all
	-------------------------------------------------
	select * from bal_le_his_vw
	-------------------------------------------------
		union all
	-------------------------------------------------
	select * from bal_le_tag_his_vw
	-------------------------------------------------
		union all
	-------------------------------------------------
	select * from bal_ltc_instance_his_vw
	-------------------------------------------------
		union all
	-------------------------------------------------
	select * from bal_plan_assumption_his_vw
	-------------------------------------------------
		union all
	-------------------------------------------------
	select * from bal_reference_his_vw
	-------------------------------------------------
		union all
	-------------------------------------------------
	select * from bal_program_sandbox_his_vw
	-------------------------------------------------
		union all
	-------------------------------------------------
	select * from bal_timeline_his_vw
	-------------------------------------------------
		union all
	-------------------------------------------------
	select * from bal_project_audit_his_vw
	-------------------------------------------------
) ba left join program prgm on prgm.id = ba.program_id
;
	/*
-------------------------------------------------
	union all
-------------------------------------------------
select 
	--10=Sandbox Plan, 5=Project Timeline
	decode(guid.ba_code,'sandboxplanimportplan',10,5) bac,
	guid.ba_code,
	upper('import_his') as table_name_his,
	prg.name as program_name,
	prg.code as program_id,
	prj.name as project_name,
	prj.code as project_code,
	prj.id as project_id,
	guid.create_date,
	null as change_comment,
	guid.user_id as log_user_id,
	max(im.rid||im.startscn||im.endscn) as id
from import_his im
join sys_guid_transaction tr on (im.xid = tr.transaction_id)
join sys_guid guid on (guid.id=tr.guid)
join project prj on prj.id = im.project_id
join program prg on prg.id = prj.program_id
--
where guid.ba_code in ('importstudyDEL','importtimelinefpsDEL','importtimelineplansophiaDEL','sandboxplanimportplan')
group by
	decode(guid.ba_code,'sandboxplanimportplan',10,5),
	guid.ba_code,
	prg.name,
	prg.code,
	prj.name,
	prj.code,
	prj.id,
	guid.create_date,
	guid.user_id
	*/
prompt
prompt 