create or replace package job_pkg authid current_user as

	/**
	 * Schedules all jobs.
	 */
	procedure setup;

	/**
	 * Stops all scheduled jobs.
	 */
	procedure teardown;

	/**
	 * Data cleanup job.
	 * Initiates cleanup for specific packages.
	 * Handles all exceptions internally.
	 */
	procedure cleanup;

	/**
	 * Import data job.
	 * Initiates import for specific packages.
	 * Handles all exceptions internally.
	 */
	procedure import;

	/**
	 * Export data job.
	 * Initiates export for specific packages.
	 * Handles all exceptions internally.
	 */
	procedure export;

	/**
	 * Create special JOB for SOA MDS chache refresh.
	 */
	procedure setup_cachemds;

	/**
	 * Tear down, drop Cache MDS JOB.
	 */
	procedure teardown_cachemds;

	/**
	 * Run - refresh SOA MDS cache.
	 */
	procedure send_cachemds;

	procedure send_cachemds_finish(p_payload xmltype);

	/**
	 * Create special JOB for QuickPlan integration.
	 */
	procedure setup_qplan_integration;

	/**
	 * Tear down, drop QuickPlan integration JOB.
	 */
	procedure teardown_qplan_integration;

	function job_exists(p_job_name varchar2) return number;

	-------------
	procedure setup_fun_sub_status;
	procedure update_function_sub_status;

	-------------------
	--Must be initiated only during system setup/installation.
	procedure setup_open_import_slot;
	procedure setup_close_import_slot;
	-------------------
	--This DB Job is being created every night during data import.
	--created with option: RUN ONCE
	procedure setup_run_import_once(p_payload xmltype);
	-------------------
	--prepare waiting slot = MESSAGE for data import
	procedure open_import_slot;
	--finilize data import, close data import waiting slot if it is still opened.
	procedure close_import_slot;

	-------------------
	--Refresh sys_guid table for project_id and program_id. Job must be stopped after addapting ADF part.
	procedure update_sys_guid;
	procedure setup_update_sys_guid;

end;
/
create or replace package body job_pkg as

--pragma serially_reusable;
	/*************************************************************************/
	function v_cachemds_job_name return nvarchar2
	as
	begin
		return 'CACHEMDS_JOB';
	end;
	/*************************************************************************/
	function v_export_job_name return nvarchar2
	as
	begin
		return 'EXPORT_JOB';
	end;
	/*************************************************************************/
	function v_import_job_name return nvarchar2
	as
	begin
		return 'IMPORT_JOB';
	end;
	/*************************************************************************/
	function v_qplan_notify_job_name return nvarchar2
	as
	begin
		return 'QPLAN_NOTIFY_JOB';
	end;
	/*************************************************************************/
	function v_qplan_release_job_name return nvarchar2
	as
	begin
		return 'QPLAN_RELEASE_JOB';
	end;
	/*************************************************************************/
	function v_calculate_gt_job_name return nvarchar2
	as
	begin
		return 'CALCULATE_GT_JOB';
	end;
	/*************************************************************************/
	function v_setup_fun_sub_job_name return nvarchar2
	as
	begin
		return 'FUNCTION_SUB_STATUS';
	end;
	/*************************************************************************/
	function v_import_open_slot_job_name return nvarchar2
	as
	begin
		return 'IMPORT_OPEN_SLOT_JOB';
	end;
	/*************************************************************************/
	function v_import_close_slot_job_name return nvarchar2
	as
	begin
		return 'IMPORT_CLOSE_SLOT_JOB';
	end;
	/*************************************************************************/
	function v_import_run_once_job_name return nvarchar2
	as
	begin
		return 'IMPORT_RUN_ONCE_JOB';
	end;
	/*************************************************************************/
	function job_exists(p_job_name varchar2) return number as
		v_count number;
	begin
		select count(*)
		into v_count
		from user_scheduler_jobs
		where job_name = upper(p_job_name);

		return v_count;
	end;

	/*************************************************************************/
	procedure import
	as
		v_sumsteps nvarchar2(11):='8';
		v_step nvarchar2(60):= v_import_job_name||':CleanImport.1/'||v_sumsteps;
		v_where nvarchar2(99):='job_pkg.import';
		v_guid sys_guid_transaction.guid%type;
		v_user nvarchar2(99):='PROMIS';
	begin
		log_pkg.log(v_where, 'Done:job_pkg.BEGIN;','BEGIN');
		v_guid:=ba_log_pkg.generate_guid;
		ba_log_pkg.put_guid(v_guid,v_user,'importbegin',null,null,'DONE',null,1,null);

		notify_pkg.import_job_started; --send an email that job was started.

		--logging exists inside procedure job_pkg.cleanup;, thus, here is not needed
		job_pkg.cleanup;
		log_pkg.log(v_where, 'Done:job_pkg.cleanup;',v_step);
		ba_log_pkg.put_guid(v_guid,null,null);
		commit;
		v_guid:=ba_log_pkg.generate_guid;
		ba_log_pkg.put_guid(v_guid,v_user,'importcleanup',null,null,'DONE',null,1,null);

		v_step := v_import_job_name||':MainImport.2/'||v_sumsteps;
		import_pkg.launch_all; --BAL logging is being done inside
		log_pkg.log(v_where, 'Done:import_pkg.launch_all;',v_step);
		ba_log_pkg.put_guid(v_guid,null,null);
		commit;

		--after data is imported, start <<LoggedChangesEmail>> task and send email notifications.
		v_step := v_import_job_name||':EmailLogChanges.3/'||v_sumsteps;
		audit_pkg.run_project_audit_job;
		log_pkg.log(v_where, 'Done:audit_pkg.run_project_audit_job;',v_step);
		ba_log_pkg.put_guid(v_guid,null,null);
		commit;
		v_guid:=ba_log_pkg.generate_guid;
		ba_log_pkg.put_guid(v_guid,v_user,'importloggedchangesemail',null,null,'DONE',null,1,null);

		--Second notification JOB is for <<ReleasedCompletedPIDTEmail>>
		v_step := v_import_job_name||':EmailPidtChanges.4/'||v_sumsteps;
		notify_pkg.released_completed_pidt;
		log_pkg.log(v_where, 'Done:notify_pkg.released_completed_pidt;',v_step);
		ba_log_pkg.put_guid(v_guid,null,null);
		commit;
		v_guid:=ba_log_pkg.generate_guid;
		ba_log_pkg.put_guid(v_guid,v_user,'importreleasedcompletedpidtemail',null,null,'DONE',null,1,null);

		v_step := v_import_job_name||':ViewRefresh.5/'||v_sumsteps;
		timeline_pkg.merge_timeline_wbs(null);--just in case, FULL refresh - MERGE View
		log_pkg.log(v_where, 'Done:timeline_pkg.merge_timeline_wbs;',v_step);
		ba_log_pkg.put_guid(v_guid,null,null);
		commit;

		v_step := v_import_job_name||':ViewRefresh.6/'||v_sumsteps;
		timeline_pkg.merge_timeline_activity(null);--just in case, FULL refresh - MERGE View
		log_pkg.log(v_where, 'Done:timeline_pkg.merge_timeline_activity;',v_step);
		ba_log_pkg.put_guid(v_guid,null,null);
		commit;

