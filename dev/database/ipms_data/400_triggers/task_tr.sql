create or replace trigger task_biu_tr
before insert or update on task for each row
  begin
    if inserting then
      if :new.id is null then
        select task_id_seq.nextval into :new.id from dual;
      end if;
      :new.create_date := sysdate;
      :new.update_date := :new.create_date;
    end if;
    if updating then
      :new.update_date := sysdate;
    end if;
  end;
/