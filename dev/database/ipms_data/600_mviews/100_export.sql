drop materialized view export_masterdata_project_vw;

create materialized view export_masterdata_project_vw as
select 
	program_id,
	id,
	code,
	name,
	state_code,
	priority_code,
	area_code,
	substance_type_code,
	source_code,
	phase_code,
	category_code,
	is_portfolio,
	is_collaboration,
	is_hpr,
	enpv,
	npv,
	peak_sales,
	create_date,
	ipowner_code,
	is_active,
	description,
	termination_date,
	trg_code,
	trg,
	er,
	target_gene_code,
	start_hts_date,
	general_project_frame,
	lsa_date,
	d2_compound,
	--phase_estimated_code,
	--details_partner
	lc_type_code,
	lc_type_id,
	subgroup_code,
	subgroup_id	
from(
	select
		row_number() over(partition by prj.code order by nvl(prj.area_code,'1') desc) as rank,
		prg.id program_id,
		prj.id,
		prj.code,
		prj.name,
		prj.state_code,
		prj.priority_code,
		prj.area_code,
		prj.substance_type_code,
		prj.source_code,
		prj.phase_code,
		decode(prj.category_code,'ME','NM',prj.category_code) category_code,
		prj.is_portfolio,
		prj.is_collaboration,
		prj.is_hpr,
		prj.enpv,
		prj.npv,
		prj.peak_sales,
		prj.create_date,
		prj.ipowner_code,
		prj.is_active,
		prj.description,
		prj.termination_date,
		id1.trg_code,--ProMIS is not using this column, so, for exporting just take from the source
		prj.trg,
		prj.er,
		prj.target_gene_code,
		prj.start_hts_date,
		prj.general_project_frame,
		prj.lsa_date,
		prj.d2_compound,
		--prj.phase_estimated_code,
		--prj.details_partner
		lct.code lc_type_code,
		lct.correlation_id lc_type_id,
		subc.code subgroup_code,
		subc.correlation_id subgroup_id
		from project prj
	left join program prg on (prj.program_id=prg.id) and prg.code not like 'RESERVED-PT%'
	left join (select distinct trg,trg_code from import_d1 where trg is not null) id1 on (prj.trg=id1.trg)
	left join project_category lct on (lct.code=prj.category_code and lct.is_promis=1)
	left join project_category subc on (subc.code=prj.project_group_code and subc.is_promis=0)
	where prj.pidt_release_date is not null
	and prj.program_id<>'RBIN'
) where rank=1 --take only one project for selected: code=projectId ---- PROMISIII-297
;

grant select on export_masterdata_project_vw to mxcbi;
grant select on export_masterdata_project_vw to mycsd;


drop materialized view export_masterdata_program_vw;

create materialized view export_masterdata_program_vw as
select
	prg.id,
	prg.code,
	prg.name
from program prg
where id<>'RBIN'
and prg.code not like 'RESERVED-PT%'
and exists(
select id from project prj
where prj.program_id=prg.id
and prj.pidt_release_date is not null
and prj.program_id<>'RBIN'
);

grant select on export_masterdata_program_vw to mxcbi;
grant select on export_masterdata_program_vw to mycsd;


drop materialized view export_ingredient_vw;

create materialized view export_ingredient_vw as
select
	SUBSTR(api.substance_code, 1, 10) substance_code,
	prj.id as project_id,
	prj.code as project_code
from ingredient_vw api
join project prj on prj.id=api.project_id
where prj.pidt_release_date is not null
and prj.program_id<>'RBIN';

grant select on export_ingredient_vw to mxcbi;
grant select on export_ingredient_vw to mycsd;


drop materialized view export_member_vw;

create materialized view export_member_vw as
select
	tm.employee_code,
	tm.role_code,
	prj.id as project_id,
	prj.code as project_code
from member_vw tm
join project prj on prj.id=tm.project_id and prj.program_id = tm.program_id
where prj.pidt_release_date is not null
and prj.program_id<>'RBIN';

grant select on export_member_vw to mxcbi;
grant select on export_member_vw to mycsd;


drop materialized view export_plan_milestone_vw;

