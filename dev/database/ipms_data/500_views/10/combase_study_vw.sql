create or replace view combase_study_vw as
select
	to_char(prj.pjx_no) as project_id,
	prjstd.stu_no as study_id,
	std.stu_name as study_name,
	ph.xph_name as study_phase,
	ph.xph_code as study_phase_code,
	to_nchar(decode(bc.bt_no,'0128','ED','0129','LD',bc.bt_no)) as budget_class,--must be doceded at source that ProMIS is avare of the meaning
	greatest(std.modify_date,stph.modify_date,stph.modify_date,prjstd.modify_date) as modify_date
from bdo_project@combase_db prj
join bdr_stu_pjx@combase_db prjstd on prjstd.pjx_no=prj.pjx_no and prjstd.status='ACTIVE'
join bdo_trial@combase_db std on std.stu_no=prjstd.stu_no and std.status='ACTIVE'
left join bdr_stu_xph@combase_db stph on stph.stu_no=std.stu_no and stph.status='ACTIVE'
left join bdo_phase@combase_db ph on ph.xph_no=stph.xph_no and ph.status='ACTIVE'
left join bdr_stu_bt_pp@combase_db bc on bc.stu_no=std.stu_no and bc.status='ACTIVE'
where prj.status='ACTIVE';