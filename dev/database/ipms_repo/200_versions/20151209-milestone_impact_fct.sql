create table milestone_impact_fct as
select 
	project_id,
	study_id,
	study_element_id,
	plan_start_date,
	act_start_date,
	plan_finish_date,
	act_finish_date
from ipms_data.sophia_timeline_flat_vw;

grant select on milestone_impact_fct to mycsd;