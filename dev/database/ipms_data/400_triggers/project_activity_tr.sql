create or replace trigger project_activity_biu_tr
before insert or update on project_activity for each row
  begin
    if inserting then
      select project_activity_id_seq.nextval into :new.id from dual;
      :new.create_date := sysdate;
      :new.create_user_id := nvl(:new.create_user_id,'TRIGGER');
      :new.update_date := :new.create_date;
      :new.update_user_id := :new.create_user_id;
    end if;
    if updating then
      :new.update_date := sysdate;
      :new.update_user_id := nvl(:new.update_user_id,'TRIGGER');
    end if;
  end;
/