create or replace package import_employees_pkg as
--pragma serially_reusable;
	/** 
	 * PROMIS-444
	 * DB SYS JOB, once per day
	 * Get all Employees from LDAP and update Names
	 * Asynchronous.
	 * Sends request message to MW.
	 */
	procedure get_employees;

	/**
	 * Search Active Directory for a user
	 * Asynchronous.
	 * Sends request message to MW.
	 */
	procedure search_ad(p_guid in nvarchar2, p_cwid in nvarchar2, p_forename in nvarchar2, p_surname in nvarchar2);

	/**
	 * Updates staging table (employee_ad_search) for found users
	 * Callback
	 */
	procedure search_ad_finish(p_guid in nvarchar2, p_payload in xmltype);

end;
/
create or replace package body import_employees_pkg as
--pragma serially_reusable;
	g_done nvarchar2(99):='Procedure completed.';--standard text for informaing that procedure completed as expected.

	/*************************************************************************/
	procedure delete_obsole_employees as
	begin
		delete from employee 
		where nvl(update_date,create_date)<sysdate-1/24 --older than 1h
		and code not in (select distinct employee_code from team_member);
	end;

	/*************************************************************************/
	procedure get_employees as
		v_payload xmltype;
		v_msgid nvarchar2(100);
		v_where nvarchar2(99):='import_employees_pkg.get_employees';
		v_log_txt nvarchar2(111):='LDAP search request sent.';
		v_subject nvarchar2(99):='get_employees';
		v_loop pls_integer:=0;
		v_guid sys_guid_transaction.guid%type;--nvarchar2(99):='SYS_JOB';
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
	begin
		log_pkg.steps(null,v_step_start,v_steps_result);
		v_guid:=ba_log_pkg.generate_guid;
		ba_log_pkg.put_guid(v_guid,'PROMIS', v_where);
		import_employees_pkg.delete_obsole_employees;

			for rr in (
					select e.code as employee_code
					from employee e
					join (select distinct employee_code from team_member) tm on (e.code=tm.employee_code)
					where nvl(e.update_date,e.create_date)<sysdate-1/24
					order by e.code
				) 
			loop
				v_loop:=v_loop+1;

