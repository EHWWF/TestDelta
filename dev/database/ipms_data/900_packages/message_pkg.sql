create or replace package message_pkg as
--pragma serially_reusable;
	/** Xml namespaces. */
/*
	xmlns_ipms constant nvarchar2(100) := 'xmlns="http://xmlns.bayer.com/ipms"';
	xmlns_ipms_soa constant nvarchar2(100) := 'xmlns="http://xmlns.bayer.com/ipms/soa"';
	xmlns_ipms_qplan constant nvarchar2(100) := 'xmlns="http://xmlns.bayer.com/ipms/qplan"';

	nsuri_ipms constant nvarchar2(100) := 'http://xmlns.bayer.com/ipms';
	nsuri_ipms_soa constant nvarchar2(100) := 'http://xmlns.bayer.com/ipms/soa';
	nsuri_ipms_qplan constant nvarchar2(100) := 'http://xmlns.bayer.com/ipms/qplan';
*/
	function xmlns_ipms return nvarchar2;
	function xmlns_ipms_soa return nvarchar2;
	function xmlns_ipms_qplan return nvarchar2;
	function nsuri_ipms return nvarchar2;
	function nsuri_ipms_soa return nvarchar2;
	function nsuri_ipms_qplan return nvarchar2;

	/** Xml header. */
	--xml_header constant nvarchar2(100) := '<?xml version="1.0" encoding="utf-8" ?>';

	/**
	 * Sends message into soa via request queue.
	 * Returns message id.
	 */
	function send(p_subject in nvarchar2, p_payload in xmltype, p_callback in varchar2) return nvarchar2;

	/**
	 * Handles response message from soa.
	 * Invokes callback (if any).
	 * Handles all exceptions from callback.
	 * Handles unmatched responses (no request exists).
	 */
	procedure receive(p_payload in xmltype);

	/**
	 * Terminates message by id.
	 * Returns message id of termination request.
	 */
	function terminate(p_id in nvarchar2, p_component in varchar2, p_callback in varchar2) return nvarchar2;

	/**
	 * Returns 1 if payload contains response/accept.
	 */
	function is_accept(p_payload in xmltype) return number;

	/**
	 * Returns 1 if payload contains response/complete.
	 */
	function is_complete(p_payload in xmltype) return number;

	/**
	 * Returns 1 if payload contains response/reject.
	 */
	function is_reject(p_payload in xmltype) return number;

	/**
	 * Returns 1 if payload contains response/error.
	 */
	function is_error(p_payload in xmltype) return number;

	/**
	 * Returns stage from payload message.
	 */
	function get_stage(p_payload in xmltype) return nvarchar2;

	/**
	 * Startups aq.
	 */
	procedure setup;

	/**
	 * Shutdowns aq.
	 */
	procedure teardown;

	/**
	 * Forced purges all queues.
	 */
	procedure purge;

	/**
	 * Safely cleanups old messages.
	 */
	procedure cleanup;

	/**
	 * Returns summary of message.
	 */
	function get_summary(p_id in nvarchar2) return nvarchar2;

	/**
	 * Returns subject of message.
	 */
	function get_subject(p_id in nvarchar2) return nvarchar2;

	/**
	 * Generates xml.
	 */
	function xml(p_contents in nvarchar2) return xmltype;

	/**
	 * Sends users into external sys.
	 * Asynchronous.
	 * Sends update/users message.
	 */
	procedure send_users(p_callback in nvarchar2 default null, p_projectType in nvarchar2 default null);

	/**
	 * Handles response from external sys.
	 * Callback.
	 */
	procedure send_users_finish(p_payload in xmltype);

	/**
	 * parses callback and initiates missing update P6 users Calls
	 *
	 */
	procedure parse_send_users(p_payload in xmltype, p_projectType in nvarchar2);

