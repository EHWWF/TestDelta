create or replace trigger project_category_biu_tr
before insert or update on project_category for each row
  begin
    if inserting then
      :new.create_date := sysdate;
      :new.update_date := :new.create_date;
	  if :new.is_promis=1 and :new.correlation_id is null then
		select max(correlation_id)+1 into :new.correlation_id
		from project_category
		where is_promis=1;
	  end if;
    end if;
    if updating then
      :new.update_date := sysdate;
    end if;
  end;
/