create materialized view export_plan_milestone_vw as
select
	ml.code milestone_code,
	ml.type_code as milestone_type_code,
	reg.code as region_code,
	tm.plan_date,
	tm.actual_date,
	prj.id as project_id,
	prj.code as project_code
from milestone_vw tm
join milestone ml on ml.code=tm.milestone_code
left join region reg on tm.milestone_code like reg.code||'-%'
join project prj on prj.id=tm.project_id
where ml.type_code in ('DEC','DEV','REG') and tm.timeline_type_code='CUR'
and prj.pidt_release_date is not null
and milestone_code!='DMC' --PROMISIII-439
and prj.program_id<>'RBIN'
	union all
select
	prj.area_code as milestone_code,
	to_nchar('DEC') as milestone_type_code,
	null as region_code,
	null as plan_date,
	prj.d1_decision_date as actual_date,
	prj.id as project_id,
	prj.code as project_code
from ipms_data.project prj
where prj.d1_decision_date is not null
and prj.area_code='D1'
and prj.pidt_release_date is not null
and prj.program_id<>'RBIN'
;

grant select on export_plan_milestone_vw to mxcbi;
grant select on export_plan_milestone_vw to mycsd;


drop materialized view export_project_state_vw;

create materialized view export_project_state_vw as
select code,name,description,is_active
from project_state;

grant select on export_project_state_vw to mxcbi;
grant select on export_project_state_vw to mycsd;




drop materialized view export_priority_vw;

create materialized view export_priority_vw as
select code,name,description,is_active
from priority;

grant select on export_priority_vw to mxcbi;
grant select on export_priority_vw to mycsd;




drop materialized view export_therapeutic_area_vw;

create materialized view export_therapeutic_area_vw as
select code,name,description,is_active
from project_state;

grant select on export_therapeutic_area_vw to mxcbi;
grant select on export_therapeutic_area_vw to mycsd;





drop materialized view export_project_source_vw;

create materialized view export_project_source_vw as
select code,name,description,is_active
from project_source;

grant select on export_project_source_vw to mxcbi;
grant select on export_project_source_vw to mycsd;




drop materialized view export_project_category_vw;
create materialized view export_project_category_vw as
select code,name,description,is_active
from project_category
where code<>'ME';
/*
exception: ME (Molecular Entity) does not exist in the PIDT. This lookup can be mapped to NM (New Molecule).
assumption: NM always exists
is_promis=1 -> means, we export only the position that are being maintain in ProMIS as LC type. BAY_PROMIS-439
*/
grant select on export_project_category_vw to mxcbi;
grant select on export_project_category_vw to mycsd;



drop materialized view export_milestone_type_vw;

create materialized view export_milestone_type_vw as
select code,name,is_active
from milestone_type;

grant select on export_milestone_type_vw to mxcbi;
grant select on export_milestone_type_vw to mycsd;


drop materialized view export_project_phase_vw;

create materialized view export_project_phase_vw as
select code,name,ordering,is_active
from phase
where code in('1','2','3','4','5','7','9','11','12','15');

grant select on export_project_phase_vw to mxcbi;
grant select on export_project_phase_vw to mycsd;




drop materialized view export_region_vw;

create materialized view export_region_vw as
select code,name,description,is_active
from region;

grant select on export_region_vw to mxcbi;
grant select on export_region_vw to mycsd;




drop materialized view export_milestone_vw;

create materialized view export_milestone_vw as
select code,name,type_code,is_active
from milestone;

grant select on export_milestone_vw to mxcbi;
grant select on export_milestone_vw to mycsd;



drop materialized view export_roles_vw;

create materialized view export_roles_vw as
select
	tm.code,
	tm.name,
	tm.description
from team_role tm
where tm.is_active=1;

grant select on export_roles_vw to mxcbi;
grant select on export_roles_vw to mycsd;




drop materialized view export_project_area_vw;

create materialized view export_project_area_vw as
select code, name, is_active, description from project_area;

grant select on export_project_area_vw to mxcbi;
grant select on export_project_area_vw to mycsd;



-- Target Product Profile (TPP) export views

drop materialized view export_tpp_category;

create materialized view export_tpp_category as
select 
	code as category_code, 
	name as category_name,
	description as category_description,
	is_active,
	modify_date
from tpp_category;