--Disabled Import D1 for JIRA ProMIS-608
		/*v_step := v_import_job_name||':ViewRefresh.7/'||v_sumsteps;
		import_d1_pkg.start_d1_import;--just in case, refresh also D1 import table.
		log_pkg.log(v_where, 'Done:import_d1_pkg.start_d1_import;',v_step);
		ba_log_pkg.put_guid(v_guid,null,null);
		commit;
		v_guid:=ba_log_pkg.generate_guid;
		ba_log_pkg.put_guid(v_guid,v_user,'importareacoded1',null,null,'DONE',null,1,null);*/
		
		--Enabled Import D2 for Enhancement JIRA ProMIS-608
		v_step := v_import_job_name||':ViewRefresh.7/'||v_sumsteps;
		import_d2_pkg.start_d2_import;--just in case, refresh also D2 import table.
		log_pkg.log(v_where, 'Done:import_d2_pkg.start_d2_import;',v_step);
		ba_log_pkg.put_guid(v_guid,null,null);
		commit;
		v_guid:=ba_log_pkg.generate_guid;
		ba_log_pkg.put_guid(v_guid,v_user,'importareacoded2',null,null,'DONE',null,1,null);

		--Disabled Update D2 field as Update d2 Projects being handled in Import D2 package for JIRA ProMIS-608
		
		/*v_step := v_import_job_name||':ViewRefresh.8/'||v_sumsteps;
		import_d1_pkg.update_d2_fields;
		log_pkg.log(v_where, 'Done:import_d1_pkg.update_d2_fields;',v_step);
		ba_log_pkg.put_guid(v_guid,null,null);
		commit;
		v_guid:=ba_log_pkg.generate_guid;
		ba_log_pkg.put_guid(v_guid,v_user,'importend',null,null,'DONE',null,1,null);*/

	exception when others then
		log_pkg.log(v_where, 'OTHERS!step='||v_step,sqlerrm);
		notice_pkg.catch(v_step, 'The main procedure for data import failed.');
	end;

	/*************************************************************************/
	procedure export as
	begin
		notice_pkg.debug(v_export_job_name,'Data export started.');
		export_pkg.launch_all;
		notice_pkg.information(v_export_job_name,'Data export completed.');

	exception when others then
		notice_pkg.catch(v_export_job_name, 'Data export failed.');
	end;

	/*************************************************************************/
	procedure setup_cachemds as
	begin
		if job_exists(v_cachemds_job_name) = 0 then
			dbms_scheduler.create_job (
				job_name => v_cachemds_job_name,
				job_type => 'plsql_block',
				job_action => 'begin job_pkg.send_cachemds; commit; end;',
				start_date => sysdate+60/1440,
				repeat_interval => 'freq=minutely; interval=60;',
				end_date => null,
				enabled => true,
				comments => 'Job defined entirely by the create job procedure. Refreshe cache for SOA MDS.');
		end if;
	end;

	/*************************************************************************/
	procedure teardown_cachemds as
	begin

		if job_exists(v_cachemds_job_name) = 1 then
			dbms_scheduler.drop_job (
				job_name => v_cachemds_job_name,
				force => true
			);
		end if;

	end;

	/*************************************************************************/
	procedure send_cachemds as
		v_msgid nvarchar2(55);
	begin
		v_msgid := message_pkg.send(lower(v_cachemds_job_name), xmltype('<read '||message_pkg.xmlns_ipms_soa||'><config/></read>'), 'begin job_pkg.send_cachemds_finish(:1); end;');

	end;

	/*************************************************************************/
	procedure update_study_template(p_payload xmltype) as
		v_where nvarchar2(99):='job_pkg.update_study_template';
	begin
		--At first, logically delete not used templates
		update study_template set
			is_active=0,
			update_date=sysdate
		where is_active=1
		and id in (
				select id from study_template
				minus
				select tpl.id
				from
					xmltable(
						xmlnamespaces(default 'http://xmlns.bayer.com/ipms/soa'),
						'//project/studyTemplates/template' passing p_payload
						columns
							id nvarchar2(20) path '@id',
							name nvarchar2(100) path 'name'
					) tpl
		);

		--Insert missing ones and update Name and is_active if different
		for rr in (
						select tpl.id, tpl.name
						from
							xmltable(
								xmlnamespaces(default 'http://xmlns.bayer.com/ipms/soa'),
								'//project/studyTemplates/template' passing p_payload
								columns
									id nvarchar2(20) path '@id',
									name nvarchar2(100) path 'name'
							) tpl
					)
		loop
			begin
				insert into study_template (id,name,create_date,is_active)
				values (rr.id,rr.name,sysdate,1);
			exception when dup_val_on_index then
				update study_template set
					name=rr.name,
					is_active=1,
					update_date=sysdate
				where id=rr.id and (name<>rr.name or is_active=0);
			end;
		end loop;

		--try to delete not used ones, one by one
		for dd in (
						select * from study_template where is_active=0
						)
		loop
			begin
				delete from study_template where id=dd.id and is_active=0;
			exception when others then null; end;
		end loop;


		/*
		-- Does not work for Deleting used templates
		merge into study_template stp
		using (
			select id, name, count(src) src, count(dst) dst from (
				select tpl.id, tpl.name, 1 as src, null as dst
				from xmltable(
						xmlnamespaces(default 'http://xmlns.bayer.com/ipms/soa'),
						'//project/studyTemplates/template' passing p_payload
						columns
							id nvarchar2(20) path '@id',
							name nvarchar2(100) path 'name'
					) tpl
				union all
				select id, name, null as src, 1 as dst
				from study_template
			)
			group by id, name
			having count(src) <> count(dst)
		) xs on (stp.id=xs.id)
		when matched then
			update set stp.name=xs.name
			delete where xs.src=0
		when not matched then
			insert (id, name) values (xs.id, xs.name);
		*/
	exception when others then
		notice_pkg.catch(v_where, 'Updating: study_template.');
		raise;
	end;

	/*************************************************************************/
	procedure update_baseline_type(p_payload xmltype) as
		v_where nvarchar2(99):='job_pkg.update_baseline_type';
		v_is_selectable number;
	begin
		--At first, logically delete not used templates
		update baseline_type set
			is_active=0,
			update_date=sysdate
		where is_active=1
		and id in (
				select id from baseline_type
				minus
				select tpl.id
				from
					xmltable(
						xmlnamespaces(default 'http://xmlns.bayer.com/ipms/soa'),
						'//baseline/baselineTypes/baselineType'
						passing p_payload
						columns
							id nvarchar2(20) path '@id'
					) tpl
		);

		--Insert missing ones and update Name and is_active if different
		for rr in (
						select tpl.id, tpl.name, tpl.sequence_number
						from
							xmltable(
								xmlnamespaces(default 'http://xmlns.bayer.com/ipms/soa'),
								'//baseline/baselineTypes/baselineType'
								passing p_payload
								columns
									id nvarchar2(20) path '@id',
									name nvarchar2(100) path 'name',
									sequence_number number path 'sequenceNumber'
							) tpl
					)
		loop
			if upper(replace(rr.name,' ')) in (replace(upper('Raw-Current Publication'),' '),replace(upper('Current-Approved Publication'),' ')) then
			 v_is_selectable:=0;
			else
			 v_is_selectable:=1;
			end if;

			begin
				insert into baseline_type (id,name,create_date,is_active,sequence_number,is_selectable)
				values (rr.id,rr.name,sysdate,1,rr.sequence_number,v_is_selectable);
			exception when dup_val_on_index then
				update baseline_type set
					name=rr.name,
					sequence_number=rr.sequence_number,
					is_active=1,
					is_selectable=v_is_selectable,
					update_date=sysdate
				where id=rr.id and (name<>rr.name or is_active=0 or is_selectable<>v_is_selectable or sequence_number<>rr.sequence_number);
			end;
		end loop;

		--try to delete not used ones, one by one
		for dd in (
						select * from baseline_type where is_active=0
						)
		loop
			begin
				delete from baseline_type where id=dd.id and is_active=0;
			exception when others then null; end;
		end loop;

	exception when others then
		notice_pkg.catch(v_where, 'Updating: baseline_type.');
		raise;
	end;

	/*************************************************************************/
	procedure send_cachemds_finish(p_payload xmltype) as
		v_where nvarchar2(99):='job_pkg.send_cachemds_finish';
	begin
		if message_pkg.is_complete(p_payload) = 0 then
			return;
		end if;

		update_study_template(p_payload);
		update_baseline_type(p_payload);

	end;

	/*************************************************************************/
	procedure setup_qplan_integration as
	begin

		if job_exists(v_qplan_release_job_name) = 0 then
			dbms_scheduler.create_job (
				job_name => v_qplan_release_job_name,
				job_type => 'plsql_block',
				job_action => 'begin audit_pkg.release_all_changes_to_qplan; commit; end;',
				start_date => sysdate+60/1440,
				repeat_interval => 'freq=minutely; interval=60;',
				end_date => null,
				enabled => true,
				comments => 'Job defined entirely by the create job procedure. Monitor projects for updates and release to FPS.');
		end if;

		if job_exists(v_qplan_notify_job_name) = 0 then
			dbms_scheduler.create_job (
				job_name => v_qplan_notify_job_name,
				job_type => 'plsql_block',
				job_action => 'begin notify_pkg.published_2qplan; commit; end;',
				start_date => trunc(sysdate+1 - 7.5/24) + 7.5/24,
				repeat_interval => 'freq=daily; interval=1;',
				end_date => null,
				enabled => true,
				comments => 'Job defined entirely by the create job procedure. Daily notification about FPS integrations.');
		end if;

	end;

	/*************************************************************************/
	procedure teardown_qplan_integration as
	begin

		if job_exists(v_qplan_release_job_name) = 1 then
			dbms_scheduler.drop_job (
				job_name => v_qplan_release_job_name,
				force => true
			);
		end if;

		if job_exists(v_qplan_notify_job_name) = 1 then
			dbms_scheduler.drop_job (
				job_name => v_qplan_notify_job_name,
				force => true
			);
		end if;

	end;

	/*************************************************************************/
	procedure setup as
	begin

		if job_exists(v_import_job_name) = 0 then
			dbms_scheduler.create_job (
				job_name => v_import_job_name,
				job_type => 'plsql_block',
				job_action => 'begin job_pkg.import; commit; end;',
				start_date => trunc(sysdate+1)+6/24,
				repeat_interval => 'freq=daily; interval=1;',
				end_date => null,
				enabled => true,
				comments => 'Job defined entirely by the create job procedure.');
		end if;

		if job_exists(v_export_job_name) = 0 then
			dbms_scheduler.create_job (
				job_name => v_export_job_name,
				job_type => 'plsql_block',
				job_action => 'begin job_pkg.export; commit; end;',
				start_date => trunc(sysdate+1)+19/24,
				repeat_interval => 'freq=daily; interval=1;',
				end_date => null,
				enabled => true,
				comments => 'Job defined entirely by the create job procedure.');
		end if;

		setup_cachemds;
		setup_qplan_integration;
	end;

	/*************************************************************************/
	procedure teardown as
	begin

		if job_exists(v_import_job_name) = 1 then
			dbms_scheduler.drop_job (
				job_name => v_import_job_name,
				force => true);
		end if;

		if job_exists(v_export_job_name) = 1 then
			dbms_scheduler.drop_job (
				job_name => v_export_job_name,
				force => true);
		end if;

		teardown_cachemds;
		teardown_qplan_integration;
	end;

	/*************************************************************************/
	procedure cleanup as
	begin
		notice_pkg.debug(v_import_job_name||':CleanImport','Data cleanup started.');
			import_pkg.cleanup;
			message_pkg.cleanup;
			notice_pkg.cleanup;
			log_pkg.cleanup;
		notice_pkg.information(v_import_job_name||':CleanImport','Data cleanup completed.');

	exception when others then
		notice_pkg.catch(v_import_job_name||':CleanImport', 'Data cleanup failed.');
	end;

	/*************************************************************************/
	procedure setup_fun_sub_status as
	begin
		if job_exists(v_setup_fun_sub_job_name) = 0 then
			dbms_scheduler.create_job (
				job_name => v_setup_fun_sub_job_name,
				job_type => 'plsql_block',
				job_action => 'begin job_pkg.update_function_sub_status; commit; end;',
				start_date => trunc(sysdate+1)+1/(24*60),
				repeat_interval => 'freq=daily; interval=1;',
				end_date => null,
				enabled => true,
				comments => 'Job defined entirely by the create job procedure.');
		end if;
	end;

	/*************************************************************************/
	procedure update_function_sub_status as
		v_where nvarchar2(99):='job_pkg.update_function_sub_status';
		v_rowcount1 number:=0;
		v_rowcount2 number:=0;
		vg_guid sys_guid_transaction.guid%type;
	begin

		vg_guid:=ba_log_pkg.generate_guid;
		ba_log_pkg.put_guid(vg_guid,'PROMIS', v_where);
		log_pkg.log(v_where, 'SUB-FUNCTION update.','Starting...');

		update function set is_active=0, update_date=sysdate where nvl(valid_to,sysdate+111)<sysdate and is_active=1;
		v_rowcount1 := sql%rowcount;
		update function set is_active=1, update_date=sysdate where nvl(valid_to,sysdate+111)>sysdate and is_active=0;
		v_rowcount2 := sql%rowcount;
			if (v_rowcount1+v_rowcount2)>0 then
				lookup_pkg.send(null);
			end if;

		log_pkg.log(v_where, 'SUB-FUNCTION update.v_rowcount1+2='||(v_rowcount1+v_rowcount2),'Done.Subfunction..');

		update subfunction set is_active=0, update_date=sysdate where nvl(valid_to,sysdate+111)<sysdate and is_active=1;
		v_rowcount1 := sql%rowcount;
		update subfunction set is_active=1, update_date=sysdate where nvl(valid_to,sysdate+111)>sysdate and is_active=0;
		v_rowcount2 := sql%rowcount;

		log_pkg.log(v_where, 'SUB-FUNCTION update.v_rowcount1+2='||(v_rowcount1+v_rowcount2),'Done.Function..');

		ba_log_pkg.put_guid(vg_guid,null,null);

		--after updating SUB-Functions, run Employee import from LDAP as well: PROMIS-444
		begin
			import_employees_pkg.get_employees;
			--null;
		exception when others then
			log_pkg.log(v_where, 'OTHERS-ERROR!,import_employees_pkg.get_employees',sqlerrm);
		end;

		job_pkg.cleanup; --during nightly tasks, do data cleaning as well, then another import will be done faster.

	exception when others then
		log_pkg.log(v_where, 'OTHERS.',sqlerrm);
		notice_pkg.catch(v_where, 'update_function_sub_status.');
	end;



	/*************************************************************************/
	procedure setup_open_import_slot as
	begin
		if job_exists(v_import_open_slot_job_name) = 0 then
			dbms_scheduler.create_job (
				job_name => v_import_open_slot_job_name,
				job_type => 'plsql_block',
				job_action => 'begin job_pkg.open_import_slot; commit; end;',
				number_of_arguments => 0,
				start_date => trunc(sysdate+1)+1/(24*60),
				repeat_interval => 'FREQ=WEEKLY;BYDAY=MON,TUE,WED,THU,FRI',
				end_date => null,
				enabled => true,
				comments => 'Creates data import waiting slot to import data from COMBASE.');
		end if;
	end;

	/*************************************************************************/
	procedure open_import_slot as
		v_where nvarchar2(99):='job_pkg.open_import_slot';
		v_payload xmltype;
		v_message_id nvarchar2(22);
	begin
		/* get id for new message - will be injected into xml */
		v_message_id := 'S'||to_char(sysdate,'yyyymmdd');

		select xmltype('<?xml version="1.0" encoding="utf-8" ?><request '||
		message_pkg.xmlns_ipms_soa||' id="'||v_message_id||'"/>') into v_payload from dual;

		insert into message(id,request,subject,callback)
		values(v_message_id,v_payload,'import_job','begin job_pkg.setup_run_import_once(:1); commit; end;');

	exception when others then
		--log_pkg.log(v_where, 'OTHERS.',sqlerrm);
		log_pkg.catch(v_where,'OTHERS', v_where);
	end;

	/*************************************************************************/
	procedure setup_close_import_slot as
	begin
		if job_exists(v_import_close_slot_job_name) = 0 then
			dbms_scheduler.create_job (
				job_name => v_import_close_slot_job_name,
				job_type => 'plsql_block',
				job_action => 'begin job_pkg.close_import_slot; commit; end;',
				number_of_arguments => 0,
				start_date => trunc(sysdate+1)+(9.5/24),
				repeat_interval => 'FREQ=WEEKLY;BYDAY=MON,TUE,WED,THU,FRI',
				end_date => null,
				enabled => true,
				comments => 'Finishes data import by updating waiting slot.');
		end if;
	end;

	/*************************************************************************/
	procedure close_import_slot as
		v_where nvarchar2(99):='job_pkg.close_import_slot';
		v_response_date date;
		v_message_id nvarchar2(22);
		v_new_message_id nvarchar2(22);
	begin
		/* get id for new message - will be injected into xml */
		v_message_id := 'S'||to_char(sysdate,'yyyymmdd');
		select message_id_seq.nextval into v_new_message_id from dual;

		begin
			select response_date into v_response_date from message where id=v_message_id;

			if v_response_date is null then
				update message set id=v_new_message_id, callback='ER_'||v_message_id where id=v_message_id;
				--Send E-Mail about missing import
				notify_pkg.import_job_not_started;
			else
				update message set id=v_new_message_id, callback='FIN_'||v_message_id where id=v_message_id;
			end if;

		exception when no_data_found then
			null;
		end;

	exception when others then
		log_pkg.catch(v_where,'OTHERS', v_where);
	end;


	/*************************************************************************/
	procedure setup_run_import_once(p_payload xmltype) as
		v_where nvarchar2(99):='job_pkg.setup_run_import_once';
		v_message_id nvarchar2(22);
		v_new_message_id nvarchar2(22);
		v_rowcount pls_integer;
	begin
		if job_exists(v_import_run_once_job_name) = 0 then
			dbms_scheduler.create_job (
				job_name => v_import_run_once_job_name,
				job_type => 'plsql_block',
				job_action => 'begin job_pkg.import; commit; end;',--MAIN IMPORT
				number_of_arguments => 0,
				start_date => sysdate+1/(24*60),--delay one minute start, just in case, if all works then change that mode to: start immediate
				repeat_interval => null,
				end_date => null,
				enabled => true,
				comments => 'Finishes data import by updating waiting slot.');

				begin
					--v_message_id := p_payload.extract('/response/@id',message_pkg.xmlns_ipms_soa).getstringval();
					v_message_id := 'S'||to_char(sysdate,'yyyymmdd');
					select message_id_seq.nextval into v_new_message_id from dual;
					update message set id=v_new_message_id, callback='OK_'||v_message_id where id=v_message_id;
					v_rowcount := sql%rowcount;
				exception when others then
					log_pkg.catch(v_where,'SELECT', 'v_message_id='||v_message_id||';v_new_message_id='||v_new_message_id);
				end;
			log_pkg.log(v_where, 'OK;v_message_id='||v_message_id||';v_new_message_id='||v_new_message_id, v_rowcount);
		else
			log_pkg.log(v_where, 'JOB_EXISTS','JOB_EXISTS');
		end if;

	exception when others then
		log_pkg.catch(v_where,'OTHERS', 'v_message_id='||v_message_id||';v_new_message_id='||v_new_message_id);
	end;

	/*************************************************************************/
	procedure update_sys_guid_status
	as
		v_where nvarchar2(99):='job_pkg.update_sys_guid_status';
		v_project_id nvarchar2(20);
		v_program_id nvarchar2(20);
		v_count number;
		v_msg nvarchar2(32000);
		--v_timestamp date:=sysdate-1/96;--we look back only for 15min
		v_timestamp date:=sysdate-1/48;--we look back for 30min because PublishTimeline could take much loner than 15min
	begin

		for cc in (
					select *
					from sys_guid
					--where (record_count is null or record_count=0)
					where nvl(record_count,0)=0-- is null
					and create_date > v_timestamp
					and ba_code<>'messagefps'
					and ba_code<>'autoimportstudy'
					--and ba_code<>'importstudy'--todo, BAL must be send later
					)
		loop
			v_count:=0;
			v_program_id:=null;
			v_msg:=null;

			if cc.ba_code in ('programcreate','programedit','programdelete') then
				--select versions_startscn, versions_starttime, versions_endscn, versions_endtime, versions_xid, versions_operation

				begin
					--at first try using standard flashback option, directly from source table
					select ttt.id, count(1) into v_program_id,v_count
					from program
					versions between scn timestamp_to_scn(v_timestamp) and timestamp_to_scn(sysdate) ttt
					join sys_guid_transaction tr on (ttt.versions_xid = tr.transaction_id)
					--join sys_guid guid on (guid.id=tr.guid)
					where tr.guid=cc.id--'61259f28-3ee7-44b7-9d4d-0bbe844bd3cc'
					and ttt.versions_operation=decode(cc.ba_code,'programcreate','I','programedit','U','programdelete','D')
					group by ttt.id
					;
					v_msg:=v_msg||'program;';
				exception when others then
				/*
					begin
						select ttt.id, count(1) into v_program_id,v_count
						from program_his ttt
						--versions between scn timestamp_to_scn(v_timestamp) and timestamp_to_scn(sysdate) ttt
						join sys_guid_transaction tr on (ttt.xid = tr.transaction_id)
						--join sys_guid guid on (guid.id=tr.guid)
						where tr.guid=cc.id--'61259f28-3ee7-44b7-9d4d-0bbe844bd3cc'
						and ttt.operation=decode(cc.ba_code,'programcreate','I','programedit','U','programdelete','D')
						group by ttt.id
						;
						v_msg:=v_msg||'program_his;';
					exception when others then
					*/
						v_msg:=v_msg||'OTHER:SELECT;program;'||sqlerrm;
					--end;
				end;

			elsif cc.ba_code in ('programroles') then

				begin
					select count(1) into v_count
					from user_role
					versions between scn timestamp_to_scn(v_timestamp) and timestamp_to_scn(sysdate) ttt
					join sys_guid_transaction tr on (ttt.versions_xid = tr.transaction_id)
					where tr.guid=cc.id
					;
					v_msg:=v_msg||'user_role'||v_count||';';
				exception when others then
					v_msg:=v_msg||'OTHER:SELECT;user_role;'||sqlerrm;
				end;

			elsif cc.ba_code in ('programteam') then

				begin
					--select pp.program_id,count(1) into v_program_id,v_count
					select count(1) into v_count
					from team_member_project
					versions between scn timestamp_to_scn(v_timestamp) and timestamp_to_scn(sysdate) ttt
					join sys_guid_transaction tr on (ttt.versions_xid = tr.transaction_id)
					--join project pp on (ttt.project_id=pp.id)
					where tr.guid=cc.id
					--group by pp.program_id
					;
					v_msg:=v_msg||'team_member_project'||v_count||';';
				exception when others then
					v_msg:=v_msg||'OTHER:SELECT;team_member_project;'||sqlerrm;
				end;

			elsif cc.ba_code in ('sandboxplancreate','sandboxplandelete','sandboxplanmodify','sandboxplanimportactuals','sandboxplanimportplan') then
				begin
					select count(1) into v_count
					from program_sandbox
					versions between scn timestamp_to_scn(v_timestamp) and timestamp_to_scn(sysdate) ttt
					join sys_guid_transaction tr on (ttt.versions_xid = tr.transaction_id)
					where tr.guid=cc.id
					;
					v_msg:=v_msg||'program_sandbox'||v_count||';';
				exception when others then
					v_msg:=v_msg||'OTHER:SELECT;program_sandbox;'||sqlerrm;
				end;

			elsif cc.ba_code in
				(
					'projectcreate',
					'projectdelete',
					'projectedit',
					'projecteditid',
					'projectforecast',
					'projectimportd1',
					'projectlead',
					'projectmove',
					'projectrelease',
					'projectreleasefps',
					'projectrestore',
					'projecttypify'
				) then

				begin
					select count(1) into v_count
					from project
					versions between scn timestamp_to_scn(v_timestamp) and timestamp_to_scn(sysdate) ttt
					join sys_guid_transaction tr on (ttt.versions_xid = tr.transaction_id)
					where tr.guid=cc.id
					;
					v_msg:=v_msg||'project;';
				exception when others then
					begin
						/*
						select count(1) into v_count
						from project_his ttt
						join sys_guid_transaction tr on (ttt.xid = tr.transaction_id)
						where tr.guid=cc.id
						;
						*/
						v_msg:=v_msg||'project_his'||v_count||';';
					exception when others then
						v_msg:=v_msg||'OTHER:SELECT;project;'||sqlerrm;
					end;
				end;

			elsif cc.ba_code in ('tppedit') then

				begin
					select count(1) into v_count
					from target_product_profile
					versions between scn timestamp_to_scn(v_timestamp) and timestamp_to_scn(sysdate) ttt
					join sys_guid_transaction tr on (ttt.versions_xid = tr.transaction_id)
					where tr.guid=cc.id
					;
					v_msg:=v_msg||'target_product_profile'||v_count||';';
				exception when others then
					v_msg:=v_msg||'OTHER:SELECT;target_product_profile;'||sqlerrm;
				end;

			elsif cc.ba_code in ('goalscreate','goalsdelete','goalsedit') then

				begin
					select count(1) into v_count
					from goal
					versions between scn timestamp_to_scn(v_timestamp) and timestamp_to_scn(sysdate) ttt
					join sys_guid_transaction tr on (ttt.versions_xid = tr.transaction_id)
					where tr.guid=cc.id
					;
					v_msg:=v_msg||'goal'||v_count||';';
				exception when others then
					v_msg:=v_msg||'OTHER:SELECT;goal;'||sqlerrm;
				end;

			elsif cc.ba_code in ('estimatesprocessdelete','estimatesprocessstart','estimatesprocessterminate','estimatesprocessupdate','estimatestagmeetingfinalize') then

				begin
					select count(1) into v_count
					from latest_estimates_process
					versions between scn timestamp_to_scn(v_timestamp) and timestamp_to_scn(sysdate) ttt
					join sys_guid_transaction tr on (ttt.versions_xid = tr.transaction_id)
					where tr.guid=cc.id
					;
					v_msg:=v_msg||'latest_estimates_process'||v_count||';';
				exception when others then
					v_msg:=v_msg||'OTHER:SELECT;latest_estimates_process;'||sqlerrm;
				end;

			elsif cc.ba_code in ('estimatestagcreate','estimatestagfreeze') then

				begin
					select count(1) into v_count
					from latest_estimates_tag
					versions between scn timestamp_to_scn(v_timestamp) and timestamp_to_scn(sysdate) ttt
					join sys_guid_transaction tr on (ttt.versions_xid = tr.transaction_id)
					where tr.guid=cc.id
					;
					v_msg:=v_msg||'latest_estimates_tag'||v_count||';';
				exception when others then
					v_msg:=v_msg||'OTHER:SELECT;latest_estimates_tag;'||sqlerrm;
				end;

			elsif cc.ba_code in ('estimatesprovide') then
