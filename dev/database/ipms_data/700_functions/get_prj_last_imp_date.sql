create or replace function get_prj_last_imp_date(p_id in nvarchar2) return date
is
begin
	for r in (select max(imp.create_date) imp_date	
					from import imp where imp.project_id = p_id and imp.status_code='DONE' 
					and bitand(type_mask,import_pkg.type_project)=import_pkg.type_project ) loop
				return r.imp_date;
		end loop;
	return null;
end;
/
