create or replace package notify_pkg as

    import_type_actuals constant number(20) := 8;
    import_type_plan constant number(20) := 16;
    import_type_study constant number(20) := 64;
    import_type_raw constant number(20) := import_type_actuals + import_type_plan + import_type_study;
    tbody_tag_str varchar2(20) := '<tbody/>';

    function replace_clob_substr(src_clob in clob, replace_str in varchar2, replace_with in varchar2) return clob;

	/*************************************************************************/
	/**
	 * Sends email notification to GDD-operations to inform about project creation
	 */
	procedure project_created(p_id in nvarchar2);
	procedure project_created_finish(p_id in nvarchar2, p_payload in xmltype);

	/*************************************************************************/
	/**
	 * Sends email notification to GDD-operations to inform about project creation
	 */
	procedure published_2qplan(p_since in date := null);
	procedure published_2qplan_finish(p_payload in xmltype);

	/*************************************************************************/
	/**
	 * Sends email notification to GDD-operations about changed project identifier
	 */
	procedure project_code_changed(p_id in nvarchar2, p_code_old in nvarchar2, p_code_new in nvarchar2);

	/*************************************************************************/
	/**
	 * Sends email notification to RDControlling to inform about PIDT project changes
	 */
	procedure released_completed_pidt;
	procedure released_completed_PIDT_finish(p_payload in xmltype);

	/*************************************************************************/
	/**
	 * Sends email notification about colleted LoggedChanges
	 */
	procedure collected_changes(p_sys_job_id in nvarchar2);
	procedure collected_changes_finish(p_payload in xmltype);

	/*************************************************************************/
    /**
	 * Sends email notification about skipped of failed Import.
	 */
    -- NOTE: call get_import_msg_for_skipped_prj BEFORE starting import!
	function get_import_msg_for_skipped_prj(p_type_mask in number, p_root in xmltype default null) return xmltype;
    -- NOTE: call get_import_msg_for_failed_prj AFTER starting import!
	function get_import_msg_for_failed_prj(p_type_mask in number, p_root in xmltype default null, p_job_id in nvarchar2) return xmltype;
	function get_running_soa(p_type_mask in number, p_root in xmltype default null, p_job_id in nvarchar2) return xmltype;
    -- NOTE: parameter p_rows can be initialized using get_import_msg_for_skipped_prj() and get_import_msg_for_failed_prj()
	procedure import_failed(p_rows in xmltype);
	procedure import_failed_finish(p_payload in xmltype);

	function nvl_project_id(p_code in nvarchar2, p_sys_project_id in nvarchar2) return nvarchar2;

	--e-mail for data refresh or import issues
	procedure ipms_repo_job_failed;
	procedure import_job_not_started;
	procedure import_job_started;

	/*************************************************************************/
    /**
	 * Returns one CWID from configuration table that could be used for sending monitoring e-mails
	 */
	function get_always_1cwid return nvarchar2;

