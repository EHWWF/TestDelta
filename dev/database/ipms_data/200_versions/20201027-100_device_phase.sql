create table device_phase (
	code varchar2(20) constraint device_phase_pk primary key constraint device_phase_code_cnn not null,
	name varchar2(100) constraint device_phase_name_cnn not null,
	is_active number(1) default 1 constraint device_phase_is_active_cnn not null constraint device_phase_active_chk check(is_active in (0,1)),
	create_date date constraint device_phase_create_date_cnn not null,
	update_date date constraint device_phase_update_date_cnn not null
);
------------
comment on table device_phase is 'Lookup table for Project Device Phase Code field.';
comment on column device_phase.code is 'PK.';
comment on column device_phase.is_active is 'The value is being set by ProMIS Administrator by using dedicated UI in ProMIS.';
------------
create or replace trigger device_phase_biu_tr
before insert or update on device_phase for each row
  begin
    if inserting then
      :new.create_date := sysdate;
	end if;
	:new.update_date := sysdate;
	:new.code := replace(upper(:new.code),' ');
  end;
/
------------
alter table project add (device_phase_code varchar2(20) constraint project_device_phase_fk references device_phase(code));
create index project_device_phase_fki on project(device_phase_code);
comment on column project.device_phase_code is 'Reference to the table: device_phase. The field was added based on reqeirement: PROMIS-566';