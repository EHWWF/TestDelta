alter table project disable all triggers;
alter table project add (is_typify_excluded number(1) default 0 not null check(is_typify_excluded in (0,1)));
alter table project enable all triggers;