end;
/
create or replace package body message_pkg as
--pragma serially_reusable;
	/* keep track of message relationships */
	g_msgid nvarchar2(20);

	/*************************************************************************/
	function xmlns_ipms return nvarchar2
	as
	begin
		return 'xmlns="http://xmlns.bayer.com/ipms"';
	end;
	/*************************************************************************/
	function xmlns_ipms_soa return nvarchar2
	as
	begin
		return 'xmlns="http://xmlns.bayer.com/ipms/soa"';
	end;
	/*************************************************************************/
	function xmlns_ipms_qplan return nvarchar2
	as
	begin
		return 'xmlns="http://xmlns.bayer.com/ipms/qplan"';
	end;
	/*************************************************************************/
	function nsuri_ipms return nvarchar2
	as
	begin
		return 'http://xmlns.bayer.com/ipms';
	end;
	/*************************************************************************/
	function nsuri_ipms_soa return nvarchar2
	as
	begin
		return 'http://xmlns.bayer.com/ipms/soa';
	end;
	/*************************************************************************/
	function nsuri_ipms_qplan return nvarchar2
	as
	begin
		return 'http://xmlns.bayer.com/ipms/qplan';
	end;

	/*************************************************************************/
	function xml(p_contents in nvarchar2) return xmltype as
	begin
		return xmltype('<?xml version="1.0" encoding="utf-8" ?>'||p_contents);
	end;

	/*************************************************************************/
	function get_summary(p_id in nvarchar2) return nvarchar2 as
		v_info nvarchar2(100);
	begin
		select 'Message['||id||','||get_char_date(request_date)||','||nvl2(composite_id,composite_id||','||get_char_date(response_date),'-')||']'
		into v_info
		from message
		where id=p_id;

		return v_info;

	exception when no_data_found then
		return 'Message['||nvl(p_id,'-')||']';
	end;

	/*************************************************************************/
	function get_subject(p_id in nvarchar2) return nvarchar2 as
		v_subj nvarchar2(100);
	begin
		select 'message:'||nvl(p_id,'-')
		into v_subj
		from dual;

		return v_subj;
	end;

	/*************************************************************************/
	procedure cleanup as
	begin
		--keep finished messages only for one week
		delete from message
		where (sysdate - request_date) > 90 --365/2
		and (sysdate - response_date) > 90 --365/2
		;
	end;

	/*************************************************************************/
	function is_error(p_payload in xmltype) return number as
	begin
		return case when p_payload is null or p_payload.existsnode('//error', xmlns_ipms)=1 then 1 else 0 end;
	end;

	/*************************************************************************/
	function is_reject(p_payload in xmltype) return number as
	begin
		return case when p_payload is not null then p_payload.existsnode('//reject', xmlns_ipms) else 0 end;
	end;

	/*************************************************************************/
	function is_accept(p_payload in xmltype) return number as
	begin
		return case when p_payload is not null then p_payload.existsnode('//accept', xmlns_ipms) else 0 end;
	end;

	/*************************************************************************/
	function is_complete(p_payload in xmltype) return number as
	begin
		return case when p_payload is not null then p_payload.existsnode('//complete', xmlns_ipms_soa) else 0 end;
	end;

	/*************************************************************************/
	function get_stage(p_payload in xmltype) return nvarchar2 as
	begin
		return p_payload.extract('//complete/@stageId', xmlns_ipms_soa).getstringval();
	end;

	/*************************************************************************/
	function send(p_subject in nvarchar2, p_payload in xmltype, p_callback in varchar2) return nvarchar2
	as
		v_where nvarchar2(99):='message_pkg.send';
		v_par nvarchar2(4000):='p_subject='||p_subject||';p_callback='||p_callback;
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
        v_msg_out nvarchar2(4000);
		payload xmltype;
		message_id nvarchar2(20);
		enqueue_options dbms_aq.enqueue_options_t;
		message_properties dbms_aq.message_properties_t;
		message_handle raw(16);
		valid number;

	begin
		log_pkg.steps(null, v_step_start, v_steps_result);
		-- get id for new message - will be injected into xml
		select message_id_seq.nextval into message_id from dual;
		v_par:=v_par||';message_id='||message_id;

		-- inject id and wrap payload into request element
		select appendchildxml(
			xmltype('<?xml version="1.0" encoding="utf-8" ?><request '||xmlns_ipms_soa||' id="'||message_id||'"/>'),'/*',
			insertchildxml(p_payload,'/*','@id',message_id))
		into payload from dual;

		-- save message
		insert into message(id,request,subject,callback, parent_id)
		values(message_id,payload,p_subject,p_callback, g_msgid);

		-- send message
		dbms_aq.enqueue(
			queue_name=>'ipms_data.request_aq',
			payload=>payload,
			enqueue_options=>enqueue_options,
			message_properties=>message_properties,
			msgid=>message_handle);

		--notice_pkg.debug(get_subject(message_id), get_summary(message_id)||' request sent.', payload.getclobval());
		log_pkg.steps('END', v_procedure_start, v_steps_result);
		log_pkg.slog(v_where, v_par, v_steps_result);-- || v_msg_out);
		return message_id;

	exception when others then
		--notice_pkg.catch(get_subject(message_id), get_summary(message_id)||' request sending failed!');
		log_pkg.steps('ERROR', v_procedure_start, v_steps_result);
		log_pkg.scatch(v_where, v_par, v_steps_result || v_msg_out);
	end;

	/*************************************************************************/
	procedure receive(p_payload in xmltype)
	as
		v_where nvarchar2(222) := 'message_pkg.receive';
		v_par nvarchar2(4000);
        v_rowcount number := 0;
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
		v_msg_out nvarchar2(4000);
		msgid nvarchar2(20);
		payload xmltype;
		msg message%rowtype;
		valid number;

	begin
		log_pkg.steps(null, v_step_start, v_steps_result);
		-- extract response details
		msgid := p_payload.extract('/response/@id',xmlns_ipms_soa).getstringval();
		v_par:='msgid='||msgid;
		payload := p_payload.extract('/response/*',xmlns_ipms_soa);

		-- look for related message
		begin
			select * into msg from message where id=msgid;
		exception when no_data_found then
			v_msg_out:=v_msg_out||';Response has unmatched id!';
			log_pkg.steps('ERROR', v_procedure_start, v_steps_result);
			log_pkg.scatch(v_where, v_par, v_steps_result || v_msg_out);
			return;
		end;

		-- keep track of the message currently being processed
		g_msgid := msgid;

		-- validate xml - turning off validation on 2015-03-13, no added value
		--select xmlisvalid(p_payload, 'http://xmlns.bayer.com/ipms/soa/soa.xsd') into valid from dual;
		--if valid=0 then
		--	notice_pkg.debug(get_subject(msgid), get_summary(msgid)||' response has invalid payload!', p_payload.getClobVal());
		--end if;

		-- save response
		update message
		set response=p_payload,response_date=sysdate
		where id=msgid;

		v_rowcount := sql%rowcount;
		log_pkg.steps('a' || v_rowcount, v_step_start, v_steps_result);
		--notice_pkg.debug(get_subject(msgid), get_summary(msgid)||' response received.', p_payload.getClobVal());

		-- save composite
		if is_accept(p_payload)=1 then
			update message
			set composite_id=p_payload.extract('//accept/@compositeId',xmlns_ipms).getStringVal()
			where id=msgid;
		end if;

		-- use callback if have one
		if msg.callback is not null then
			execute immediate msg.callback using payload;
		end if;

		-- finish processing
		if is_accept(p_payload)=1 then
			--notice_pkg.debug(get_subject(msgid), get_summary(msgid)||' accepted.');
			v_msg_out:=v_msg_out||';accepted.';
		elsif is_complete(p_payload)=1 then
			--notice_pkg.debug(get_subject(msgid), get_summary(msgid)||' completed.');
			v_msg_out:=v_msg_out||';completed.';
		elsif is_error(p_payload)=1 then
			--notice_pkg.debug(get_subject(msgid), get_summary(msgid)||' failed.',p_payload.extract('//description/text()',xmlns_ipms).getstringval());
			v_msg_out:=v_msg_out||';failed.';
		elsif is_reject(p_payload)=1 then
			--notice_pkg.debug(get_subject(msgid), get_summary(msgid)||' rejected.',p_payload.extract('//description/text()',xmlns_ipms).getstringval());
			v_msg_out:=v_msg_out||';rejected.';
		end if;

		log_pkg.steps('END', v_procedure_start, v_steps_result);
		log_pkg.slog(v_where, v_par, v_steps_result || v_msg_out);

	exception when others then
		v_msg_out:=v_msg_out||';Response processing failed!';
		log_pkg.steps('ERROR', v_procedure_start, v_steps_result);
		log_pkg.scatch(v_where, v_par, v_steps_result || v_msg_out);
		g_msgid := null;
	end;

	/*************************************************************************/
	procedure setup as
	begin
		dbms_aqadm.start_queue(
			queue_name=>'request_aq');

		dbms_aqadm.start_queue(
			queue_name=>'response_aq');

		dbms_aqadm.grant_queue_privilege('ALL','ipms_data.request_aq','SYS');

		dbms_aq.register(
			sys.aq$_reg_info_list(
				sys.aq$_reg_info(
					'ipms_data.response_aq',
					dbms_aq.namespace_aq,
					'plsql://ipms_data.response_callback',
					null)), 1);
	end;

	/*************************************************************************/
	procedure teardown as
	begin
		begin
			dbms_aq.unregister(
				sys.aq$_reg_info_list(
					sys.aq$_reg_info(
						'ipms_data.response_aq',
						dbms_aq.namespace_aq,
						'plsql://ipms_data.response_callback',
						null)), 1);
		exception
			when others then null;
		end;

		dbms_aqadm.stop_queue(
			queue_name=>'request_aq');

		dbms_aqadm.stop_queue(
			queue_name=>'response_aq');
	end;

	/*************************************************************************/
	procedure purge as
		po dbms_aqadm.aq$_purge_options_t;
	begin
		dbms_aqadm.purge_queue_table('request_qt', null, po);
		dbms_aqadm.purge_queue_table('response_qt', null, po);
	end;

	/*************************************************************************/
	function terminate
		(
			p_id in nvarchar2,
			p_component in varchar2,
			p_callback in varchar2
		) return nvarchar2
	as
		v_where nvarchar2(222):='message_pkg.terminate';
		v_par nvarchar2(4000):='p_id='||p_id||';p_component='||p_component||';p_callback='||p_callback;
		v_payload xmltype;
		v_subject message.subject%type;
		v_composite_id nvarchar2(20);

	begin
		select
			xmltype(
			'<?xml version="1.0" encoding="utf-8" ?>'||
			'<terminate '||message_pkg.xmlns_ipms_soa||' compositeId="'||composite_id||'" componentName="'||p_component||'" />'
			) as payload, subject, composite_id
			into v_payload, v_subject, v_composite_id
		from message
		where id=p_id;

		if v_composite_id is not null then
			log_pkg.slog(v_where, v_par, 'Terminating...v_composite_id='||v_composite_id);
			return send(v_subject, v_payload, p_callback);
		else
			log_pkg.slog(v_where, v_par, 'ERROR. Missing composite_id ! Termination must be repeated by user from UI.');
			return null;
		end if;
	end;

	/*************************************************************************/
	function get_summary return nvarchar2 as
	begin
		return 'Users';
	end;

	/*************************************************************************/
	procedure send_users(p_callback in nvarchar2 default null, p_projectType in nvarchar2 default null) as
		payload xmltype;
		msgid nvarchar2(20);
		v_subject nvarchar2(50);
		v_callback nvarchar2(32000);
		v_projecttype nvarchar2(50):=nvl(p_projecttype,'D3TR');
		v_nextProjectType nvarchar2(50);
	begin
		v_subject := 'update:users:'||v_projecttype;

		--send 4 times, every time with different context, one by one (sequential mode).
		if v_projecttype = 'D3TR' then --it is the first time
			v_nextprojecttype := 'D2PRJ';
		elsif v_projecttype = 'D2PRJ' then
			v_nextprojecttype := 'PRDMNT';
		elsif v_projecttype = 'PRDMNT' then
			v_nextprojecttype := 'DEV';
		elsif v_projecttype = 'DEV' then
        	v_nextprojecttype := 'SAMD';
		elsif v_projecttype = 'SAMD' then        --PROMIS 604
			v_nextprojecttype := 'STOP';
		else
			return; --STOP
		end if;

		select message_pkg.xml('<update '||message_pkg.xmlns_ipms_soa||
		'><users projectType="'||v_projectType||'" '||message_pkg.xmlns_ipms||'/></update>')
		into payload
		from dual;

		/* send request */
		msgid := message_pkg.send(v_subject, payload,
			get_text('begin message_pkg.send_users_finish(:1);%1 end;',
			varchar2_table_typ(nvl(p_callback,'begin message_pkg.parse_send_users(:1,'''||v_nextProjectType||'''); end;'))));

		--notice_pkg.debug(v_subject, get_summary||' send.');
		log_pkg.slog(v_subject, get_summary, 'Send.');

	end;

	/*************************************************************************/
	procedure send_users_finish(p_payload in xmltype) as
	begin
		/* validate response */
		if message_pkg.is_complete(p_payload)=0 then
			return;
		end if;

		--notice_pkg.information('users', get_summary||' sent.');
		log_pkg.slog('message_pkg.send_users_finish', null, 'Send.');
	end;

	/*************************************************************************/
	procedure parse_send_users(p_payload in xmltype, p_projectType in nvarchar2) as
	begin
		if message_pkg.is_accept(p_payload)=1 then --ELSE invoke parse_send
			return;
		end if;

		message_pkg.send_users(null,p_projectType);

		log_pkg.slog('message_pkg.parse_send_users', p_projectType, 'Send.');

	end;

end;
/