v_count:=1;
/*
				begin
					select count(1) into v_count
					from latest_estimate
					versions between scn timestamp_to_scn(v_timestamp) and timestamp_to_scn(sysdate) ttt
					join sys_guid_transaction tr on (ttt.versions_xid = tr.transaction_id)
					where tr.guid=cc.id
					;
					v_msg:=v_msg||'latest_estimate'||v_count||';';
				exception when others then
					v_msg:=v_msg||'OTHER:SELECT;latest_estimate;'||sqlerrm;
				end;
*/
			elsif cc.ba_code in ('estimatesprocessstartltc','estimatesprocessterminateltc','estimatesprocessupdateltc') then

				begin
					select count(1) into v_count
					from ltc_process
					versions between scn timestamp_to_scn(v_timestamp) and timestamp_to_scn(sysdate) ttt
					join sys_guid_transaction tr on (ttt.versions_xid = tr.transaction_id)
					where tr.guid=cc.id
					;
					v_msg:=v_msg||'ltc_process'||v_count||';';
				exception when others then
					v_msg:=v_msg||'OTHER:SELECT;ltc_process;'||sqlerrm;
				end;

			elsif cc.ba_code in ('estimatesprovideltc','ltcprovide') then
v_count := 1;
/*
				begin
					select count(1) into v_count
					from ltc_estimate
					versions between scn timestamp_to_scn(v_timestamp) and timestamp_to_scn(sysdate) ttt
					join sys_guid_transaction tr on (ttt.versions_xid = tr.transaction_id)
					where tr.guid=cc.id
					;
					v_msg:=v_msg||'ltc_estimate'||v_count||';';
				exception when others then
					v_msg:=v_msg||'Missing record from ltc_estimate;';
					v_msg:=v_msg||'OTHER:SELECT;program;'||sqlerrm;
				end;
*/
			elsif cc.ba_code in ('estimatestagcreateltc','estimatestagprefillltc') then

				begin
					select count(1) into v_count
					from ltc_tag
					versions between scn timestamp_to_scn(v_timestamp) and timestamp_to_scn(sysdate) ttt
					join sys_guid_transaction tr on (ttt.versions_xid = tr.transaction_id)
					where tr.guid=cc.id
					;
					v_msg:=v_msg||'ltc_tag'||v_count||';';
				exception when others then
					v_msg:=v_msg||'OTHER:SELECT;ltc_tag;'||sqlerrm;
				end;

			elsif cc.ba_code in ('planningassumptionsprovide','planningassumptionsstart') then

				begin
					select count(1) into v_count
					from plan_assumption_request
					versions between scn timestamp_to_scn(v_timestamp) and timestamp_to_scn(sysdate) ttt
					join sys_guid_transaction tr on (ttt.versions_xid = tr.transaction_id)
					where tr.guid=cc.id
					;
					v_msg:=v_msg||'plan_assumption_request'||v_count||';';
				exception when others then
					v_msg:=v_msg||'OTHER:SELECT;plan_assumption_request;'||sqlerrm;
				end;

			elsif cc.ba_code in ('referencesmaintain') then

				begin
					select count(1) into v_count
					from reference
					versions between scn timestamp_to_scn(v_timestamp) and timestamp_to_scn(sysdate) ttt
					join sys_guid_transaction tr on (ttt.versions_xid = tr.transaction_id)
					where tr.guid=cc.id
					;
					v_msg:=v_msg||'reference'||v_count||';';
				exception when others then
					v_msg:=v_msg||'OTHER:SELECT;reference;'||sqlerrm;
				end;

			elsif cc.ba_code in ('timelinepublish','unlocksendreceive','maintainbaselines') then

				begin
					select count(1) into v_count
					from timeline
					versions between scn timestamp_to_scn(v_timestamp) and timestamp_to_scn(sysdate) ttt
					join sys_guid_transaction tr on (ttt.versions_xid = tr.transaction_id)
					where tr.guid=cc.id
					;
					v_msg:=v_msg||'timeline'||v_count||';';
					if cc.ba_code='timelinepublish' and v_count<12 then
						v_count:=0; --sorry, publication is still running, come back later
					elsif cc.ba_code in ('unlocksendreceive','maintainbaselines','importstudy') and v_count<9 then
						v_count:=0; --sorry, come back later
					end if;
				exception when others then
					v_msg:=v_msg||'OTHER:SELECT;timeline;'||sqlerrm;
				end;

			elsif cc.ba_code in ('importtimelinefps','importtimelineplansophia') then

				begin
					select count(1) into v_count
					from import_timeline
					versions between scn timestamp_to_scn(v_timestamp) and timestamp_to_scn(sysdate) ttt
					join sys_guid_transaction tr on (ttt.versions_xid = tr.transaction_id)
					where tr.guid=cc.id
					;
					v_msg:=v_msg||'import_timeline'||v_count||';';
					/*
					if cc.ba_code='timelinepublish' and v_count<12 then
						v_count:=0; --sorry, publication is still running, come back later
					elsif cc.ba_code in ('unlocksendreceive','maintainbaselines','importstudy') and v_count<9 then
						v_count:=0; --sorry, come back later
					end if;
					*/
				exception when others then
					v_msg:=v_msg||'OTHER:SELECT;import_timeline;'||sqlerrm;
				end;

			elsif cc.ba_code in ('importstudy') then

				begin
					select count(1) into v_count
					from import_study
					versions between scn timestamp_to_scn(v_timestamp) and timestamp_to_scn(sysdate) ttt
					join sys_guid_transaction tr on (ttt.versions_xid = tr.transaction_id)
					where tr.guid=cc.id
					;
					v_msg:=v_msg||'import_study'||v_count||';';
					/*
					if cc.ba_code='timelinepublish' and v_count<12 then
						v_count:=0; --sorry, publication is still running, come back later
					elsif cc.ba_code in ('unlocksendreceive','maintainbaselines','importstudy') and v_count<9 then
						v_count:=0; --sorry, come back later
					end if;
					*/
				exception when others then
					v_msg:=v_msg||'OTHER:SELECT;import_study;'||sqlerrm;
				end;

			else

				--NOTE:
				--messagefps is missing in sys_guid table
				--autoimportstudy is done at import_pkg
				v_msg:=v_msg||'ELSE;';
			end if;


			--Assuming that many transactions are related with P6 and all integration goes via MESSAGE table,
			--thus, in case of issue check MESSAGE table
			/*
			if v_count=0 then
				begin
					select count(1) into v_count
					from message
					versions between scn timestamp_to_scn(v_timestamp) and timestamp_to_scn(sysdate) ttt
					join sys_guid_transaction tr on (ttt.versions_xid = tr.transaction_id)
					where tr.guid=cc.id
					;
					v_msg:=v_msg||'message;';
				exception when others then
					v_msg:=v_msg||'Missing record from message;';
				end;
			end if;
			*/
			--------------------------------------------------------------------
			begin
				v_msg:=substr(v_msg,1,4000);--just in case
				update sys_guid set
					record_count=v_count,
					program_id=nvl(v_program_id,program_id),
					--status_code=nvl(status_code,decode(v_count,0,'ERROR','DONE')),
					status_code=decode(v_count,0,'ERROR','DONE'),
					warning=v_msg
				where id=cc.id
				and nvl(record_count,0)=0-- is null
				;
			exception when others then
				log_pkg.log(v_where, 'OTHERS:UPDATE.id='||cc.id,sqlerrm);
			end;

		end loop;

	exception when others then
		log_pkg.log(v_where, 'OTHERS.',sqlerrm);
		notice_pkg.catch(v_where, 'OTHERS.');
	end;

	/*************************************************************************/
	procedure update_sys_guid
	as
		v_where nvarchar2(99):='job_pkg.update_sys_guid';
		v_project_id nvarchar2(20);
		v_program_id nvarchar2(20);
		v_count number;
	begin
		for rr in (
					select *
					from sys_guid
					where project_id is null
					and ba_code in --only these ba_codes we will find in prepared view
						(
						'estimatesprovide',
						'goalscreate',
						'goalsdelete',
						'goalsedit',
						'importstudy',
						'importtimelinefps',
						'importtimelineplansophia',
						'ltcprovide',
						'planningassumptionsprovide',
						'projectcreate',
						'projectdelete',
						'projectedit',
						'projecteditid',
						'projectimportd1',
						'projectlead',
						'projectmove',
						'projectrelease',
						'projecttypify',
						'timelinepublish',
						'tppedit'
						)
					 and create_date > sysdate-1/24
					)
		loop
			begin
