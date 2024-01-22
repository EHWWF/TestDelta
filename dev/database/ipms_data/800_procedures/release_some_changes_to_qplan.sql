create or replace procedure release_some_changes_to_qplan as
	v_record_id nvarchar2(20);
	v_sys_job_id number;
	v_callback varchar2(200);
begin
	select message_id_seq.nextval into v_sys_job_id from dual;

	for r in (
			with
				prj as (
					select
						id,
						nvl(update_user_id, create_user_id) cwid,
						qplan_release_date,
						nvl(update_date, create_date) as master_data_change_date,
						(select max(nvl(update_date, create_date)) from timeline where project_id = p.id) as timeline_change_date,
						(select max(nvl(update_date, create_date)) from costs_probability where project_id = p.id) as project_ptr_change_date,
						(select max(nvl(update_date, create_date)) from costs_probability where project_id is null) as default_ptr_change_date,
						p.code
					from project p
					where is_syncing=0
						and code is not null
						and area_code is not null
						--and area_code in ('PRE-POT','D2-PRJ')
						and program_id != 'RBIN' --skip deleted projects
				),
				prj_audit_log as (
					select
						project_id,
						pa.details,
						pa.create_date as event_date,
						row_number() over(partition by pa.project_id order by pa.create_date desc) as rowno
					from project_audit pa
					where pa.record_type='FPS'
				)
			select
				prj.*, prja.event_date, prja.details as last_glimpse,
				nvl2(prj.qplan_release_date, 'update', 'creation') as operation
			from prj
				left join prj_audit_log prja on prja.project_id = prj.id and prja.rowno=1
			where 1 = 0 -- unLOCK !!!! --> 1=1
				and prj.code in ('11111111111111')
	)
	loop

		insert
		into project_audit
			(project_id, details, change_comment, sys_job_id, record_type, prj_update_user_id, create_date)
		values
			(r.id, qplan_pkg.xml(r.id), 'Requested Project '||r.operation, v_sys_job_id, 'FPS', r.cwid, sysdate)
		returning id into v_record_id;

		--qplan_pkg.release(r.id, r.last_glimpse, get_text('audit_pkg.release_prj_to_qplan_finish(''%1'', :1);', varchar2_table_typ(v_record_id)));
		qplan_pkg.release(r.id, null, get_text('audit_pkg.release_prj_to_qplan_finish(''%1'', :1);', varchar2_table_typ(v_record_id)));--null= the last XML, so FULL XML will be send

	end loop;

end;