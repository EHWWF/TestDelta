begin
for r in (
select c.constraint_name from user_constraints c
join user_constraints t on c.r_constraint_name=t.constraint_name
where c.table_name='TPP_VALUES' and t.table_name='TARGET_PRODUCT_PROFILE'
) loop
execute immediate 'alter table tpp_values drop constraint '|| r.constraint_name;
end loop;
end;
/
alter table tpp_values add constraint tpp_fk foreign key (tpp_id) references target_product_profile(id) on delete cascade;