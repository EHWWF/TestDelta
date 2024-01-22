alter table team_role add (
	is_dev_relevant number(1) default 0 not null,
	is_prdmnt_relevant number(1) default 0 not null,
	is_d2prj_relevant number(1) default 0 not null
);

update team_role set is_dev_relevant=1, is_prdmnt_relevant=1,is_d2prj_relevant=1;
update team_role set is_dev_relevant=0, is_prdmnt_relevant=0,is_d2prj_relevant=1 where code='LOPC';
commit;
