create or replace view global_ba_log_vw as
select 
	ba.category_id as bac,
	sg.ba_code,
	--sg.ba_code as table_name_his,
	prg.name as program_name,
	prg.id as program_id,
	prj.name as project_name,
	prj.code as project_code,
	prj.id as project_id,
	sg.create_date,
	null as change_comment,
	sg.user_id as log_user_id,
	sg.id,
	sg.description,
	sg.status_code
from sys_guid sg
join business_activity ba on (sg.ba_code=ba.code)
join project prj on (sg.project_id=prj.id)
join program prg on (prj.program_id=prg.id)
where sg.ba_code in
					(
					--'estimatesprovide',
					'goalscreate',
					'goalsdelete',
					'goalsedit',
					'importstudy',
					'autoimportstudy',
					'importtimelinefps',
					'importtimelineplansophia',
					'ltcprovide',
					'planningassumptionsprovide',
					'projectcreate',
					'projectdelete',
					'projectedit',
					'projecteditid',
					'projectimportd1',
					'projectlead',
					'projectmove',
					'projectrelease',
					'projecttypify',
					'timelinepublish',
					'tppedit',
					'maintainbaselines'--,
					--'estimatesprovideltc'
					)
-------------------------------------------------
	union all
-------------------------------------------------
select 
	ba.category_id as bac,
	sg.ba_code,
	--sg.ba_code as table_name_his,
	prg.name as program_name,
	prg.id as program_id,
	null as project_name,
	null as project_code,
	null as project_id,
	sg.create_date,
	null as change_comment,
	sg.user_id as log_user_id,
	sg.id,
	sg.description,
	sg.status_code
from sys_guid sg
join business_activity ba on (sg.ba_code=ba.code)
left join program prg on (sg.program_id=prg.id)
where sg.ba_code in
					(
					'programcreate',
					'programdelete',
					'programedit',
					'programroles',
					'sandboxplancreate',
					'programteam'
					)
-------------------------------------------------
	union all
-------------------------------------------------
-- empty no project no program
select 
	ba.category_id as bac,
	sg.ba_code,
	--sg.ba_code as table_name_his,
	null as program_name,
	null as program_id,
	null as project_name,
	null as project_code,
	null as project_id,
	sg.create_date,
	null as change_comment,
	sg.user_id as log_user_id,
	sg.id,
	sg.description,
	sg.status_code
from sys_guid sg
join business_activity ba on (sg.ba_code=ba.code)
where sg.ba_code in
					(
					'estimatesprocessdelete',
					'estimatesprocessstart',
					'estimatesprocessterminate',
					'estimatesprocessupdate',
					'estimatesprovide', --has project ID ? not in 2018 and 2019, only in 2017
					'estimatestagcreate',
					'estimatestagmeetingfinalize',
					'planningassumptionsstart',
					'referencesmaintain',
					'estimatesprocessstartltc',
					'estimatesprocessterminateltc',
					'estimatesprocessupdateltc',
					'estimatestagcreateltc',
					'importareacodeco',
					'importareacoded1',
					'importareacoded2prj',
					'importareacoded3tr',
					'importareacodelg',
					'importareacodelo',
					'importareacodepostpot',
					'importareacodeprdmnt',
					'importareacodeprepot',
					'importareacoders',
					'importbegin',
					'importcleanup',
					'importend',
					'importloggedchangesemail',
					'importreleasedcompletedpidtemail',
					'estimatesprovideltc',
					'estimatestagfreezeltc',
					'estimatestagprefillltc'
					)
-------------------------------------------------
	union all
-------------------------------------------------
select 
	cast ('11' as nvarchar2(20)) as bac,-- FPS
	cast ('messagefps' as nvarchar2(30)) as ba_code,
	--cast ('project_audit' as nvarchar2(30)) as table_name_his,
	prg.name as program_name,
	p.program_id,
	p.name as project_name,
	p.code as project_code,
	p.id as project_id,
	pa.create_date,
	pa.change_comment,
	cast ('PROMIS' as nvarchar2(30)) as log_user_id,
	pa.id,
	null description,
	null status_code
from project_audit pa
join project p on p.id=pa.project_id
join program prg on prg.id = p.program_id
where (upper(record_type) = upper('FPS'))
;