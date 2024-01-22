create or replace view prj_ptr_values_vw as
--
-- Project-specific and default PTR values (probabilities) for each 
-- project / phase combination in one view. 
--
-- Default PTR values (probabilities) are selected using project properties
-- like SBE and Substance Type.
-- 
-- Includes only 5 main phases (preclinical, phases 1-3 and submission.
--
with default_cp as (
	select 
		prj.id as project_id,
		phase.code as phase_code,
		phase.name as phase_name,
		phase.ordering as phase_ordering,
		prj.sbe_code,
		prj.substance_type_code,
		cp.probability as default_probability,
		row_number() over(partition by prj.id, phase.code order by cp.sbe_code, cp.substance_type_code) as rowno
	from 
		project prj
		cross join phase
		left join costs_probability cp on cp.scope_code='INT'
			and cp.phase_code = phase.code 
			and cp.project_id is null 
				and (cp.sbe_code = prj.sbe_code or cp.sbe_code is null) 
				and (cp.substance_type_code = prj.substance_type_code or cp.substance_type_code is null)
	where phase.code in ('1', '2', '34', '5', '6')
)
select 
	default_cp.project_id, 
	default_cp.phase_code, 
	default_cp.phase_name, 
	default_cp.phase_ordering, 
	default_cp.sbe_code, 
	default_cp.substance_type_code, 
	default_cp.default_probability,
	project_cp.probability,
	project_cp.id project_cp_id,
	project_cp.create_date,
	project_cp.create_user_id,
	project_cp.scope_code,
	project_cp.update_date,
	project_cp.update_user_id
from default_cp
left join costs_probability project_cp on project_cp.scope_code='INT'
	and project_cp.project_id = default_cp.project_id
	and project_cp.phase_code = default_cp.phase_code
where default_cp.rowno = 1
order by default_cp.project_id, default_cp.phase_ordering;
