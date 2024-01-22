create or replace view prj_milestone_factors_vw as
with 
	projectlist as (
		select
		id as project_id,
		name as project_name,
		code as project_code,
		area_code         
		from project where area_code in ('D2-PRJ','PRE-POT','POST-POT')
	),         
	projectfactors as
	(select
		id,
		project_id,         
		milestone_code,         
		goal_factor         
	from project_goal_factor
	),
	d1ProjDecisionList as ( 
	select
		id as project_id,
		name as project_name,
		code as project_code,
		area_code
	from project
	where area_code in ('D1')  
	and d1_decision_date is not null
	),
	d1ProjTerminationList as (
	select
		id as project_id,
		name AS project_name,
		code AS project_code,
		area_code
	from project
	where area_code in ('D1','D2-PRJ','PRE-POT','POST-POT')
	and termination_date is not null
	)
--D2, DEV
select
	ta.project_id || '-' ||ta.milestone_code as id,
	ta.project_id,
	ta.milestone_code as milestone_type,
	nvl(projectfactors.goal_factor,1) as factor,
	projectlist.project_code,
	projectlist.area_code,
	projectlist.project_name,
	decode( nvl(projectfactors.goal_factor,1), 1, 0, 1 ) as srch_exception,
	nvl(projectfactors.id,-1) as factorflag
from timeline_activity ta         
join projectlist on projectlist.project_id = ta.project_id
left join projectfactors on ta.project_id = projectfactors.project_id and ta.milestone_code = projectfactors.milestone_code
where ta.type in ('Start Milestone','Finish Milestone')
and ta.timeline_type_code = 'CUR'
and ta.milestone_code is not null
and ta.milestone_code <>'Termn'--goes with separte SELECT based on terminationDate from PROJECT table
group by projectlist.area_code,
			projectfactors.id,
			ta.project_id,
			projectlist.project_code,
			projectlist.project_name,
			ta.milestone_code,
			projectfactors.goal_factor
--D1 Decision
union all
select
	d1ProjDecisionList.project_id || '-D1' as id,
	d1ProjDecisionList.project_id,
	'D1' as milestone_type,
	Nvl(D1PrjDecFct.goal_factor,1) AS factor,
	d1ProjDecisionList.project_code,         
	d1ProjDecisionList.area_code,
	d1ProjDecisionList.project_name,
	decode( Nvl(D1PrjDecFct.goal_factor,1), 1, 0, 1 ) as srch_exception,
	nvl(d1prjdecfct.id,-1) as factorflag
from d1projdecisionlist
left join projectfactors d1prjdecfct on d1projdecisionlist.project_id = d1prjdecfct.project_id and d1prjdecfct.milestone_code = 'D1'
--D1 Termination
union all
select 
	d1ProjTerminationList.project_id || '-Termn',
	d1ProjTerminationList.project_id,
	'Termn' as milestone_type,
	Nvl(D1PrjTermFct.goal_factor,1) AS factor,
	d1ProjTerminationList.project_code,         
	d1ProjTerminationList.area_code,
	d1ProjTerminationList.project_name,
	decode( Nvl(D1PrjTermFct.goal_factor,1), 1, 0, 1 ) as srch_exception,
	nvl(d1prjtermfct.id,-1) as factorflag
from d1projterminationlist
left join projectfactors d1prjtermfct on d1projterminationlist.project_id = d1prjtermfct.project_id and D1PrjTermFct.milestone_code = 'Termn';