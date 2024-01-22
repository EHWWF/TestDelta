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