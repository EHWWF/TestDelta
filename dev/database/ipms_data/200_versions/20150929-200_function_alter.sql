alter table function add (valid_from date);
update function set valid_from=to_date('01-01-1900 01:00:00','dd-mm-yyyy hh24:mi:ss') where valid_from is null;
commit;
alter table function modify (valid_from date not null);

alter table function add (valid_to date);
--update function set valid_to=to_date('01-01-1910 01:00:00','dd-mm-yyyy hh24:mi:ss') where valid_to is null;
--commit;

comment on column function.is_active is 'Valid_From and Valid_To should be used instead and is_active should be dropped, see:PROMIS-282';

alter table function add (create_date date default sysdate not null);
alter table function add (update_date date);

create index function_valid_from_idx1 on function (valid_from);
create index function_valid_to_idx1 on function (valid_to);