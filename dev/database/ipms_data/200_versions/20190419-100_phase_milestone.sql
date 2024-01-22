alter table phase_milestone add create_date date default sysdate constraint phase_milest_create_date_cnn not null;
alter table phase_milestone add update_date date default sysdate constraint phase_milest_update_date_cnn not null;
create or replace trigger phase_milestone_biu_tr
before insert or update on phase_milestone for each row
    begin
        if inserting then
            :new.create_date := sysdate;
            :new.update_date := :new.create_date;
        end if;
        if updating then
            :new.update_date := sysdate;
        end if;
    end;
/
update phase_milestone set milestone_code='D5' where phase_code=3 and category='GT' and milestone_code<>'D5';
commit;