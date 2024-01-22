create table project_planning_code (
	code nvarchar2(20) constraint project_pc_pk primary key constraint project_pc_code_cnn not null,
	name nvarchar2(100) constraint project_pc_name_cnn not null,
	is_active number(1) default 1 constraint project_pc_is_active_cnn not null constraint project_pc_active_chk check(is_active in (0,1)),
	create_date date constraint project_pc_create_date_cnn not null,
	update_date date constraint project_pc_update_date_cnn not null
);
------------
comment on table project_planning_code is 'Lookup table for Project Planning Code field.';
comment on column project_planning_code.code is 'PK.';
comment on column project_planning_code.is_active is 'The value is being set by ProMIS Administrator by using dedicated UI in ProMIS.';
------------
create or replace trigger project_planning_code_biu_tr
before insert or update on project_planning_code for each row
  begin
    if inserting then
      :new.create_date := sysdate;
	end if;
	
	:new.update_date := sysdate;
  end;
/
------------
begin
for rr in (select code, name, is_active from project where code in
(select PLANNING_CODE from project group by PLANNING_CODE)
order by 1)
loop
begin
insert into project_planning_code (code, name, is_active)
values (rr.code, rr.name, rr.is_active);
commit;
exception when others then null;
end;
end loop;
end;
/
------------
alter table project add constraint project_planning_code_fk foreign key (planning_code) references project_planning_code(code);
create index project_planning_code_fki on project(planning_code);
comment on column project.planning_code is 'Reference to the table: project_planning_code. The field was modified based on reqeirement: PROMIS-524';