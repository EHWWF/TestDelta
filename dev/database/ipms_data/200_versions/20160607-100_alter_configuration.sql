alter table configuration modify(code nvarchar2 (50));
alter table configuration add (is_resource number(1) default 0 not null);
