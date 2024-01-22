alter table latest_estimates_process add(tag nvarchar2(20));
update latest_estimates_process set tag='ProMIS 1';
commit;
alter table latest_estimates_process modify (tag nvarchar2(20) not null);