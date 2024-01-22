begin
for r in (select constraint_name from user_constraints where table_name='TPP_VALUES' and constraint_type='R' and r_constraint_name =(select constraint_name from user_constraints where table_name='TARGET_PRODUCT_PROFILE' and constraint_type='P')) loop
execute immediate 'alter table tpp_values drop constraint '||r.constraint_name;
end loop;
end;
/
alter table tpp_values add constraint tpp_values_tpp_id_fk foreign key (tpp_id) references target_product_profile(id) on delete cascade;

begin
for r in (select constraint_name from user_cons_columns where table_name='PROJECT' and column_name='SUCC_PROJECT_ID') loop
execute immediate 'alter table project drop constraint '||r.constraint_name;
end loop;
end;
/
alter table project add constraint project_succ_project_id_fk foreign key (succ_project_id) references project(id) on delete set null;

begin
for r in (select constraint_name from user_cons_columns where table_name='PROJECT' and column_name='PREDECESSOR_PROJECT_ID') loop
execute immediate 'alter table project drop constraint '||r.constraint_name;
end loop;
end;
/
alter table project add constraint project_predec_project_id_fk foreign key (predecessor_project_id) references project(id) on delete set null;


