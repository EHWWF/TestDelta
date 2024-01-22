CREATE OR REPLACE TRIGGER "IPMS_DATA"."COSTS_FPS_TR" 
before insert or update on costs_fps
for each row
begin
	if inserting then
		select costs_id_fps_seq.nextval into :new.id from dual;
		:new.create_date := sysdate;
		:new.create_user_id := user_pkg.get_current_user;
	end if;

	if updating then
		:new.update_date := sysdate;
        :new.update_user_id := user_pkg.get_current_user;
	end if;
end;
/
ALTER TRIGGER "IPMS_DATA"."COSTS_FPS_TR" ENABLE;
truncate table costs_fps;
insert into costs_fps (
	project_id, study_id, 
	function_code, subfunction_code,
	scope_code, method_code, type_code, subtype_code,
	cost,
	committed_state, start_date, finish_date,
	create_user_id, update_user_id, create_date, update_date
)
select
	project_id, study_id,
	sfn.function_code, cst.subfunction_code,
	scope_code, method_code, type_code, subtype_code,
	cost,
	committed_state, start_date, finish_date,
	create_user_id, update_user_id, create_date, update_date	
from costs_cs cst
left join subfunction sfn on sfn.code=cst.subfunction_code;
commit;
insert into costs_fps (
	project_id, study_id, 
	function_code, subfunction_code,
	scope_code, method_code, type_code, subtype_code,
	cost,
	committed_state, start_date, finish_date,
	create_user_id, update_user_id, create_date, update_date
)
select
	project_id, study_id,
	sfn.function_code, cst.subfunction_code,
	scope_code, method_code, type_code, subtype_code,
	cost,
	committed_state, start_date, finish_date,
	create_user_id, update_user_id, create_date, update_date	
from costs_ged cst
left join subfunction sfn on sfn.code=cst.subfunction_code;
commit;
truncate table import_costs_fps;
insert into import_costs_fps (
	reference_id, import_id,
	project_id, study_id, 
	function_code, subfunction_code,
	scope_code, method_code, type_code, subtype_code,
	year, month, cost,
	committed_state, 
	status_code, status_description,
	create_date
)
select
	reference_id||'CS', import_id,
	project_id, study_id, 
	sfn.function_code, subfunction_code,
	scope_code, method_code, type_code, subtype_code,
	year, month, cost,
	committed_state, 
	status_code, status_description,
	create_date
from import_costs_cs cst
left join subfunction sfn on sfn.code=cst.subfunction_code;
commit;
insert into import_costs_fps (
	reference_id, import_id,
	project_id, study_id, 
	function_code, subfunction_code,
	scope_code, method_code, type_code, subtype_code,
	year, month, cost,
	committed_state, 
	status_code, status_description,
	create_date
)
select
	reference_id||'GED', import_id,
	project_id, study_id, 
	sfn.function_code, subfunction_code,
	scope_code, method_code, type_code, subtype_code,
	year, month, cost,
	committed_state, 
	status_code, status_description,
	create_date
from import_costs_ged cst
left join subfunction sfn on sfn.code=cst.subfunction_code;
commit;
