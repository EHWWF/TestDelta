----DROP-obsolete-db-objects-from-first-implementation---
drop trigger program_top_values_tr;
drop sequence program_top_values_id_seq;
drop table program_top_values;
drop trigger program_top_tr;
drop sequence program_top_id_seq;
drop table program_top;
------------------
alter table program_top_category add order_by number default 50 constraint prg_top_order_by_cnn not null;
comment on column program_top_category.order_by is 'The number that should be used for categroy ordering at ui form. The field was added based on reqeirement: PROMIS-465';
------------------
create table program_top_version (
	id number constraint program_top_v_pk primary key,
	parent_id number constraint program_top_v_parent_id_fk references program_top_version(id),
	program_id nvarchar2(20) constraint program_top_v_program_id_cnn not null constraint program_top_v_program_id_fk references program(id) on delete cascade,
	name varchar2(200) constraint program_top_v_name_cnn not null,
	version varchar2(200) default 'current' constraint program_top_v_version_cnn not null constraint program_top_v_version_ca check(version in ('current','previous')),
	description varchar2(500),
	approval_date date,
	create_user_id varchar2(20) constraint program_top_v_create_by_cnn not null,
	update_user_id varchar2(20) constraint program_top_v_update_by_cnn not null,
	create_date date default sysdate constraint program_v_top_create_date_cnn not null,
	update_date date default sysdate constraint program_v_top_update_date_cnn not null
);
------------------
create index program_top_v_program_id_fki on program_top_version(program_id);
create index program_top_v_parent_id_fki on program_top_version(parent_id);
create unique index program_top_version_ui on program_top_version(program_id,replace(version,'previous',id));
------------------
comment on table program_top_version is 'Table represents realation between Program and TOP version.By default current is being added when creating new version. Table was created while implementing requirement: PROMIS-465';
comment on column program_top_version.program_id is 'Reference to Program.';
comment on column program_top_version.parent_id is 'Self Reference when a new version is being created based on current.';
comment on column program_top_version.version is 'The code of version. Two options possible: current and previous.';
------------------
create sequence program_top_v_id_seq minvalue 1 maxvalue 999999999999999999 increment by 1 start with 1;
------------------
create or replace trigger program_top_version_tr
before insert or update on program_top_version
for each row
begin
	if inserting then
		if :new.id is null then
			select program_top_v_id_seq.nextval into :new.id from dual;
		end if;
		:new.create_date := sysdate;
		:new.create_user_id := nvl(:new.create_user_id,'TRIGGER');
		:new.update_user_id := :new.create_user_id;
	end if;
	if updating then
		:new.update_user_id := nvl(:new.update_user_id,'TRIGGER');
	end if;
	:new.update_date := sysdate;
end;
/
------------
create table program_top_value (
	id number constraint program_top_value_pk primary key,
	program_version_id number constraint program_top_val_ver_cnn not null constraint program_top_val_ver_fk references program_top_version(id),
	subcategory_code varchar2(20) constraint program_top_val_scat_cnn not null constraint program_top_val_scat_fk references program_top_subcategory(code),
	indication1 varchar2(512),
	indication2 varchar2(512),
	indication3 varchar2(512),
	indication4 varchar2(512),
	indication5 varchar2(512),
	indication6 varchar2(512),
	indication7 varchar2(512),
	indication8 varchar2(512),
	create_user_id varchar2(20) constraint program_top_val_create_by_cnn not null,
	update_user_id varchar2(20) constraint program_top_val_update_by_cnn not null,
	create_date date default sysdate constraint program_top_val_create_d_cnn not null,
	update_date date default sysdate constraint program_top_val_update_d_cnn not null
);
---------------------------
create index program_top_val_ver_fki on program_top_value(program_version_id);
create index program_top_val_scat_fki on program_top_value(subcategory_code);
------------
comment on table program_top_value is 'Table represents the values for Target Oportunity Profile and for concrete version. Table was created while implementing requirement: PROMIS-465';
comment on column program_top_value.program_version_id is 'Reference to the table program_top_version.';
comment on column program_top_value.subcategory_code is 'Reference to the table program_top_subcategory.';
comment on column program_top_value.indication1 is 'Indications starting from 1 till 8.';
------------
create sequence program_top_value_id_seq minvalue 1 maxvalue 999999999999999999 increment by 1 start with 1;
------------
create or replace trigger program_top_value_tr
before insert or update on program_top_value
for each row
begin
	if inserting then
		if :new.id is null then
			select program_top_value_id_seq.nextval into :new.id from dual;
		end if;
		:new.create_date := sysdate;
		:new.create_user_id := nvl(:new.create_user_id,'TRIGGER');
		:new.update_user_id := :new.create_user_id;
	end if;
	if updating then
		:new.update_user_id := nvl(:new.update_user_id,'TRIGGER');
	end if;
	:new.update_date := sysdate;
end;
/
------------