/*			
				Does not work with: "import_employees_pkg.search_ad" because exat sAMAccountName must be used
				--import_employees_pkg.search_ad(v_guid, rr.employee_code, null, null);
				select
					message_pkg.xml(
					'<read xmlns="http://xmlns.bayer.com/ipms/soa">'||
						'<ldap xmlns="http://xmlns.bayer.com/ipms">'||
							'<baseDN>'||configuration_pkg.get_config_value('LDAPBASEDN')||'</baseDN>'||
							'<searchFilter>('||chr(38)||'amp;'||
							'(|'||						
								(select 
									listagg('(sAMAccountName='||employee_code||')','')
								within group(order by employee_code)
								from (select distinct employee_code from team_member)
								)||
							')'||configuration_pkg.get_config_value('LDAPSEARCH')
							||')</searchFilter>'||
						'</ldap>'||
					  '</read>') as payload
				into v_payload
				from dual;
*/
			v_payload := xmltype('<read xmlns="http://xmlns.bayer.com/ipms/soa">'||
						'<ldap xmlns="http://xmlns.bayer.com/ipms">'||
							'<baseDN>'||configuration_pkg.get_config_value('LDAPBASEDN')||'</baseDN>'||
							'<searchFilter>sAMAccountName='||rr.employee_code||'</searchFilter>'||
							--ONLY sAMAccountName must be provided
						'</ldap>'||
					  '</read>');

			v_msgid := message_pkg.send(v_subject, v_payload, get_text('begin import_employees_pkg.search_ad_finish(''%1'',:1); end;',varchar2_table_typ(v_guid)));
		
			if mod(v_loop, 10) = 0 then
				ba_log_pkg.put_guid(v_guid,null,null);
				commit;
				dbms_lock.sleep(5); --wait to avoid creation of numerous concurent SOA-LDAP
			end if;
		end loop;
			
		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, v_log_txt||';loop_count='||v_loop, v_steps_result);
	exception when others then
		log_pkg.catch(v_where, v_log_txt||';v_msgid='||v_msgid||';loop_count='||v_loop,v_steps_result);
		raise;
	end;

	/*************************************************************************/
	procedure search_ad(p_guid in nvarchar2, p_cwid in nvarchar2, p_forename in nvarchar2, p_surname in nvarchar2) as
	PRAGMA AUTONOMOUS_TRANSACTION;
		v_payload xmltype;
		v_msgid nvarchar2(100);
		v_where nvarchar2(99):='import_employees_pkg.search_ad';
		v_cwid nvarchar2(99):=replace(p_cwid,' ');
		v_log_txt nvarchar2(111):='LDAP search request sent, GUID: '||p_guid||' Message ID: ';
		v_subject nvarchar2(99):='ldap_search';
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
	begin
		log_pkg.steps(null,v_step_start,v_steps_result);

			if length(v_cwid)>3 then 
			--do quick search as fast as possible, length=5 means that all letters were provided
			--Note. there are some exception that the length is 4
				v_payload := xmltype('<read xmlns="http://xmlns.bayer.com/ipms/soa">'||
							'<ldap xmlns="http://xmlns.bayer.com/ipms">'||
								'<baseDN>'||configuration_pkg.get_config_value('LDAPBASEDN')||'</baseDN>'||
								'<searchFilter>sAMAccountName='||v_cwid||'</searchFilter>'||
							'</ldap>'||
						  '</read>');
			else
			--Perform FULL search but on a smaller base, means, use the filter: configuration_pkg.get_config_value('LDAPSEARCH')
				v_payload := xmltype('<read xmlns="http://xmlns.bayer.com/ipms/soa">'||
							'<ldap xmlns="http://xmlns.bayer.com/ipms">'||
								'<baseDN>'||configuration_pkg.get_config_value('LDAPBASEDN')||'</baseDN>'||
								----DESCRIPTION------------------------------------------------------------
								--sAMAccountName ---> CWID
								--givenName ---> forename
								--sn ---> surname
								----DESCRIPTION------------------------------------------------------------
								'<searchFilter>('||chr(38)||'amp;'||
								case when v_cwid is not null then '(sAMAccountName='||v_cwid||'*)' end ||
								case when p_forename is not null then '(givenName='||p_forename||'*)' end ||
								--Note: wildcard could be use in front as well but it will be much slower :(, e.g. (givenName=*'||p_forename||'*)
								case when p_surname is not null then '(sn='||p_surname||'*)' end ||
								configuration_pkg.get_config_value('LDAPSEARCH')||')</searchFilter>'||
							'</ldap>'||
						  '</read>');
			end if;

		v_msgid := message_pkg.send(v_subject, v_payload, get_text('begin import_employees_pkg.search_ad_finish(''%1'',:1); end;',varchar2_table_typ(p_guid)));

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, v_log_txt||v_msgid, v_steps_result);
		commit;
	exception when others then
		log_pkg.catch(v_where, v_log_txt||v_msgid,v_steps_result);
		raise;
	end;
	
	/*************************************************************************/
	procedure search_ad_finish(p_guid in nvarchar2, p_payload in xmltype) as
		v_log_txt nvarchar2(111):='LDAP search response received, GUID: '||p_guid;
		v_where nvarchar2(99):='import_employees_pkg.search_ad_finish';
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
	begin
		log_pkg.steps(null,v_step_start,v_steps_result);
	
		/* validate response */
		if message_pkg.is_complete(p_payload)=0 then
			return;
		end if;
		
		merge into employee emp 
		using (
			select 
				nvl(extractvalue(column_value,'//employee/@cwid',message_pkg.xmlns_ipms),'Not provided by LDAP') cwid,
				nvl(extractvalue(column_value,'//employee/@forename',message_pkg.xmlns_ipms),'Not provided by LDAP') forename,
				nvl(extractvalue(column_value,'//employee/@surname',message_pkg.xmlns_ipms),'Not provided by LDAP') surname
			from table(select xmlsequence(extract(p_payload,'//employees/employee',message_pkg.xmlns_ipms)) from dual)
			union all
			select '0123-dummy!','0123-dummy!','0123-dummy!' from dual --TODO: Danas, why this is needed?
			) emp_ad
			on (emp_ad.cwid=emp.code)
			when matched then
				update 
					set
						emp.forename=emp_ad.forename,
						emp.surname=emp_ad.surname,
						emp.guid=p_guid,
						emp.update_date=sysdate,
						emp.name=replace(replace(surname,',')||', '||replace(forename,','),'  ',' ')
			when not matched then 
				insert (guid,code,forename,surname,name,create_date)
				values (p_guid,emp_ad.cwid,emp_ad.forename,emp_ad.surname,replace(replace(emp_ad.surname,',')||', '||replace(emp_ad.forename,','),'  ',' '),sysdate);

		--if p_guid='SYS_JOB' then --Means sys job that does all employee synchro with LDAP and not used ones should be deleted
		--	import_employees_pkg.delete_obsole_employees;
		--end if;

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, v_log_txt, v_steps_result);
	exception when others then
		log_pkg.catch(v_where, v_log_txt,v_steps_result);
		raise;
	end;
	
end;
/