create or replace package ba_log_pkg as
	--Business Activity Log

	procedure put_guid
	(
		p_guid in nvarchar2 default null,
		p_user_id in nvarchar2 default null, 
		p_ba_code in nvarchar2 default null, 
		p_project_id in nvarchar2 default null, 
		p_program_id in nvarchar2 default null,
		p_status_code in nvarchar2 default null,
		p_description in nvarchar2 default null,
		p_record_count in number default null,
		p_warning in nvarchar2 default null
	)
	;

	procedure put_guid_from_db_call(p_ba_code in nvarchar2);
	procedure put_transaction_id(p_transaction_id in nvarchar2);

	function generate_guid return varchar2;
	function get_transaction_id return varchar2;
	function get_scn(p_scn in number default null) return number;

end;
/

create or replace package body ba_log_pkg as

	/*************************************************************************/
	function get_transaction_id return varchar2 as
		v_transaction_id sys_guid_transaction.transaction_id%type;
	begin
		select
			trim(
				rpad(utl_raw.reverse(UTL_RAW.CAST_FROM_BINARY_INTEGER(regexp_substr(dbms_transaction.local_transaction_id,'[^.]+',1,1))),4,0)
			|| rpad(utl_raw.reverse(UTL_RAW.CAST_FROM_BINARY_INTEGER(regexp_substr(dbms_transaction.local_transaction_id,'[^.]+',1,2))),4,0)
			|| rpad(utl_raw.reverse(utl_raw.cast_from_binary_integer(regexp_substr(dbms_transaction.local_transaction_id,'[^.]+',1,3))),80)
					)
			into v_transaction_id
		from dual;

		return v_transaction_id;

	exception when others then
		return null;
	end;


	/*************************************************************************/
	procedure put_guid
	(
		p_guid in nvarchar2 default null,
		p_user_id in nvarchar2 default null, 
		p_ba_code in nvarchar2 default null, 
		p_project_id in nvarchar2 default null, 
		p_program_id in nvarchar2 default null,
		p_status_code in nvarchar2 default null,
		p_description in nvarchar2 default null,
		p_record_count in number default null,
		p_warning in nvarchar2 default null
	)
	is
	 v_transaction_id sys_guid_transaction.transaction_id%type;
	 v_project_id nvarchar2(20);
	 v_program_id nvarchar2(20);
	begin
		if p_guid is not null then --means new BA should be started
			if p_user_id is not null and p_ba_code is not null then --in separate "IF check", because often p_user_id could be null
				v_project_id:=substr(p_project_id,1,20);
				v_program_id:=substr(p_program_id,1,20);
				begin
					--based on ba_code list do program_id/project_id cleaning, because ADF could leave old values from the prev page/action
					--
					if p_ba_code in
										(
										'estimatesprocessdelete',
										'estimatesprocessstart',
										'estimatesprocessterminate',
										'estimatesprocessupdate',
										--'estimatesprovide', has project ID
										'estimatestagcreate',
										'estimatestagmeetingfinalize',
										'planningassumptionsstart',
										'referencesmaintain'
										) 
					then  --clear project and program
					 v_project_id:=null;
					 v_program_id:=null;
					elsif p_ba_code in
										(
										'programcreate',
										'programdelete',
										'programedit',
										'programroles',
										'sandboxplancreate'
										)
					then  --clear project
					 v_project_id:=null;
					end if;

					if v_project_id is not null then v_program_id:=null; end if;

					insert into sys_guid(id,user_id,ba_code,project_id,program_id,status_code,description,record_count,warning)
					values(p_guid,p_user_id,lower(p_ba_code),v_project_id,v_program_id,p_status_code,p_description,p_record_count,p_warning);

				exception
					when dup_val_on_index then
						null;
				end;
			end if;

			begin
				v_transaction_id:=ba_log_pkg.get_transaction_id;

				if v_transaction_id is not null then
					insert into sys_guid_transaction (guid,transaction_id)
														values (p_guid,v_transaction_id);
				end if;
			exception
				when dup_val_on_index then
					null;
			end;
		--else
			--log_pkg.log('ba_log_pkg.put_guid','p_guid='||p_guid||';p_user_id='||p_user_id||';p_ba_code='||p_ba_code, 'p_guid is NULL!');
		end if;

	exception when others then
	 log_pkg.log('ba_log_pkg.put_guid','OTHERS;p_guid='||p_guid||';p_user_id='||p_user_id||';p_ba_code='||p_ba_code, sqlerrm);
	end;


	/*************************************************************************/
	procedure put_guid_from_db_call(p_ba_code in nvarchar2)
	is
	 v_transaction_id sys_guid_transaction.transaction_id%type;
	 v_guid sys_guid_transaction.guid%type;
	begin
		if p_ba_code is not null then
			v_guid:=ba_log_pkg.generate_guid;

			begin
				insert into sys_guid(id,user_id,ba_code) values(v_guid,'PROMIS',p_ba_code);
			exception
				when dup_val_on_index then
					null;
			end;

			begin
				v_transaction_id:=ba_log_pkg.get_transaction_id;

				if v_transaction_id is not null then
					insert into sys_guid_transaction (guid,transaction_id)
														values (v_guid,v_transaction_id);
				end if;
			exception
				when dup_val_on_index then
					null;
			end;
		end if;


	exception when others then
	 log_pkg.log('ba_log_pkg.put_guid_from_db_call','OTHERS;p_ba_code='||p_ba_code, sqlerrm);
	end;

	/*************************************************************************/
	function generate_guid return varchar2 as
		v_uuid varchar2(40);
	begin
--	 return sys_guid();

	 select regexp_replace(rawtohex(sys_guid()), '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5')
	 into v_uuid from dual;
	 return v_uuid;

	exception when others then
		return null;
	end;

	/*************************************************************************/
	procedure put_transaction_id(p_transaction_id in nvarchar2) as
		v_transaction_id sys_guid_transaction.transaction_id%type;
		v_guid sys_guid_transaction.guid%type;
	begin
		--Find GUID from sys_guid_transaction table based on pending local transaction Id

		begin
			select t.guid into v_guid from sys_guid_transaction t
			where t.transaction_id=p_transaction_id;

		exception when others then
			--in case it is not unique, should not never happen, but ... so take newer one
			for rr in (
				select t.guid
				from sys_guid g
				join sys_guid_transaction t on (g.id=t.guid)
				where t.transaction_id=p_transaction_id
				order by g.create_date desc
			)
			loop
				v_guid:=rr.guid;
				exit;
			end loop;
		end;

		if v_guid is not null then
			begin
				v_transaction_id:=ba_log_pkg.get_transaction_id;

				if v_transaction_id is not null then
					insert into sys_guid_transaction (guid,transaction_id)
														values (v_guid,v_transaction_id);
				end if;
			exception
				when dup_val_on_index then
					null;
			end;
		end if;

	exception when others then
		log_pkg.log('ba_log_pkg.put_transaction_id','OTHERS;p_transaction_id='||p_transaction_id, sqlerrm);
	end;

	function get_scn(p_scn in number default null) return number as
	  v_scn number;
	begin

		select 35152949702 into v_scn from dual;

	  return v_scn;
	end;

end;
/