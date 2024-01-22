alter table study_template add(is_active number(1,0) default 1 not null);
alter table study_template add(create_date date default sysdate not null);
alter table study_template add(update_date date);