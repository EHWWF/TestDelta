create table dis_study_mview as 
select
	to_nchar(tl.project_id) as project_id,
	to_nchar(tl.study_id) as study_id,
	to_nchar(tl.study_element_id) as study_element_id,
	tl.plan_start_date,
	tl.plan_finish_date,
	tl.act_start_date,
	tl.act_finish_date
from timeline@sophia_db tl
join combase_study_vw cmb on (cmb.project_id=to_char(tl.project_id) and cmb.study_id=to_char(tl.study_id));

alter table dis_study_mview add (create_date date default sysdate);
alter table dis_study_mview add (update_date date);

create unique index dis_study_mview_uidx on dis_study_mview (project_id,study_id,study_element_id);

comment on table dis_study_mview is 'The table is used for discrepancy performance only.';