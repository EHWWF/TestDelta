create or replace package program_pkg as

	/**
	 * Sends program into external sys.
	 * Requires unlocked instance.
	 * Throws no_data_found exception if requirements unmatched.
	 * Asynchronous.
	 * Sends create/program (if sync_date is null) or update/program message.
	 * If p_action is provided to e.g. "create" then "create" is forced
	 * Locks instance.
	 */
	procedure send(p_id in nvarchar2, p_callback in varchar2 default null, p_action in varchar2 default null);

	/**
	 * Updates program with response from external sys.
	 * Callback.
	 * Unlocks instance.
	 * Updates projects, if any included in the payload.
	 */
	procedure send_finish(p_id in nvarchar2, p_payload in xmltype);

	/**
	 * Requests program from external sys.
	 * Requires unlocked instance.
	 * Throws no_data_found exception if requirements unmatched.
	 * Asynchronous.
	 * Sends read/program message.
	 * Locks instance.
	 */
	procedure receive(p_id in nvarchar2, p_callback in varchar2 default null);

	/**
	 * Updates program with response from external sys.
	 * Callback.
	 * Unlocks instance.
	 * Updates projects, if any included in the payload.
	 */
	procedure receive_finish(p_id in nvarchar2, p_payload in xmltype);

	/**
	 * Sends program roles into external sys.
	 * Asynchronous.
	 * Sends update/roles message.
	 * p_project_type in ('D3Tr','PrdMnt','Dev') -> depends on ProMIS main=left ADF menu.
	 */
	procedure send_roles(p_id in nvarchar2, p_callback in varchar2 default null, p_project_type in varchar2 default null);

	/**
	 * Completes roles upload.
	 * Callback.
	 * Unlocks instance.
	 */
	procedure send_roles_finish(p_id in nvarchar2, p_payload in xmltype);

	/**
	 * Discards running activities for the program.
	 * Unlocks instance.
	 * Closes related messages.
	 */
	procedure unlock(p_id in nvarchar2);

	/**
	 * Deletes program from external sys.
	 * Requires unlocked instance without projects.
	 * Throws no_data_found exception if requirements unmatched.
	 * Asynchronous.
	 * Sends delete/program message.
	 */
	procedure delete(p_id in nvarchar2, p_callback in varchar2 default null);

	/**
	 * Updates program with data from xml.
	 * Updates projects, if any presented in xml.
	 */
	procedure save(p_payload in xmltype);

	/**
	 * Returns xml representation of the program.
	 * 0 - core
	 * 1 - code,name
	 * 2 - roles
	 */
	function xml(p_id in nvarchar2, p_full in number default 1) return xmltype;

	/**
	 * Returns summary of program.
	 */
	function get_summary(p_id in nvarchar2) return nvarchar2;

	/**
	 * Returns subject of program.
	 */
	function get_subject(p_id in nvarchar2) return nvarchar2;

	/**
	 * Sends roles for all unlocked programs.
	 */
	procedure send_roles;

	/**
	 * Inserts new program
	 */
	procedure create_program(p_code in nvarchar2, p_name in nvarchar2, p_id out nvarchar2);

	/**
	 * generate Application Role list: master with detail
	 */
	function get_approles(p_id in nvarchar2) return xmltype;

