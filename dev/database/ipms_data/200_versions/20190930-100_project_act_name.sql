------------
create table import_project_activity_name (
	import_id varchar2(20) constraint imp_prj_act_name_impid_cnn not null,
	project_activity_id varchar2(100) constraint imp_prj_act_name_prjid_cnn not null,
	project_activity_name varchar2(240) constraint imp_prj_act_name_prjname_cnn not null,
	is_active number(1) default 1 constraint imp_prj_act_name_active_cnn not null, constraint imp_prj_act_name_active_ca check(is_active in (0,1)),
	status_code varchar2(10) default 'NEW' constraint imp_prj_act_name_status_cnn not null,
	status_description varchar2(500),			
	create_date date default sysdate constraint imp_prj_act_name_cdate_cnn not null
);
------------
comment on table import_project_activity_name is 'Table is being used for storing tmp data for project activity name. Table was created while implementing requirement: PROMIS-442';
comment on column import_project_activity_name.project_activity_id is 'Project activity ID from SOPHIA.';
comment on column import_project_activity_name.project_activity_name is 'Project activity name from SOPHIA.';
------------
create unique index imp_prj_act_name_impid_ui on import_project_activity_name(import_id,project_activity_id);
------------
create table project_activity_name (
	id varchar2(100) constraint prj_act_name_prjid_pk primary key,
	name varchar2(240) constraint prj_act_name_prjname_cnn not null,
	is_active number(1) default 1 constraint prj_act_name_active_cnn not null, constraint prj_act_name_active_ca check(is_active in (0,1)),			
	create_date date default sysdate constraint prj_act_name_cdate_cnn not null,
	update_date date default sysdate constraint prj_act_name_udate_cnn not null
);
------------
comment on table project_activity_name is 'Table is being used for suporting UI reports by mapping id to names. Table was created while implementing requirement: PROMIS-442';
comment on column project_activity_name.id is 'Project activity ID from SOPHIA.';
comment on column project_activity_name.name is 'Project activity name from SOPHIA.';
------------