grant select on export_tpp_category to mxcbi;
grant select on export_tpp_category to mycsd;



drop materialized view export_tpp_subcategory;

create materialized view export_tpp_subcategory as
select
	code as subcategory_code,
	name as subcategory_name,
	description as subcategory_description,
	category_code,
	is_active,
	modify_date
from tpp_subcategory;

grant select on export_tpp_subcategory to mxcbi;
grant select on export_tpp_subcategory to mycsd;



drop materialized view export_tpp_header;

create materialized view export_tpp_header as
select
	tpp.id as tpp_id,
	tpp.name as tpp_name,
	to_number(prj.code) as project_id,
	tpp.version as tpp_version_id,
	tpp.description as tpp_description,
	tpp.indication as tpp_indication,
	tpp.references,
	tpp.approval_date,
	tpp.create_user_id,
	tpp.update_user_id,
	tpp.create_date,
	tpp.update_date
from target_product_profile tpp
join project prj on (tpp.project_id=prj.id and REGEXP_LIKE(prj.code, '^[[:digit:]]+$'));

grant select on export_tpp_header to mxcbi;
grant select on export_tpp_header to mycsd;



drop materialized view export_tpp_values;

create materialized view export_tpp_values as
select
	tppv.id as tpp_value_id,
	tppv.tpp_id,
	tppv.subcategory_code,
	tppv.key_edv_proposition,
	tppv.standard_of_care,
	tppv.targeted_profile,
	tppv.upside,
	tppv.targeted_in,
	tppv.key_driver,
	tppv.unique_selling_point,
	tppv.create_user_id,
	tppv.update_user_id,
	tppv.create_date,
	tppv.update_date	
from tpp_values tppv
join target_product_profile tpp on (tppv.tpp_id=tpp.id)
join project prj on (tpp.project_id=prj.id and REGEXP_LIKE(prj.code, '^[[:digit:]]+$'));

grant select on export_tpp_values to mxcbi;
grant select on export_tpp_values to mycsd;



-- Goal tracking materialized views

drop materialized view export_goal;

create materialized view export_goal as
select 
	id as goal_id,
	goal as goal_name
from goal;

grant select on export_goal to mxcbi;
grant select on export_goal to mycsd;



drop materialized view export_goal_fct;

create materialized view export_goal_fct as
select
	g.id as goal_id,
	to_number(prj.code) as project_id,
	to_number(prg.code) as program_id,
	g.type as type_code,
	g.phase as phase_code,
	g.plan_reference,
	g.plan_reference_date,
	to_number(g.status) as status_id,
	g.target_date,
	g.achieved_date,
	g.revised_date
from goal g
join project prj on (g.project_id=prj.id and regexp_like(prj.code, '^[[:digit:]]+$'))
join program prg on (prj.program_id=prg.id and REGEXP_LIKE(prg.code, '^[[:digit:]]+$'));

grant select on export_goal_fct to mxcbi;
grant select on export_goal_fct to mycsd;



drop materialized view export_goal_type;

create materialized view export_goal_type as
select
	type as goal_type_code,
	substr(decode(type, N'T', N'Team Goal', N'K', N'Key Goal','DC','ODC/TA Goal', N'B', N'BHC Goal', type),1,20) as goal_type_name
from (
	select N'T' as type from dual
	union
	select N'K' as type from dual
	union
	select N'B' as type from dual
	union
	select N'DC' as type from dual
	union
	select distinct type from goal
);

grant select on export_goal_type to mxcbi;
grant select on export_goal_type to mycsd;



drop materialized view export_goal_phase;

create materialized view export_goal_phase as
select 
	phase as goal_phase_code,
	substr(decode(phase, N'S', N'Goal Setup', N'T', N'Goal Tracking', phase),1,20) as goal_phase_name
from (
	select N'S' as phase from dual 
	union
	select N'T' as phsae from dual 
	union
	select distinct phase from goal
);

grant select on export_goal_phase to mxcbi;
grant select on export_goal_phase to mycsd;



drop materialized view export_goal_status;

create materialized view export_goal_status as
select
	to_number(code) as goal_status_id,
	substr(name,1,20) as goal_status_name
from goal_status;

grant select on export_goal_status to mxcbi;
grant select on export_goal_status to mycsd;