end;
/
create or replace package body program_pkg as
	vg_where nvarchar2(99);

	/*************************************************************************/
	function get_summary(p_id in nvarchar2) return nvarchar2 as
		v_info nvarchar2(100);
	begin
		select 'Program['||id||','||nvl(code,'-')||']'
		into v_info
		from program
		where id=p_id;

		return v_info;

	exception when no_data_found then
		return 'Program['||nvl(p_id,'-')||']';
	end;

	/*************************************************************************/
	function get_subject(p_id in nvarchar2) return nvarchar2 as
	begin
		return 'program:'||p_id;
	end;

	/*************************************************************************/
	procedure send_message(p_id in nvarchar2, p_payload in xmltype, p_callback in varchar2, p_is_syncing in number default 1) as
		msgid nvarchar2(20);
		subject nvarchar2(50);
	begin
		/* check status */
		select get_subject(id) into subject
		from program where id=p_id and is_syncing=0;

		/* send request */
		msgid := message_pkg.send(subject, p_payload, p_callback);

		/* mark as in sync */
		update program set is_syncing=p_is_syncing, sync_id=msgid where id=p_id;
	end;

	/*************************************************************************/
	procedure unlock(p_id in nvarchar2) as
	begin
		update program set is_syncing=0 where id=p_id;
	end;

	/*************************************************************************/
	procedure send(p_id in nvarchar2, p_callback in varchar2 default null, p_action in varchar2 default null) as
		payload xmltype;
	begin
		/* setup either create or update request */
		select
			appendchildxml(
				message_pkg.xml(nvl2(sync_date,(decode(p_action,null,'<update','<'||p_action)),'<create')||' '||message_pkg.xmlns_ipms_soa||'/>'),
				'/*', xml(id,2), message_pkg.xmlns_ipms_soa
			) as payload
		into payload
		from program
		where id=p_id;

		/* send request */
		send_message(p_id, payload,
			get_text('begin program_pkg.send_finish(''%1'',:1);%2 end;', varchar2_table_typ(p_id, p_callback)), case when p_action='create' then 0 else 1 end);

		notice_pkg.debug(get_subject(p_id), get_summary(p_id)||' send.');
		log_pkg.log(get_subject(p_id), get_summary(p_id), 'Send.');
	end;

	/*************************************************************************/
	procedure receive(p_id in nvarchar2, p_callback in varchar2 default null) as
		payload xmltype;
	begin
		/* setup the request */
		select
			message_pkg.xml(
				'<read '||message_pkg.xmlns_ipms_soa||'>'||
					xml(id, 0)||
				'</read>'
			) as payload
		into payload
		from program
		where id=p_id;

		/* send request */
		send_message(p_id, payload,
			get_text('begin program_pkg.receive_finish(''%1'',:1);%2 end;', varchar2_table_typ(p_id, p_callback)));

		notice_pkg.debug(get_subject(p_id), get_summary(p_id)||' receive.');
	end;

	/*************************************************************************/
	procedure send_finish(p_id in nvarchar2, p_payload in xmltype) as
	begin
		receive_finish(p_id, p_payload);
	end;

	/*************************************************************************/
	procedure receive_finish(p_id in nvarchar2, p_payload in xmltype) as
	begin
		/* validate response */
		if message_pkg.is_complete(p_payload)=0 then
			return;
		end if;

		/* stop sync */
		update program set is_syncing=0 where id=p_id;

		/* update with data from soa */
		save(p_payload);

		notice_pkg.information(get_subject(p_id), get_summary(p_id)||' synchronized.');
	end;

	/*************************************************************************/
	procedure save(p_payload in xmltype) as
	begin
		update program set
			sync_date=sysdate,
			name=utl_i18n.unescape_reference(extract(p_payload,'//program/name/text()',message_pkg.xmlns_ipms).getstringval())
		where id=p_payload.extract('//program/@id',message_pkg.xmlns_ipms).getstringval();

		/* update related projects */
		project_pkg.save(p_payload);
	end;

	/*************************************************************************/
	procedure delete(p_id in nvarchar2, p_callback in varchar2 default null) as
		payload xmltype;
	begin
		/* setup request for empty program */
		select
			appendchildxml(
				message_pkg.xml('<delete '||message_pkg.xmlns_ipms_soa||'/>'),
				'/*', xml(p_id, 0), message_pkg.xmlns_ipms_soa
			) as payload
		into payload
		from program
		where id=p_id and not exists (select * from project where program_id=p_id);

		/* send request */
		send_message(p_id, payload, p_callback);

		notice_pkg.debug(get_subject(p_id), get_summary(p_id)||' delete.');
		log_pkg.log(get_subject(p_id), get_summary(p_id), 'Delete.');
	end;

	/*************************************************************************/
	function get_approles(p_id in nvarchar2) return xmltype as
		v_nvarchar nvarchar2(32000);
		v_payload xmltype;
	begin
		for rr in (
				select '<appRole refAppRole="'||masterapprole||'">'||detailapprole||'</appRole>' rowww
				from opss_app_roles_vw
				where (
							detailapprole like lower('ProjectCreateAssigned%')
						or detailapprole like lower('TimelineEditRawAssigned%')
						or detailapprole like lower('ProjectViewAssigned%')
						or detailapprole in (lower('SandboxPlanModifyAssignedDev'),lower('SandboxPlanDeleteAssignedDev'))
						)
				and masterapprole in (select role_code from user_role ur where ur.program_id=p_id)
				)
				loop
					v_nvarchar:=v_nvarchar||rr.rowww;
				end loop;

		if v_nvarchar is not null then
			select xmltype('<appRoles>'||v_nvarchar||'</appRoles>') into v_payload from dual;
			return v_payload;
		else
			return null;
		end if;

	exception when others then
		log_pkg.log('program_pkg.get_approles','p_id='||p_id,sqlerrm);
		return null;
	end;

	/*************************************************************************/
	procedure send_roles(p_id in nvarchar2, p_callback in varchar2 default null, p_project_type in varchar2 default null) as
		payload xmltype;
	begin
	--p_project_type in ('D3Tr','PrdMnt','Dev')

		/* prepare request */
		select
			message_pkg.xml(
				'<update '||message_pkg.xmlns_ipms_soa||'>'||
					'<roles programId="'||id||'" projectType="'||upper(nvl(p_project_type,'DEV'))||'" '||message_pkg.xmlns_ipms||'>'||
						(
						select listagg('<role userId="'||user_id||'" roleId="'||role_code||'"/>','') within group(order by id)
						from user_role ur where ur.program_id=prg.id
						)||
						get_approles(p_id)||
					'</roles>'||
				'</update>'
			) as payload
		into payload
		from program prg
		where id=p_id;

		/* send request */
		send_message(p_id, payload,
			get_text('begin program_pkg.send_roles_finish(''%1'',:1);%2 end;', varchar2_table_typ(p_id, p_callback)));

		notice_pkg.debug(get_subject(p_id), get_summary(p_id)||' roles send.');
		log_pkg.log(get_subject(p_id), get_summary(p_id), 'Roles send.');

	exception when others then
		log_pkg.log('program_pkg.send_roles','p_id='||p_id||';p_callback='||p_callback||';p_project_type='||p_project_type,sqlerrm);
		raise;
	end;

	/*************************************************************************/
	procedure send_roles_finish(p_id in nvarchar2, p_payload in xmltype) as
	begin
		/* validate response */
		if message_pkg.is_complete(p_payload)=0 then
			return;
		end if;

		/* stop sync */
		update program set is_syncing=0 where id=p_id;

		notice_pkg.information(get_subject(p_id), get_summary(p_id)||' roles sent.');
	end;

	/*************************************************************************/
	function xml(p_id in nvarchar2, p_full in number default 1) return xmltype as
		payload xmltype;
	begin
		/* generate xml representation */
		select
			xmltype(
				'<program id="'||id||'" '||message_pkg.xmlns_ipms||'>'||
					decode(p_full,0,'',get_element('code',code))||
					decode(p_full,0,'',get_element('name',name))||
					--areaCode is needed before creating, dedicated EPS, for MAINtenance projects. If Program has at least one MNT project then send areaCode
					decode((select count(1) from project where program_id = p_id and area_code='PRD-MNT' and rownum=1),1,get_element('areaCode','PRD-MNT'),'')||
					decode(p_full,2,'<roles programId="'||id||'">'
						||(select listagg('<role userId="'||user_id||'" roleId="'||utl_i18n.escape_reference(role_code)||'"/>','')
						within group(order by id)
						from user_role ur where ur.program_id=prg.id)||'</roles>','')||
				'</program>'
			)
		into payload
		from program prg
		where id=p_id;

		return payload;
	end;

	/*************************************************************************/
	procedure send_roles as
	begin
		vg_where :='program_pkg.send_roles;';
		log_pkg.log(vg_where, 'TODO', 'MONITOR USAGE!!!');--TODO, if not used, then delete this procedure with COM-MIT

		for prg in (select id from program where is_syncing=0 and id<>'RBIN')
		loop
			send_roles(prg.id);
			commit;
		end loop;
	end;

	/*************************************************************************/
	procedure create_program(p_code in nvarchar2, p_name in nvarchar2, p_id out nvarchar2) as
	begin
		insert into program (code, name) values(p_code,p_name) returning id into p_id;
	end;


end;
/