create table regulatory_type (
	code varchar2(10) constraint regulatory_type_pk primary key,
	name varchar2(100) constraint regulatory_type_name_cnn not null,
	description varchar2(500),
	is_active number(1) default 1 constraint regulatory_type_act_cnn not null constraint regulatory_type_act_ca check(is_active in (0,1)),
	create_date date default sysdate constraint regulatory_create_date_cnn not null,
	update_date date default sysdate constraint regulatory_update_date_cnn not null
);
------------
comment on table regulatory_type is 'Table represents the lookup for Project regulatory type. Table was created while implementing requirement: PROMIS-463';
comment on column regulatory_type.code is 'Unique code for the regulatory type.';
comment on column regulatory_type.name is 'The name of the regulatory type.';
------------
create or replace trigger regulatory_type_tr
before insert or update on regulatory_type
for each row
begin
	if inserting then
		:new.create_date := sysdate;
	end if;
	:new.update_date := sysdate;
end;
/
------------
merge into regulatory_type dst
using (
	select 'f1' code,'FDA Fast Track' name, '1' is_active from dual
		union all
	select 'f2','FDA Breakthrough Therapy','1' from dual
		union all
	select 'f3','FDA Accelerated Approval','1' from dual
		union all
	select 'f4','FDA Priority Review','1' from dual
		union all
	select 'e1','EU Priority Review','1' from dual
) src
on (dst.code=src.code)
when matched then
	update set dst.name=src.name, dst.is_active=src.is_active
when not matched then
	insert(code,name,is_active) values (src.code,src.name,src.is_active);
------------
alter table project add regulatory_code varchar2(10) constraint project_regulatory_code_fk references regulatory_type(code);
comment on column project.details_modality is 'Reference to the table: regulatory_type. The field was added based on reqeirement: PROMIS-463';
------------
alter table project add regulatory_other varchar2(100);
comment on column project.details_modality is 'Free text field: Other Requlatory Comments. The field was added based on reqeirement: PROMIS-463';
------------
create index project_regulatory_code_fki on project(regulatory_code);
------------