end notify_pkg;
/
create or replace package body notify_pkg
as
	v_always_cwids nvarchar2(500);
	v_email_footer nvarchar2(4000);
	g_where nvarchar2(99);
	g_subject_prefix nvarchar2(99);

	/*************************************************************************/
	function get_exception_emails return varchar2_table_typ
	as
		v_string nvarchar2(4000);
		v_comma_index  pls_integer:=0;
		v_index	pls_integer:=1;
		v_tab varchar2_table_typ := varchar2_table_typ();
		v_result nvarchar2(4000);
	begin
		v_string := configuration_pkg.get_config_value('EXCEPTION-EMAILS')||',';

		loop
			v_comma_index := instr(v_string, ',', v_index);
		exit when v_comma_index = 0;
			v_result := trim(substr(v_string, v_index, v_comma_index - v_index));
			if v_result is not null then
				v_tab.extend;
				v_tab(v_tab.count) := v_result;
			end if;
			v_index := v_comma_index + 1;
		end loop;

		return v_tab;

	exception when others then
		return null;
	end;

	/*************************************************************************/
	function get_always_1cwid return nvarchar2
	as
	begin
		return nvl(configuration_pkg.get_config_value('SEND-ALWAYS-1CWID'),'EQQVV');--always send to algis account, just for monitoring the email implementation
	exception when others then
		return 'EQQVV';
	end;

	/*************************************************************************/
	function nvl_project_id(p_code in nvarchar2, p_sys_project_id in nvarchar2) return nvarchar2
	as
	begin
		return nvl(p_code,'Missing Project Id.');
	end;

	/*************************************************************************/
	function replace_clob_substr(src_clob in clob, replace_str in varchar2, replace_with in varchar2) return clob
	as
	  v_buffer varchar2(32767);
	  v_max_amount binary_integer := 32767;
	  v_pos integer := 1;
	  v_clob_length integer;
	  v_new_clob clob := EMPTY_CLOB;
	begin
	  -- initalize the new clob
	  dbms_lob.createtemporary(v_new_clob, TRUE);
	  v_clob_length := DBMS_LOB.getlength(src_clob);
	  while v_pos < v_clob_length
	  loop
			dbms_lob.read(src_clob, v_max_amount, v_pos,v_buffer);
			if v_buffer is not null then
				 -- replace the text
				 v_buffer := replace(v_buffer, replace_str, replace_with);
				 -- write it to the new clob
				 DBMS_LOB.writeAppend(v_new_clob, length(v_buffer), v_buffer);
			END IF;
			v_pos := v_pos + v_max_amount;
	  end loop;

	  return v_new_clob;
	end;

	/*************************************************************************/
	procedure set_always_cwids as
	begin
		v_always_cwids:='<cwids><cwid>'||get_always_1cwid||'</cwid></cwids>';
	end;

	/*************************************************************************/
	procedure set_email_footer as
	begin
		v_email_footer:=
		'<p>For data protection reasons, the content cannot be displayed within this message.'||
		' For information on the content please refer to ProMIS <a href="' ||
		configuration_pkg.get_config_value('PROMIS')||
		'">(click here)</a> within the Corporate Web. This message was automatically sent by ProMIS. '||
		'In case of questions please contact ProMIS support by replying to this mail.</p>'||
		'<p>Your ProMIS support team</p>';
		g_subject_prefix := configuration_pkg.get_config_value('SENT-PRFX');
	end;

	/*************************************************************************/
	/*
		Compose notification XML message. Automatically ads CWIDs and email footer
	 */
	function notification_xml
	(
		p_subject in nvarchar2,
		p_content in clob,
		p_app_roles in varchar2_table_typ := null,
		p_app_users in varchar2_table_typ := null,
		p_exception_emails in varchar2_table_typ := null
	) return xmltype
	as
		v_payload xmltype;
	begin

		set_email_footer;

		select xmltype('<notification '||message_pkg.xmlns_ipms||'/>')
		into v_payload
		from dual;

		select
			xmlelement("notification",
				xmlattributes(
					v_payload.extract('/*/namespace::*').getStringVal() as "xmlns"
				),
				xmlconcat(
					--xmlparse(content v_always_cwids),
					xmlelement("cwids", (select xmlagg(xmlelement("cwid", column_value)) from table(p_app_users))),
					xmlelement("emails", (select xmlagg(xmlelement("email", column_value)) from table(p_exception_emails))),
					xmlelement("appRoles", (select xmlagg(xmlelement("appRole", column_value)) from table(p_app_roles))),
					--xmlelement("ldap", ('<baseDN>'||configuration_pkg.get_config_value('LDAPBASEDN')||'</baseDN>')),
					xmlelement("ldap", (select xmlagg(xmlelement("baseDN", column_value)) from table(varchar2_table_typ(configuration_pkg.get_config_value('LDAPBASEDN'))))),
					xmlelement("subject", g_subject_prefix||p_subject),
					xmlelement("content", xmlcdata(p_content || v_email_footer || '<hr />'))
				)
			)
		into v_payload
		from dual;

		return message_pkg.xml('<notify '||message_pkg.xmlns_ipms_soa||'/>').appendChildXML('/*', v_payload);

	end;

	/*************************************************************************/
	function notification_xml
	(
		p_subject nvarchar2,
		p_content clob,
		p_app_role varchar2 := null,
		p_app_user varchar2 := null,
		p_exception_email varchar2 := null
	) return xmltype
	as
	begin
		return notification_xml
		(
			p_subject => p_subject,
			p_content => p_content,
			p_app_roles => varchar2_table_typ(p_app_role),
			p_app_users => varchar2_table_typ(p_app_user),
			p_exception_emails => varchar2_table_typ(p_exception_email)
		);
	end;

	/*************************************************************************/
	procedure project_created(p_id in nvarchar2)
	as
		v_payload xmltype;
		v_msgid nvarchar2(100);
	begin
		set_always_cwids;
		set_email_footer;

		select
			appendchildxml(
				message_pkg.xml('<notify '||message_pkg.xmlns_ipms_soa||'/>'),
				'/*',
				xmltype('<notification '||message_pkg.xmlns_ipms||'>'||
				replace(v_always_cwids,'</cwids>','<cwid>MYOVU</cwid><cwid>EQWNZ</cwid><cwid>SGHVB</cwid><cwid>SGNSG</cwid></cwids>') ||
				'<emails><email>'||configuration_pkg.get_config_value('EXCEPTION-EMAILS')||'</email></emails>'||
				'<appRoles><appRole>ProjectCreatedEmail</appRole></appRoles>'||
				'<ldap><baseDN>'||configuration_pkg.get_config_value('LDAPBASEDN')||'</baseDN></ldap>'||
				'<subject>'||g_subject_prefix||'ProMIS Notification - Project Creation</subject>'||
				'<content>'||
				'<![CDATA['||
				'<p>Dear Colleague,</p>'||
				'<p>The following project has been created:</p>'||
					'<p>'||
						'<table cellpadding="5" style="padding-left: 20">'||
							'<tbody>'||
							'<tr><td>Project ID</td><td>Project Name</td><td>Project Area</td><td>Project creation date</td></tr>'||
							'<tr><td>'
							||nvl_project_id(prj.code,prj.id)||'</td><td>'
							||prj.name||'</td><td>'
							||nvl(pa.name,prj.area_code)||'</td><td>'||
							to_char(nvl(prj.update_date,prj.create_date),'dd-mm-yyyy hh24:mi:ss')||'</td></tr>'||
							'</tbody>'||
						'</table>'||
					'</p>'||
					'<p>Audit date: '||to_char(sysdate,'dd-mm-yyyy hh24:mi:ss')||'</p>'
				||v_email_footer||
				'<hr />'||
				']]>'||
				'</content>'||
				'</notification>'),
			message_pkg.xmlns_ipms_soa) as payload
			into v_payload
		from project prj
		left join project_area pa on (prj.area_code=pa.code)
		where prj.id=p_id
		;
		/* send request */
		v_msgid := message_pkg.send('email:project_created:'||p_id, v_payload,
			get_text('begin notify_pkg.project_created_finish(''%1'',:1);%2 end;', varchar2_table_typ(p_id, null)));

		log_pkg.log('email:project_created:'||p_id, 'email:project_created:'||p_id, 'notified about project creation in ProMIS.');

	exception when others then
		notice_pkg.error('email:project_created='||p_id, 'email:project_created'||p_id);
	end;

	/*************************************************************************/
	procedure project_created_finish(p_id in nvarchar2, p_payload in xmltype) as
	begin
		/* validate response */
		if message_pkg.is_complete(p_payload)=0 then
			return;
		end if;

		log_pkg.log('email:project_created:'||p_id, 'email:project_created:'||p_id, 'notified (finish) about project creation in ProMIS.');
	end;

	/*************************************************************************/
	procedure published_2qplan(p_since in date := null)
	as
		v_since date;
		v_msg_body clob;
		v_payload xmltype;
		v_msgid nvarchar2(100);
	begin
		v_since := coalesce(p_since, sysdate - 1);

		-- Collect all projects that were successfully released to FPS
		--
		for rr in (
			select
				xmlserialize(content xmlconcat(
					xmlelement("table",
						xmlattributes(
							'5' as "cellpading",
							'padding-left: 20' as "style"
						),
						xmlelement("tbody",
							xmlagg(
							xmlelement("tr",
								xmlelement("td", nvl_project_id(p.code, p.id)),
								xmlelement("td", p.name),--ToDo maybe her should be added: dbms_xmlgen.convert as well?
								xmlelement("td", '('||to_char(pa.create_date,'dd-mm-yyyy hh24:mi:ss')||') '||
								decode(pa.details.extract('local-name(.)'), 'createProject', 'created', 'updateProject', 'updated'))
							))
						)
					)
				)) msg,
				count(*) cnt
			from project_audit pa
			inner join project p on p.id = pa.project_id
			where record_type = 'FPS'
				and change_comment like '% Response: OK'
				and  pa.create_date >= v_since
			order by pa.create_date asc
		) loop

			if rr.cnt > 0 then
				v_msg_body := v_msg_body || '<p>The following projects were SUCCESSFULLY released to the FPS:</p>';
				v_msg_body := v_msg_body || rr.msg;

			end if;

		end loop;

		-- Collect all projects that failed to release
		--
		for rr in (
			select
				xmlserialize(content xmlconcat(
					xmlelement("table",
						xmlattributes(
							'5' as "cellpading",
							'padding-left: 20' as "style"
						),
						xmlelement("tbody",
							xmlagg(
							xmlelement("tr",
								xmlelement("td", nvl_project_id(p.code, p.id)),
								xmlelement("td", p.name),--ToDo maybe her should be added: dbms_xmlgen.convert as well?
								xmlelement("td", '('||to_char(pa.create_date,'dd-mm-yyyy hh24:mi:ss')||') '||pa.change_comment)
							))
						)
					)
				)) msg,
				count(*) cnt
			from project_audit pa
			inner join project p on p.id = pa.project_id
			where record_type = 'FPS'
				and change_comment not like '% Response: OK'
				and  pa.create_date >= v_since
			order by pa.create_date asc
		) loop

			if rr.cnt > 0 then
				v_msg_body := v_msg_body || '<p>The following exceptions accrued while releasing the following projects to the FPS:</p>';
				v_msg_body := v_msg_body || rr.msg;

			end if;

		end loop;

		-- Do not send message if there is nothing to send

		if v_msg_body is null then
			log_pkg.log('published_2qplan', 'published_2qplan', ' notification about project publication to FPS not sent: nothing to report.');
			return;
		end if;

		-- Compile and send the message

		v_msg_body :=
			'<p>Dear Colleague,</p>'||
			'<p>During the time from the last report:</p>'||
			v_msg_body;

		v_payload := notification_xml
		(
			p_app_roles => varchar2_table_typ('PublishedToFPSEmail'),
			p_subject => 'ProMIS, Daily notification about FPS integration',
			p_content => v_msg_body,
			p_app_users => varchar2_table_typ(get_always_1cwid, 'EQWNZ','SGHVB','SGNSG'),
			p_exception_emails => get_exception_emails
		);

		v_msgid := message_pkg.send
		(
			'email:published_2qplan',
			v_payload,
			'begin notify_pkg.published_2qplan_finish(:1); end;'
		);

		log_pkg.log('email:published_2qplan', 'email:published_2qplan', ' notified about project publication to FPS.');

	exception when others then
		notice_pkg.error('email:published_2qplan', sqlerrm);
	end;


	/*************************************************************************/
	procedure published_2qplan_finish(p_payload in xmltype) as
	begin
		/* validate response */
		if message_pkg.is_complete(p_payload)=0 then
			return;
		end if;

		log_pkg.log('email:published_2qplan', 'email:published_2qplan', ' notified (finish) about project publication to FPS.');
	end;


	/*************************************************************************/
	procedure project_code_changed(p_id in nvarchar2, p_code_old in nvarchar2, p_code_new in nvarchar2)
	as
		v_date date;
		v_msg_body clob;
		v_payload xmltype;
		v_msgid nvarchar2(100);
	begin

		v_msg_body :=
			'<p>Dear Colleague,</p>'||
			'<p>Project ID in ProMIS changed from <b>'||p_code_old||'</b> to <b>'||p_code_new||'</b>.</p>' ||
			'<p>Project ID in FPS must be updated manually .</p>' ||
			v_msg_body;


		v_payload := notification_xml
		(
			p_app_roles => varchar2_table_typ('ReleasedCompletedPIDTEmail'),--BAY_PROMIS-196
			p_subject => 'ProMIS, Project ID changed',
			p_content => v_msg_body,
			p_app_users => varchar2_table_typ(get_always_1cwid, 'EQWNZ','SGHVB','SGNSG'),
			p_exception_emails => get_exception_emails
		);

		v_msgid := message_pkg.send
		(
			'email:project_code_changed',
			v_payload,
			null
		);

		log_pkg.log('email:project_code_changed', 'email:project_code_changed', ' notified about changed project ID.');

	exception when others then
		notice_pkg.error('email:project_code_changed', sqlerrm);
	end;



	/*************************************************************************/
	procedure released_completed_PIDT
	as
		v_payload xmltype;
		v_msgid nvarchar2(100);
		v_html_table nvarchar2(32000);
	begin
		audit_pkg.pidt_audit_job(v_html_table);
		if v_html_table is not null then
			set_always_cwids;
			set_email_footer;

			if configuration_pkg.get_config_value('SENT-BY') like '%TEST%' then	--SENT-BY=PROD-System;TEST-System;DEV_NEW-System
				v_always_cwids:=replace(v_always_cwids,'</cwids>','<cwid>EQWNZ</cwid><cwid>MYJOE</cwid></cwids>');
			else-- CUC-430
				v_always_cwids:=replace(v_always_cwids,'</cwids>','<cwid>EQWNZ</cwid><cwid>MYJOE</cwid><cwid>EPRIT</cwid>'||
				'<cwid>PHGDO</cwid><cwid>TUNAG</cwid><cwid>PHOXF</cwid><cwid>GEOTL</cwid><cwid>SGQMS</cwid><cwid>SGKVH</cwid></cwids>');
			end if;

			select
				appendchildxml(
					message_pkg.xml('<notify '||message_pkg.xmlns_ipms_soa||'/>'),
					'/*',
					xmltype('<notification '||message_pkg.xmlns_ipms||'>'||
					v_always_cwids||
					'<emails><email>'||configuration_pkg.get_config_value('EXCEPTION-EMAILS')||'</email></emails>'||
					'<appRoles><appRole>ReleasedCompletedPIDTEmail</appRole></appRoles>'||
					'<ldap><baseDN>'||configuration_pkg.get_config_value('LDAPBASEDN')||'</baseDN></ldap>'||
					'<subject>'||g_subject_prefix||'ProMIS, Project Change Notification</subject>'||
					'<content>'||
					'<![CDATA['||
					'<p>Dear Colleague,</p>'||
					'<p>The following D2/Development projects have been released to the PIDT or completed/terminated in ProMIS since the last change notification:</p>'||
						'<p><table cellpadding="5" style="padding-left: 20"><tbody>'||
								'<tr><td>Project ID</td><td>Project Name</td><td>Project Area</td>'||
								'<td>(Proposed) SBE</td><td>Logged Changes</td></tr>'||
								v_html_table||
								'</tbody></table>'||
						'</p><p>Audit date: '||to_char(sysdate,'dd-mm-yyyy hh24:mi:ss')||'</p>'
					||v_email_footer||
					'<hr />'||
					']]>'||
					'</content>'||
					'</notification>'),
			  message_pkg.xmlns_ipms_soa
				) as payload
			into v_payload
			from dual;

			/* send request */
			v_msgid := message_pkg.send('email:released_completed_PIDT', v_payload,	'begin notify_pkg.released_completed_PIDT_finish(:1); end;');

			log_pkg.log('email:released_completed_PIDT', 'email:released_completed_PIDT', ' notified about project released_completed_PIDT.');
		else
			notice_pkg.information('job:EmailPidtChanges','Email:Data audit-2 job - nothing to send.');
		end if;

	exception when others then
		notice_pkg.error('email:PIDT', sqlerrm);
	end;

	/*************************************************************************/
	procedure released_completed_PIDT_finish(p_payload in xmltype)
	as
	begin
		/* validate response */
		if message_pkg.is_complete(p_payload)=0 then
			return;
		end if;

		log_pkg.log('email:released_completed_PIDT', 'email:released_completed_PIDT', ' notified (finish) about project released_completed_PIDT.');
	end;

	/*************************************************************************/
	procedure collected_changes(p_sys_job_id in nvarchar2)
	as
		v_msg_body clob;
		v_payload xmltype;
		v_msgid nvarchar2(100);
	begin

		for rr in (
			select
				xmlserialize(content xmlconcat(
					xmlelement("table",
						xmlattributes(
							'5' as "cellpading",
							'padding-left: 20' as "style"
						),
						xmlelement("tbody",
							xmlagg(
							xmlelement("tr",
								xmlelement("td", nvl_project_id(p.code, p.id)),
								xmlelement("td", p.name),--ToDo maybe her should be added: dbms_xmlgen.convert as well?
								xmlelement("td", decode(area.name, null, '', ' (Area: ' || area.name || ')') ),
								xmlelement("td", pa.change_comment)
							))
						)
					)
				)) msg,
				count(*) cnt
				from project_audit pa
				join project p on p.id = pa.project_id
                join program prog on prog.id = p.program_id
				left join project_area area on area.code = p.area_code
				where pa.sys_job_id = p_sys_job_id
                  and pa.record_type = 'IPMS'
                  and prog.code != 'RESERVED-PT-UNT'
				order by pa.create_date asc
		)
		loop
			if rr.cnt > 0 then
				v_msg_body := v_msg_body || '<p>The following projects have been changed since the last change notification:</p>';
				v_msg_body := v_msg_body || rr.msg;
			end if;
		end loop;

		-- Do not send message if there is nothing to send

		if v_msg_body is null then
			notice_pkg.debug('job:EmailLogChanges','Email:Logging data changes - nothing to send.');
		else

		-- Compile and send the message

			v_msg_body :=
				--'<p>Dear Colleague,</p>'||
				'<p>Audit date: ' || to_char(sysdate,'dd-mm-yyyy hh24:mi:ss') ||'</p>'||
				v_msg_body;

			v_payload := notification_xml
			(
				p_app_roles => varchar2_table_typ('LoggedChangesEmail'),
				p_subject => 'ProMIS, Project Change Alert, Content changed',
				p_content => v_msg_body,
				p_app_users => varchar2_table_typ(get_always_1cwid, 'EQWNZ','SGHVB','SGNSG','MYOVU'),
				p_exception_emails => get_exception_emails
			);

			v_msgid := message_pkg.send('email:collected_changes', v_payload,	'begin notify_pkg.collected_changes_finish(:1); end;');

			log_pkg.log('email:collected_changes', 'email:collected_changes', ' notified about project collected_changes.');
			notice_pkg.debug('email:collected_changes', 'email:collected_changes', ' notified about project collected_changes.');
		end if;

	exception when others then
		notice_pkg.error('email:collected_changes', sqlerrm);
	end;

	/*************************************************************************/
	procedure collected_changes_finish(p_payload in xmltype) as
	begin
		/* validate response */
		if message_pkg.is_complete(p_payload)=0 then
			return;
		end if;

		log_pkg.log('email:collected_changes', 'email:collected_changes', ' notified (finish) about project collected_changes.');
	end;

    /*************************************************************************/
    function get_import_msg_for_skipped_prj(p_type_mask in number, p_root in xmltype default null) return xmltype
	 as
		v_tbody xmltype;
		v_error xmltype;
		v_errormsq nvarchar2(32000);
		v_loop pls_integer:=0;
		----
		v_where nvarchar2(222):='notify_pkg.get_import_msg_for_skipped_prj';
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
		----
	begin
		log_pkg.steps(null,v_step_start,v_steps_result);

		select nvl(p_root, xmltype(tbody_tag_str)) into v_tbody from dual;

		for prj in (
			select
					prj.code,
					prj.id,
					dbms_xmlgen.convert(prj.name) name,
					 case when not(prj.is_syncing = 0)
								 THEN 'Import skipped. Project synchronization (e.g. with P6) in progress.'
							--when not(bitand(p_type_mask, import_type_raw) = 0 or not exists(select tl.id from timeline tl where tl.project_id = prj.id and tl.is_syncing = 1))
							when not(not exists(select tl.id from timeline tl where tl.project_id = prj.id and tl.is_syncing = 1))
								 then 'Import skipped. Timeline synchronization (e.g. with P6) in progress.'
							when not(not exists (select * from import where project_id = prj.id and status_code in ('NEW','READY','SEND') and type_mask=p_type_mask))
								 THEN 'Import skipped. The last import was NOT finished successfully. Manual action is needed before including this project to data import.'
					 END explanation
			from project prj
			where
			NOT 
				(
					 -- project is unlocked
					 prj.is_syncing = 0
					 -- timeline is unlocked
					 and (
						--bitand(p_type_mask, import_type_raw) = 0 
						--or 
						not exists(select tl.id from timeline tl where tl.project_id = prj.id and tl.is_syncing = 1)
						)
					 -- no running import for the project atm
					 -- and not exists (select * from import where project_id = prj.id and status_code in ('NEW','READY','SEND') and type_mask=p_type_mask)
				)
			and prj.program_id != 'RBIN' --skip deleted projects
			and prj.code is not null --skip projects without CODE --PROMIS-751
		)
		loop
			v_loop:=v_loop+1;
			select appendchildxml(v_tbody, '/*',
										 xmltype('<tr><td>' ||nvl_project_id(prj.code,prj.id)||', '|| prj.name || '</td>' ||
													'<td>' || prj.explanation || '</td></tr>'))
			into v_tbody
			from dual;
		end loop;

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, log_pkg.g_done||'.Skipped import for projects='||v_loop, v_steps_result);

		return v_tbody;

	exception when others then
		begin
			v_errormsq := sqlerrm;
			--log_pkg.log(g_where, 'OTHERS!',v_errormsq);
			log_pkg.catch(v_where,'OTHERS!loop_count='||v_loop,v_steps_result);

			select nvl(p_root, xmltype(tbody_tag_str)) into v_error from dual;
			select appendchildxml(v_error, '/*',
									xmltype('<tr><td>Error while creating email notification content - start part.</td><td>'
									||v_errormsq||'</td></tr>'))
			into v_error
			from dual;

			return v_error;
		exception when others then return null; end; --we will not email but at least import will continue.
    end;

    /*************************************************************************/
    function get_import_msg_for_failed_prj(p_type_mask in number, p_root in xmltype default null, p_job_id in nvarchar2) return xmltype as
		v_tbody xmltype;
		v_error xmltype;
		v_errormsq nvarchar2(32000);
		v_loop pls_integer:=0;
		----
		v_where nvarchar2(222):='notify_pkg.get_import_msg_for_failed_prj';
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
		----
	begin
		log_pkg.steps(null,v_step_start,v_steps_result);

		select nvl(p_root, xmltype(tbody_tag_str)) into v_tbody from dual;

		for pp in (
			select
				to_char(imp.update_date, 'dd-mm-yyyy hh24:mi:ss') update_date,
				prj.code,prj.id,
				dbms_xmlgen.convert(prj.name) name,
				'Import failed. ' || nvl(n.details, '') explanation
		from project prj
			join import imp on imp.project_id = prj.id and imp.status_code = 'FAIL'
			left join notice n on n.subject = 'import:' || imp.id and n.severity_code = 'ERROR'
			where
				 --nvl(imp.update_date, imp.create_date) = (select max(nvl(last_imp.update_date, last_imp.create_date)) from import last_imp where last_imp.project_id = prj.id)
				 imp.job_id=p_job_id
				 -- project is unlocked
				 -- ??? and prj.is_syncing = 0
				 -- timeline is unlocked
				 -- ??? and (bitand(p_type_mask, import_type_raw) = 0 or not exists(select tl.id from timeline tl where tl.project_id = prj.id and tl.is_syncing = 1))
			order by imp.update_date desc
		)
		loop
		v_loop:=v_loop+1;
		select appendchildxml(v_tbody, '/*',
									 xmltype('<tr><td>'
												||nvl_project_id(pp.code,pp.id)||', '||pp.name||'</td><td>'
												||pp.update_date||'-->'||pp.explanation
												||'</td></tr>'))
		into v_tbody
		from dual;
		end loop;

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, log_pkg.g_done||'.Failed imports for projects='||v_loop, v_steps_result);
		return v_tbody;

	exception when others then
		begin
			v_errormsq := sqlerrm;
			--log_pkg.log(g_where, 'OTHERS!',v_errormsq);
			log_pkg.catch(v_where,'OTHERS!loop_count='||v_loop,v_steps_result);

			select nvl(p_root, xmltype(tbody_tag_str)) into v_error from dual;
			select appendchildxml(v_error, '/*',
									xmltype('<tr><td>Error while creating email notification content - end part.</td><td>'
									||v_errormsq||'</td></tr>'))
			into v_error
			from dual;

			return v_error;
		exception when others then return null; end; --we will not email but at least import will continue.
    end;

    /*************************************************************************/
    function get_running_soa(p_type_mask in number, p_root in xmltype default null, p_job_id in nvarchar2) return xmltype as
		v_tbody xmltype;
		v_error xmltype;
		v_errormsq nvarchar2(32000);
		v_loop pls_integer:=0;
		----
		v_where nvarchar2(222):='notify_pkg.get_running_soa';
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
		----
	begin
		log_pkg.steps(null,v_step_start,v_steps_result);

		select nvl(p_root, xmltype(tbody_tag_str)) into v_tbody from dual;

		for pp in (
					select
						m.id message_id
						,m.composite_id soa_instance_id
						,decode(message_pkg.is_accept(m.response),1,'Running','Done') status
						,to_char(m.request_date,'yyyy-mm-dd hh24:mi:ss') request_time
						,m.subject
					from message m
					where m.request_date>sysdate-1
					and m.request_date<sysdate-(1/(24*2))--30min - CUC-438
					and message_pkg.is_accept(m.response)=1
					and m.subject not like 'estimate%'
					and m.subject not like 'assumptions:%'
					and m.subject <> 'cachemds_job'
					and m.subject <> 'ldap_search'
					and m.subject <> 'get_employees'
					and m.subject not like 'email:%'
					and m.callback not like 'begin project_pkg.identify_finish%'
					order by nvl(m.response_date,m.request_date) desc
		)
		loop
			v_loop:=v_loop+1;
			select appendchildxml(v_tbody, '/*',
										 xmltype('<tr><td>'
													||pp.message_id||'-'||pp.soa_instance_id||'</td><td>'
													||pp.request_time||'-->'||pp.status||'-'||pp.subject
													||'</td></tr>'))
			into v_tbody
			from dual;
		end loop;

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, log_pkg.g_done||'. Still running SOA for='||v_loop, v_steps_result);
		return v_tbody;

	exception when others then
		begin
			v_errormsq := sqlerrm;
			--log_pkg.log(g_where, 'OTHERS!',v_errormsq);
			log_pkg.catch(v_where,'OTHERS!loop_count='||v_loop,v_steps_result);

			select nvl(p_root, xmltype(tbody_tag_str)) into v_error from dual;
			select appendchildxml(v_error, '/*',
									xmltype('<tr><td>Error while creating email notification content - end part-get_running_soa.</td><td>'
									||v_errormsq||'</td></tr>'))
			into v_error
			from dual;

			return v_error;
		exception when others then return null; end; --we will not email but at least import will continue.
    end;

	/*************************************************************************/
    procedure import_failed(p_rows in xmltype)
	as
		v_payload xmltype;
		v_msgid nvarchar2(100);
		v_msg_body clob;
		v_result nvarchar2(999);
	begin
		g_where:='notify_pkg.import_failed';
		log_pkg.log(g_where, g_where, 'Starting...');

        if p_rows.getstringval() != tbody_tag_str then
			set_always_cwids;
			set_email_footer;

            select
                xmltype(replace_clob_substr(replace_clob_substr(
                    appendchildxml(
                        message_pkg.xml('<notify ' || message_pkg.xmlns_ipms_soa || '/>'),
                        '/*',
                        appendchildxml(
                            xmltype(
                                '<notification ' || message_pkg.xmlns_ipms || '>' ||
											replace(v_always_cwids,'</cwids>','<cwid>EVMFK</cwid><cwid>MYOJS</cwid></cwids>') ||
								'<emails><email>'||configuration_pkg.get_config_value('EXCEPTION-EMAILS')||'</email></emails>'||
                                '<appRoles><appRole>FailedImportEmail</appRole></appRoles>'||
								'<ldap><baseDN>'||configuration_pkg.get_config_value('LDAPBASEDN')||'</baseDN></ldap>'||
                                '<subject>'||g_subject_prefix||'ProMIS, Project Import Notification, some projects were NOT imported</subject>'||
                                '<content>'||
                                    '<fictive_cdata>'||
                                        '<p>Import date: ' || to_char(sysdate,'dd-mm-yyyy hh24:mi:ss') || '</p>'||
													 '<p>Sent by: ' || configuration_pkg.get_config_value('SENT-BY') || '</p>'||
                                        '<p>The following projects were NOT imported:</p>'||
                                        '<p>'||
                                        '<table cellpadding="5" style="padding-left: 20">'||
                                        '</table>'||
                                        '</p>' || v_email_footer ||
                                        '<hr />'||
                                    '</fictive_cdata>'||
                                '</content>'||
                                '</notification>'
                            ),
                            '/notification/content/fictive_cdata/p/table',
                            p_rows,
                            message_pkg.xmlns_ipms
                        ),
                        message_pkg.xmlns_ipms_soa
                    ).getclobval()
                    , '<fictive_cdata>', '<![CDATA['), '</fictive_cdata>', ']]>')
                ) as payload
            into v_payload
            from dual;

			v_result := 'Errors found and notified about that via e-mail.';
		else --PROMIS-750
			v_msg_body :=
				'<p>Dear Colleague,</p></p>'||
				'<p>ProMIS, data import have been finished SUCCESSFULLY.</p></p>' ||
				'<p>Import date: ' || to_char(sysdate,'dd-mm-yyyy hh24:mi:ss')||'</p>'||
				'<p>Sent by: '||configuration_pkg.get_config_value('SENT-BY')||'</p>'||
				v_msg_body;


			v_payload := notification_xml
			(
				p_app_roles => varchar2_table_typ('FailedImportEmail'),
				p_subject => 'ProMIS, data import have been finished SUCCESSFULLY.',
				p_content => v_msg_body,
				p_app_users => varchar2_table_typ(get_always_1cwid, 'EVMFK','MYOJS'),
				p_exception_emails => get_exception_emails
			);

			v_result := 'NO errors found.';
		end if;

		/* send request */
		v_msgid := message_pkg.send('email:import_resume', v_payload,	'begin notify_pkg.import_failed_finish(:1); end;');
		log_pkg.log(g_where, g_where, v_result);

	exception when others then
		log_pkg.log(g_where, 'OTHERS!', sqlerrm);
	end;

	/*************************************************************************/
	procedure import_failed_finish(p_payload in xmltype)
	as
	begin
		g_where:='notify_pkg.import_failed_finish';
		/* validate response */
		if message_pkg.is_complete(p_payload)=0 then
			return;
		end if;

		log_pkg.log(g_where, g_where, 'Notified (finish) about project import_failed.');
	end;

	/*************************************************************************/
	procedure ipms_repo_job_failed as
		v_msg_body clob;
		v_payload xmltype;
		v_msgid nvarchar2(100);
	begin
		g_where:='notify_pkg.ipms_repo_job_failed';
		v_msg_body :=
			'<p>Dear Colleague,</p>'||
			'<p>ProMIS system job for data refresh at: IPMS_REPO schema failed. For more details see IPMS_REPO.REPORTING_JOB</p>' ||
			v_msg_body;


		v_payload := notification_xml
		(
			p_app_roles => varchar2_table_typ('FailedImportEmail'),
			p_subject => 'ProMIS, data refresh for IPMS_REPO failed.',
			p_content => v_msg_body,
			p_app_users => varchar2_table_typ(get_always_1cwid, 'EVMFK','MYOJS'),
			p_exception_emails => get_exception_emails
		);

		v_msgid := message_pkg.send(
			'email:ipms_repo_job_failed',
			v_payload,
			null
		);

		log_pkg.log(g_where, g_where, 'Notified about IPMS_REPO data refresh fail.');
		--log_pkg.log('email:ipms_repo_job_failed', 'email:ipms_repo_job_failed', ' notified about IPMS_REPO data refresh fail.');

	exception when others then
		--notice_pkg.error('email:ipms_repo_job_failed', sqlerrm);
		log_pkg.log(g_where, 'OTHERS!', sqlerrm);
	end;

	/*************************************************************************/
	procedure import_job_not_started
	as
		v_msg_body clob;
		v_payload xmltype;
		v_msgid nvarchar2(100);
		v_where nvarchar2(222):='notify_pkg.import_job_not_started';
	begin
		v_msg_body :=
			'<p>Dear Colleague,</p>'||
			'<p>ProMIS system job, for data import, have NOT been started! :(</p>' ||
			'<p>Please investigate ProMIS system logs or check if data source have send XML data import triggering message.</p>' ||
			'<p>'||to_char(sysdate,'dd-mm-yyyy hh24:mi:ss')||'</p>' ||
			v_msg_body;

		v_payload := notification_xml
		(
			p_app_roles => varchar2_table_typ('FailedImportEmail'),
			p_subject => 'ProMIS, data import have NOT been started.',
			p_content => v_msg_body,
			p_app_users => varchar2_table_typ(get_always_1cwid, 'EVMFK','MYOJS'),
			p_exception_emails => get_exception_emails
		);

		v_msgid := message_pkg.send
		(
			'email:import_job_not_started',
			v_payload,
			null
		);

		log_pkg.log(v_where, v_where, 'Notified about missing data import.');

	exception when others then
		log_pkg.catch(v_where,'OTHERS!','ERROR');
	end;

	/*************************************************************************/
	procedure import_job_started
	as
		v_msg_body clob;
		v_payload xmltype;
		v_msgid nvarchar2(100);
		v_where nvarchar2(222):='notify_pkg.import_job_started';
		v_count number:=0;
		v_warning nvarchar2(1222);
		v_warning_sub nvarchar2(1222);
		iii number:=0;
	begin
		
		select count(1) into v_count from timeline where is_syncing=1;
		if v_count > 0 then
			v_warning := '<p>WARNING: The number of locked Timelines that will be skipped is:'||v_count||'</p>';
			if v_count > 10 then
				v_warning := v_warning||'<p>Please find below the first 10 records: </p>';
			end if;
			v_warning := v_warning||'<table>';
			for rr in 
				(
					select t.id, prj.code, prj.name
					from timeline t
					left join project prj on (prj.id = t.project_id)
					where t.is_syncing=1
					order by prj.name
				) 
			loop
				v_warning := v_warning||'<tr><td>'||rr.code||'</td><td>'||rr.name||'</td><td>'||rr.id||'</td></tr>';
				iii := iii +1;
				if iii > 10 then
					exit;
				end if;
			end loop;
			v_warning := v_warning||'</table>';
			v_warning_sub := 'WARNING-'||v_count;
		else
			v_warning := '<p>NOTE: All Timelines will be imported.</p>';
		end if;
		
		v_msg_body :=
			'<p>Dear Colleague,</p>'||
			'<p>ProMIS system job, for data import, have been STARTED SUCCESSFULLY! :)</p>' ||
			'<p>'||to_char(sysdate,'dd-mm-yyyy hh24:mi:ss')||'</p>' ||
			'<p/>'||
			v_warning||
			'<p/>'||
			v_msg_body;

		v_payload := notification_xml
		(
			p_app_roles => varchar2_table_typ('FailedImportEmail'),
			p_subject => 'ProMIS, data import have been started SUCCESSFULLY. '||v_warning_sub,
			p_content => v_msg_body,
			--p_app_users => varchar2_table_typ('EQQVV'), --for testing
			--p_exception_emails => null --for testing
			p_app_users => varchar2_table_typ(get_always_1cwid, 'EVMFK','MYOJS'),
			p_exception_emails => get_exception_emails
		);

		v_msgid := message_pkg.send
		(
			'email:import_job_started',
			v_payload,
			null
		);

		log_pkg.log(v_where, v_where, null);

	exception when others then
		log_pkg.catch(v_where,'OTHERS!','ERROR');
	end;

end notify_pkg;
/