drop materialized view export_project_vw;
--Dedicated View for Sophia
create materialized view export_project_vw as
select
	id,
	code,
	name,
	is_collaboration,
	phase_estimated_code,
	details_partner,
	commercial_ta_code,
	commercial_ta_name,
	details_indication,
	is_device_project,
	project_device_type_code,
	regulatory_code,
	regulatory_other,
	details_modality,
	device_phase_code
from(
	select
		row_number() over(partition by prj.code order by nvl(prj.area_code,'1') desc) as rank,
		prj.id,
		prj.code,
		prj.name,
		prj.is_collaboration,
		prj.phase_estimated_code,
		prj.details_partner,
		prj.ta_code as commercial_ta_code, -- BAY_PROMIS-24
		ta.name as commercial_ta_name,
		prj.details_indication,
		prj.is_device_project,
		prj.project_device_type_code,
		prj.regulatory_code,
		prj.regulatory_other,
		--prj.details_modality,
		configuration_pkg.get_names_for_codes(prj.details_modality) details_modality,
		prj.device_phase_code
	from project prj
	left join program prg on (prj.program_id=prg.id and prg.code not like 'RESERVED-PT%')
	left join therapeutic_area ta on (prj.ta_code=ta.code)
	where prj.pidt_release_date is not null
	and prj.program_id<>'RBIN'
) where rank=1 --take only one project for selected: code=projectId ---- PROMISIII-297
;
grant select on export_project_vw to mxcbi;
grant select on export_project_vw to mycsd;