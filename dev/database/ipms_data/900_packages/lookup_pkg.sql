create or replace 
package lookup_pkg as

	/**
	 * Sends lookups into external sys.
	 * Asynchronous.
	 * Sends update/functions message.
	 */
	procedure send(p_callback in varchar2 default null);

	/**
	 * Completes lookups propagation to external sys.
	 * Callback.
	 */
	procedure send_finish(p_payload in xmltype);

	/**
	 * Drops inactive lookup codes.
	 */
	procedure drop_inactive;

	/**
	 * Deregisters all notifications in DB.
	 */
	procedure deregister_listeners;

	procedure lock_row ( pCode in varchar2);

  procedure create_prj_goalFactor(pProjectId in varchar2, pMilestoneCode in varchar2, pFactor in number);
  
  procedure delete_prj_goalFactor(pProjectId in varchar2, pMilestoneCode in varchar2);
  
  procedure synch_prj_goalFactors;
end;
/
create or replace package body lookup_pkg as
	/*************************************************************************/
	function get_subject return nvarchar2 as
	begin
		return 'lookups';
	end;

	/*************************************************************************/
	function get_summary return nvarchar2 as
	begin
		return 'Lookups';
	end;

	/*************************************************************************/
	procedure send(p_callback in varchar2 default null) as
		v_payload xmltype;
		v_msgid nvarchar2(20);
	begin
		select xmltype('<functions '||message_pkg.xmlns_ipms||'/>')
		into v_payload
		from dual;
		
		for rr in (
		select
			xmlelement("function",
				xmlattributes(code as "id", decode(is_active,1,'false','true') as "disabled",v_payload.extract('/*/namespace::*').getStringVal() as "xmlns"),
				xmlconcat(
					xmlelement("code", code),
					xmlelement("name", '('||code||') '||name)
				)
			) r_payload
		from function
		) loop
			v_payload:=v_payload.appendChildXML('/*', rr.r_payload);
		end loop;

		v_payload:= message_pkg.xml('<update '||message_pkg.xmlns_ipms_soa||'/>').appendChildXML('/*', v_payload);
		
		v_msgid := message_pkg.send(get_subject, v_payload,
			get_text('begin lookup_pkg.send_finish(:1);%1 end;', varchar2_table_typ(p_callback)));

		notice_pkg.debug(get_subject, get_summary||' send.');
		log_pkg.log(get_subject, get_summary, 'Send.');
		
	end;

	/*************************************************************************/
	procedure send_finish(p_payload in xmltype) as
	begin
		/* validate response */
		if message_pkg.is_complete(p_payload)=0 then
			return;
		end if;
		log_pkg.log(get_subject, get_summary, 'Send_finish.');
		notice_pkg.information(get_subject, get_summary||' sent.');
	end;

	/*************************************************************************/
	procedure drop_inactive as
	begin
		delete from Therapeutic_Area where is_active=0;
		commit;
		delete from Substance_Type where is_active=0;
		commit;
		delete from Termination_Reason where is_active=0;
		commit;
		delete from Project_Source where is_active=0;
		commit;
		delete from Global_Business_Unit where is_active=0;
		commit;
		delete from Priority where is_active=0;
		commit;
		delete from Project_State where is_active=0;
		commit;
		delete from Region where is_active=0;
		commit;
		delete from Project_Category where is_active=0;
		commit;
		delete from Project_Area where is_active=0;
		commit;
		delete from News_Category where is_active=0;
		commit;
		delete from License_Type where is_active=0;
		commit;
		delete from Team_Role where is_active=0;
		commit;
	end;

	/*************************************************************************/
	procedure deregister_listeners as
		regs number;
	begin
		for reg in (select regid from USER_CHANGE_NOTIFICATION_REGS where table_name like 'IPMS_DATA%')
		loop
			dbms_change_notification.deregister(reg.regid);
		end loop;
		commit;

		select count(*) into regs from USER_CHANGE_NOTIFICATION_REGS where table_name like 'IPMS_DATA%';
		if regs > 0 then
			deregister_listeners;
		end if;
	end;

	/*************************************************************************/
	  procedure lock_row ( pCode in varchar2) is
	   lTxt varchar2(1);
	  begin
		 select '1' into lTxt
		   from termination_reason
		  where code = pCode
		   for update;
	  end lock_row;

	/*************************************************************************/
  procedure create_prj_goalFactor(pProjectId in varchar2, pMilestoneCode in varchar2, pFactor in number) is
  begin
    insert into project_goal_factor(project_id,milestone_code,goal_factor)
         values (pProjectId,pMilestoneCode,pFactor);
  end create_prj_goalFactor;

  procedure delete_prj_goalFactor(pProjectId in varchar2, pMilestoneCode in varchar2) is
  begin
      begin
        delete project_goal_factor where project_id = pProjectId and milestone_code = pMilestoneCode;
        exception when NO_DATA_FOUND then null;
      end;
  end delete_prj_goalFactor;

  procedure synch_prj_goalFactors is
  begin
    delete project_goal_factor
     where not exists ( select 1 from project_goal_factor gf
                         join project p on p.id = gf.project_id and p.area_code IN ( 'D2-PRJ', 'PRE-POT', 'POST-POT')
                         join timeline_activity ta ON ta.project_id      = gf.project_id
                                                  AND ta.milestone_code  = gf.milestone_code
                     where gf.project_id = project_goal_factor.project_id
                       and gf.milestone_code = project_goal_factor.milestone_code)
     and project_goal_factor.milestone_code not in ('D1','Termn');
  end synch_prj_goalFactors;

end;
/