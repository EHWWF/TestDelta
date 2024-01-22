drop materialized view project_substance_dim;

create materialized view project_substance_dim as
select
    ingredient.project_id || '-' || ingredient.substance_code as id,
    ingredient.project_id as project_id,
    substr(ingredient.substance_code,1,120) as active_pharm_ingredient_code,
    substance.name as active_pharm_ingredient,
    molecular.name as smallest_mol_entity,
    cv.combination_name as combination_id,
    prefbay.name as pref_bay_no
from (
		select 
			ing.*, 
			prj.bay_code as pref_bay_code 
		from ipms_data.ingredient_vw ing, ipms_data.project prj 
		where prj.id=ing.project_id
		) ingredient
left join ipms_data.substance substance on substance.code = ingredient.substance_code
left join ipms_data.combination_vw cv on cv.project_id = ingredient.project_id
left join ipms_data.bay_number prefbay on prefbay.code = ingredient.pref_bay_code
left join ipms_data.molecular_entity molecular on molecular.substance_code = substance.code;

grant select on project_substance_dim to mycsd;