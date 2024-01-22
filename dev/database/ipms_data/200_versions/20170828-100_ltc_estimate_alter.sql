alter table ltc_estimate rename column phase_name to project_phase_code;
create table ltc_milestone_phase_mappin_old as select * from ltc_milestone_phase_mapping;
create table milestone_old as select * from milestone;
alter table ltc_milestone_phase_mapping add phase_code nvarchar2(10);
truncate table ltc_milestone_phase_mapping;
alter table ltc_milestone_phase_mapping drop column phase_name;
create unique index ltc_milestone_phase_undx on ltc_milestone_phase_mapping (milestone_code, phase_code);
insert into ltc_milestone_phase_mapping (milestone_code,phase_code) values ('1GLP','1');
insert into ltc_milestone_phase_mapping (milestone_code,phase_code) values ('M4B','2');
insert into ltc_milestone_phase_mapping (milestone_code,phase_code) values ('M6A','4');
insert into ltc_milestone_phase_mapping (milestone_code,phase_code) values ('M7A','5');
insert into ltc_milestone_phase_mapping (milestone_code,phase_code) values ('M8A','6');
insert into ltc_milestone_phase_mapping (milestone_code,phase_code) values ('M9','7');
commit;
update milestone set wbs_category=null;
update milestone set wbs_category='D3-D4' where code='1GLP';
update milestone set wbs_category='D4-D6' where code='M4B';
update milestone set wbs_category='D6-D7' where code='M6A';
update milestone set wbs_category='D7-D8' where code='M7A';
update milestone set wbs_category='D8-Launch' where code='M8A';
update milestone set wbs_category='Launch' where code='M9';
commit;
alter table ltc_estimate add (
    cost_start_date date,
    cost_finish_date date,
    is_manual number(1) default 0 constraint ltc_estimate_manual_cnn not null constraint ltc_estimate_manual_in check(is_manual in (0,1))
);