/*
				select project_id, count(1)
				into v_project_id, v_count --must be unique even if repeats many times
				from global_ba_log_guid_vw
				where gu_id=rr.id
				group by project_id;
*/
				if v_project_id is not null then
					update sys_guid set project_id=v_project_id, program_id=null
					where id=rr.id
					and project_id is null;
				end if;
			exception when others then
				null;
			end;
		end loop;

		----------------

		for pp in (
					select *
					from sys_guid
					where program_id is null
					and project_id is null
					and ba_code in --only these ba_codes we will find in prepared view
						(
						'programcreate',
						'programdelete',
						'programedit',
						'programroles',
						'sandboxplancreate'
						)
					and create_date > sysdate-1/24
					)
		loop
			begin
/*
				select program_id, count(1)
				into v_program_id, v_count --must be unique even if repeats many times
				from global_ba_log_guid_vw
				where gu_id=pp.id
				group by program_id;
*/
				if v_program_id is not null then
					update sys_guid set program_id=v_program_id
					where id=pp.id
					and program_id is null
					and project_id is null;
				end if;

			exception when others then
				null;
			end;
		end loop;

		update_sys_guid_status;

	exception when others then
		log_pkg.log(v_where, 'OTHERS.',sqlerrm);
		notice_pkg.catch(v_where, 'OTHERS.');
	end;

	/*************************************************************************/
	procedure setup_update_sys_guid
	as
		v_job_name nvarchar2(99):='SYS_GUID_JOB';
	begin
		if job_exists(v_job_name) = 0 then
			dbms_scheduler.create_job (
				job_name => v_job_name,
				job_type => 'plsql_block',
				job_action => 'begin job_pkg.update_sys_guid; commit; end;',
				start_date => sysdate+2/1440,
				repeat_interval => 'freq=minutely; interval=2;',
				end_date => null,
				enabled => true,
				comments => 'Job defined entirely by the create job procedure. Refresh sys_guid table for project_id and program_id. Job must be stopped after addapting ADF part.');
		end if;
	end;
	/*************************************************************************/

end;
/