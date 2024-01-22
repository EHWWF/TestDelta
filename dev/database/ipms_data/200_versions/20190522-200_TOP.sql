create table program_top (
	id number constraint program_top_pk primary key,
	name varchar2(200),
	program_id nvarchar2(20) constraint program_top_program_id_cnn not null constraint program_top_program_id_fk references program(id) on delete cascade,
	version varchar2(200) default 'Current' constraint program_top_version_cnn not null,
	description varchar2(500),
	indication varchar2(2000),
	references varchar2(2000),
	approval_date date,
	create_user_id varchar2(20) constraint program_top_create_by_cnn not null,
	update_user_id varchar2(20) constraint program_top_update_by_cnn not null,
	create_date date default sysdate constraint program_top_create_date_cnn not null,
	update_date date default sysdate constraint program_top_update_date_cnn not null
);
---------------------------
create index program_top_program_id_fki on program_top(program_id);
------------
comment on table program_top is 'Table represents realation between Program and Target Opportunity Profile and stores TOP for program. Table was created while implementing requirement: PROMIS-465';
comment on column program_top.program_id is 'Reference to Program.';
comment on column program_top.version is 'The name of version.';
------------
create sequence program_top_id_seq minvalue 1 maxvalue 999999999999999999 increment by 1 start with 1;
------------
create or replace trigger program_top_tr
before insert or update on program_top
for each row
begin
	if inserting then
		if :new.id is null then
			select program_top_id_seq.nextval into :new.id from dual;
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
create table program_top_category (
	code varchar2(20) constraint program_top_cat_pk primary key,
	name varchar2(200) constraint program_top_cat_name_cnn not null, 
	description varchar2(500),
	is_active number(1) default 1 constraint program_top_cat_act_cnn not null constraint program_top_cat_act_ca check(is_active in (0,1)),
	modify_date date default sysdate constraint program_top_cat_modif_d_cnn not null,
	create_date date default sysdate constraint program_top_cat_create_d_cnn not null,
	update_date date default sysdate constraint program_top_cat_update_d_cnn not null
);
------------
comment on table program_top_category is 'Table represents the lookup for Target Opportunity Profile Category. Table was created while implementing requirement: PROMIS-465';
comment on column program_top_category.code is 'Unique code for the category.';
comment on column program_top_category.name is 'The name of the category.';
------------
create or replace trigger program_top_category_tr
before insert or update on program_top_category
for each row
begin
	if inserting then
		:new.create_date := sysdate;
	end if;
	:new.update_date := sysdate;
	:new.modify_date := sysdate;
	:new.code := replace(lower(:new.code),' ');
end;
/
------------
create table program_top_subcategory (
	code varchar2(20) constraint program_top_scat_pk primary key, 
	name varchar2(200) constraint program_top_scat_name_cnn not null, 
	description varchar2(500),
	category_code varchar2(20) constraint program_top_scat_cat_cnn not null constraint program_top_scat_cat_fk references program_top_category(code),
	is_active number(1) default 1 constraint program_top_scat_act_cnn not null constraint program_top_scat_act_ca check(is_active in (0,1)),
	modify_date date default sysdate constraint program_top_scat_modif_d_cnn not null,
	create_date date default sysdate constraint program_top_scat_create_d_cnn not null,
	update_date date default sysdate constraint program_top_scat_update_d_cnn not null
);
------------
create index program_top_scat_cat_fki on program_top_subcategory(category_code);
------------
comment on table program_top_category is 'Table represents the lookup for Target Opportunity Profile Subcategory. Table was created while implementing requirement: PROMIS-465';
comment on column program_top_category.code is 'Unique code for the subcategory.';
comment on column program_top_category.name is 'The name of the subcategory.';
------------
create or replace trigger program_top_subcategory_tr
before insert or update on program_top_subcategory
for each row
begin
	if inserting then
		:new.create_date := sysdate;
	end if;
	:new.update_date := sysdate;
	:new.modify_date := sysdate;
	:new.code := replace(lower(:new.code),' ');
end;
/
------------
create table program_top_values (
	id number constraint program_top_values_pk primary key,
    program_top_id number constraint program_top_val_topid_cnn not null constraint program_top_val_topid_fk references program_top(id),
    subcategory_code varchar2(20) constraint program_top_val_scat_cnn not null constraint program_top_val_scat_fk references program_top_subcategory(code),
    key_edv_proposition varchar2(200), 
    standard_of_care varchar2(200), 
    targeted_profile varchar2(200), 
    upside varchar2(200), 
    targeted_in varchar2(200), 
    key_driver number(1) default 0 constraint program_top_val_key_cnn not null constraint program_top_val_key_ca check(key_driver in (0,1)),
    unique_selling_point number(1) default 0 constraint program_top_val_usp_cnn not null constraint program_top_val_usp_ca check(unique_selling_point in (0,1)),
	create_user_id varchar2(20) constraint program_top_val_create_by_cnn not null,
	update_user_id varchar2(20) constraint program_top_val_update_by_cnn not null,
	create_date date default sysdate constraint program_top_val_create_d_cnn not null,
	update_date date default sysdate constraint program_top_val_update_d_cnn not null
  );
---------------------------
create index program_top_val_topid_fki on program_top_values(program_top_id);
create index program_top_val_scat_fki on program_top_values(subcategory_code);
------------
comment on table program_top_values is 'Table represents the values for Target Opportunity Profile. Table was created while implementing requirement: PROMIS-465';
comment on column program_top_values.program_top_id is 'Reference to the table program_top.';
comment on column program_top_values.subcategory_code is 'Reference to the table program_top_subcategory.';
------------
create sequence program_top_values_id_seq minvalue 1 maxvalue 999999999999999999 increment by 1 start with 1;
------------
create or replace trigger program_top_values_tr
before insert or update on program_top_values
for each row
begin
	if inserting then
		if :new.id is null then
			select program_top_values_id_seq.nextval into :new.id from dual;
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