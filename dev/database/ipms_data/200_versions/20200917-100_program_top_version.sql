alter table program_top_version add (project_id nvarchar2(20), constraint prg_top_version_prj_fk foreign key (project_id) references project(id) on delete cascade);
create index prg_top_version_prj_fki on program_top_version(project_id);
comment on column program_top_version.project_id is 'Reference to the table: project. Reference is not mandatory but if provided then progtram_id should be skipped or even could be null: PROMIS-562';
alter table program_top_version modify (program_id null);
alter table program_top_version add constraint prg_top_version_prj_prg_cnn check(project_id||program_id is not null);
drop index PRG_TOP_VER_NR_UI;
create unique index PRG_TOP_VER_NR_UI on program_top_version(PROGRAM_ID, PROJECT_ID, VERSION_NR);
drop index PROGRAM_TOP_VERSION_UI;
create unique index PROGRAM_TOP_VERSION_UI on program_top_version(PROGRAM_ID, PROJECT_ID, REPLACE("VERSION",'previous',TO_CHAR("ID")));