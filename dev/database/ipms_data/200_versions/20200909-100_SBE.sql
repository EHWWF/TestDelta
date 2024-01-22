alter table strategic_business_entity add is_visible number(1) default 1 constraint sbe_is_visible_cnn not null constraint sbe_is_visible_chk check(is_visible in (0,1));
alter table strategic_business_entity add update_date date default sysdate constraint sbe_update_date_cnn not null;
------------
comment on column strategic_business_entity.is_visible is 'Based on stored value in this column, Users in ProMIS Administration>Lookups, will be able to mark what SBE should be visible at UI, regardless if it is active or not. PROMIS-519';
------------
create or replace trigger sbe_biu_tr
before insert or update on strategic_business_entity for each row
  begin
    if inserting then
      :new.create_date := sysdate;
	end if;
	
	:new.update_date := sysdate;
  end;
/
---
update strategic_business_entity set is_visible=is_active;
commit;
---