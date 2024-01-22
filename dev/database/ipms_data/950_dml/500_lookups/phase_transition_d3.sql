prompt ---->
prompt ---->
prompt 
prompt ---->START    phase_transition
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;


merge into phase_transition t using (select '25' code, '25%' name, '1' is_active from dual) s on (t.code=s.code) when matched then update set t.name = s.name, t.is_active = s.is_active when not matched then insert (code,name,is_active) values (s.code,s.name,s.is_active);
merge into phase_transition t using (select '50' code, '50%' name, '1' is_active from dual) s on (t.code=s.code) when matched then update set t.name = s.name, t.is_active = s.is_active when not matched then insert (code,name,is_active) values (s.code,s.name,s.is_active);
merge into phase_transition t using (select '75' code, '75%' name, '1' is_active from dual) s on (t.code=s.code) when matched then update set t.name = s.name, t.is_active = s.is_active when not matched then insert (code,name,is_active) values (s.code,s.name,s.is_active);

commit;
prompt ---->END    phase_transition
prompt ---->
prompt ---->