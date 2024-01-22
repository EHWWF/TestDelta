create table project_modality (
	code nvarchar2(20) constraint project_mod_pk primary key constraint project_mod_code_cnn not null,
	name nvarchar2(100) constraint project_mod_name_cnn not null,
	is_active number(1) default 1 constraint project_mod_is_active_cnn not null constraint project_mod_active_chk check(is_active in (0,1)),
	create_date date default sysdate constraint project_mod_create_date_cnn not null,
	update_date date default sysdate constraint project_mod_update_date_cnn not null
);
------------
comment on table project_modality is 'Lookup table for Project Modality field.';
comment on column project_modality.code is 'PK.';
comment on column project_modality.is_active is 'The value is being set by ProMIS Administrator by using dedicated UI in ProMIS.';
------------
create or replace trigger project_modality_biu_tr
before insert or update on project_modality for each row
  begin
    if inserting then
      :new.create_date := sysdate;
	end if;
	
	:new.update_date := sysdate;
	:new.code := replace(upper(:new.code),' '); --clean CODE
  end;
/