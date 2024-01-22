alter table subfunction add (valid_from date);
update subfunction set valid_from=to_date('01-01-1900 01:00:00','dd-mm-yyyy hh24:mi:ss') where valid_from is null;
commit;
alter table subfunction modify (valid_from date not null);

alter table subfunction add (valid_to date);
--update subfunction set valid_to=to_date('01-01-1910 01:00:00','dd-mm-yyyy hh24:mi:ss') where valid_to is null;
--commit;

comment on column subfunction.is_active is 'Valid_From and Valid_To should be used instead and is_active should be dropped, see:PROMIS-282';

alter table subfunction add (create_date date default sysdate not null);
alter table subfunction add (update_date date);

create index subfunction_valid_from_idx1 on subfunction (valid_from);
create index subfunction_valid_to_idx1 on subfunction (valid_to);