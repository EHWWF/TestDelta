create or replace package sandbox_pkg as

	/**
	 * 
	 */
	procedure create_start(p_id in nvarchar2, p_callback in varchar2 default null);

	/**
	 * 
	 */
	procedure create_finish(p_id in nvarchar2, p_payload in xmltype);
	/**
	 * 
	 */
	procedure delete_start(p_id in nvarchar2, p_callback in varchar2 default null);

	/**
	 * 
	 */
	procedure delete_finish(p_id in nvarchar2, p_payload in xmltype);
	
	function get_ref_atr_name(p_reference_id in nvarchar2) return varchar2;
	
	procedure delete_sandboxTimeline(p_id in nvarchar2);
end;
/
create or replace package body sandbox_pkg as
	v_subject_create_sandbox nvarchar2(50):='create:sandbox';
	v_subject_delete_sandbox nvarchar2(50):='delete:sandbox';

	/*************************************************************************/
	function get_referenceid(p_payload in xmltype) return nvarchar2 as
	begin
		return p_payload.extract('//sandbox/@referenceId', message_pkg.xmlns_ipms).getstringval();
	end;

	/*************************************************************************/
	function get_snd_id(p_payload in xmltype) return nvarchar2 as
	begin
		return p_payload.extract('//sandbox/@id', message_pkg.xmlns_ipms).getstringval();
	end;

	/*************************************************************************/
	function get_snd_code(p_payload in xmltype) return nvarchar2 as
	begin
		return p_payload.extract('//sandbox/code/text()', message_pkg.xmlns_ipms).getstringval();
	end;

	/*************************************************************************/
	function get_snd_name(p_payload in xmltype) return nvarchar2 as
	begin
		return p_payload.extract('//sandbox/name/text()', message_pkg.xmlns_ipms).getstringval();
	end;

	/*************************************************************************/
	function get_ref_atr_name(p_reference_id in nvarchar2) return varchar2 as
	begin
		if p_reference_id is not null then
		 return 'sourceReferenceId="'||p_reference_id||'" ';
		else
		 return null;
		end if;
	end;

	/*************************************************************************/
	procedure create_start(p_id in nvarchar2, p_callback in varchar2 default null) as
		v_payload xmltype;
		v_msgid nvarchar2(20);
		v_program_id nvarchar2(20);
		v_sourcereferenceid nvarchar2(200);
	begin

		select
				case
					--when ps.snd_id is not null then (select get_ref_atr_name(reference_id) as refid from program_sandbox where id=ps.snd_id)
					when ps.snd_id is not null then get_ref_atr_name(pps.reference_id)
					when ps.timeline_id is not null then get_ref_atr_name(t.reference_id)
					else null
				end as abc
		into v_sourceReferenceId
		from program_sandbox ps
		left join timeline t on (t.id=ps.timeline_id)
		left join program_sandbox pps on (pps.id=ps.snd_id)
		where ps.id=p_id;

		select
			appendchildxml(message_pkg.xml('<create '||message_pkg.xmlns_ipms_soa||'/>'),
				'/create',
				xmltype('<sandbox id="'||ps.program_id||'-'||p_id||'-SND" '||
				'programId="'||ps.program_id||'" '||v_sourceReferenceId||
				'removeDateConstraints="'||decode(ps.is_date_constraints,1,'true','false')||'" '||message_pkg.xmlns_ipms||'>'||
				'<code>'||ps.code||'</code>'||
				'<name>'||ps.name||'</name></sandbox>'),
				message_pkg.xmlns_ipms_soa
			) as payload, ps.program_id
		into v_payload, v_program_id
		from program_sandbox ps
		left join timeline t on (t.id=ps.timeline_id)
		where ps.id=p_id;

		update program set is_syncing=1 where id=v_program_id and is_syncing=0;
    update program_sandbox ps set ps.is_syncing=1 where id=p_id and is_syncing=0;

		v_msgid := message_pkg.send(
						v_subject_create_sandbox||':'||p_id,
						v_payload,
						get_text('begin sandbox_pkg.create_finish(''%1'',:1);%2 end;',
						varchar2_table_typ(p_id, p_callback))
						);

		notice_pkg.debug(v_subject_create_sandbox||':'||p_id, v_subject_create_sandbox||':'||p_id||' send.');
		--log_pkg.log(v_subject_create_sandbox||':'||p_id, v_subject_create_sandbox||':'||p_id, 'Send.');

	end;

	/*************************************************************************/
	procedure create_finish(p_id in nvarchar2, p_payload in xmltype) as
		v_referenceid nvarchar2(20);
		v_program_id nvarchar2(20);
		v_snd_id nvarchar2(20);
		--v_code nvarchar2(200);
		v_name nvarchar2(200);
	begin
		--notice_pkg.information(v_subject_create_sandbox||':'||p_id, v_subject_create_sandbox||':'||p_id||' START1.');
		if message_pkg.is_complete(p_payload)=1 then
			--notice_pkg.information(v_subject_create_sandbox||':'||p_id, v_subject_create_sandbox||':'||p_id||' START2.');
			--return;

			--notice_pkg.information(v_subject_create_sandbox||':'||p_id, v_subject_create_sandbox||':'||p_id||' START3.');
			v_referenceid := get_referenceid(p_payload);
			v_snd_id := get_snd_id(p_payload);
			--v_code := get_snd_code(p_payload);
			v_name := get_snd_name(p_payload);

			if v_referenceid is not null then
				update program_sandbox
				set reference_id=v_referenceid, snd_timeline_id=v_snd_id
				where id=p_id returning program_id into v_program_id;



					INSERT INTO TIMELINE
							(
								NAME ,
								reference_id ,
								--SND_ID ,
								START_DATE ,
								id ,
								type_code--,code
							)
							VALUES
							(
								substr(v_name,1,100) ,
								v_referenceid ,
								--v_snd_id ,
								to_date('01-01-1001','dd-mm-yyyy'),
								v_snd_id ,
								'SND'--,v_code
							);



				update program set is_syncing=0 where id=v_program_id and is_syncing=1;
        update program_sandbox ps set ps.is_syncing=0 where id=p_id and is_syncing=1;

				timeline_pkg.receive(v_snd_id);
				program_pkg.send_roles(v_program_id); -- after creation synchronize Roles for this program.

				notice_pkg.information(v_subject_create_sandbox||':'||p_id, v_subject_create_sandbox||':'||p_id||' sandbox created.');
			else
				notice_pkg.error(v_subject_create_sandbox||':'||p_id, v_subject_create_sandbox||':'||p_id||' returned reference_id is NULL.');
			end if;
		--else
			--notice_pkg.information(v_subject_create_sandbox||':'||p_id, v_subject_create_sandbox||':'||p_id||' START-ELSE.');
		end if;

	exception when others then
		notice_pkg.error(v_subject_create_sandbox||':'||p_id, v_subject_create_sandbox||':'||p_id||'.err='||sqlerrm);
		raise;
	end;



	/*************************************************************************/
	procedure delete_start(p_id in nvarchar2, p_callback in varchar2 default null) as
		v_payload xmltype;
		v_msgid nvarchar2(20);
	begin

		select
			appendchildxml(message_pkg.xml('<delete '||message_pkg.xmlns_ipms_soa||'/>'),
				'/delete',
				xmltype('<sandbox id="'||p_id||'-SND" '||
				'programId="'||ps.program_id||
				'" referenceId="'||ps.reference_id||'" '||message_pkg.xmlns_ipms||'>'||
				'<code>'||ps.code||'</code>'||
				'<name>'||ps.name||'</name></sandbox>'),
				message_pkg.xmlns_ipms_soa
			) as payload
		into v_payload
		from program_sandbox ps
		where ps.id=p_id
		and ps.reference_id is not null;

		v_msgid := message_pkg.send(
						v_subject_delete_sandbox||':'||p_id,
						v_payload,
						get_text('begin sandbox_pkg.delete_finish(''%1'',:1);%2 end;',
						varchar2_table_typ(p_id, p_callback))
						);

		log_pkg.log('sandbox_pkg.delete_start', 'p_id='||p_id, 'Delte Sandbox at P6 initiated.');

    sandbox_pkg.delete_sandboxTimeline(p_id);

	exception
		when no_data_found then
			--means that Sandbox was created with errors and deleting should not be the problem.
			log_pkg.log('sandbox_pkg.delete_start', 'p_id='||p_id, 'exception no_data_found');
		when others then
			notice_pkg.error(v_subject_delete_sandbox||':'||p_id, v_subject_delete_sandbox||':'||p_id||' error='||sqlerrm);
			raise;
	end;

	/*************************************************************************/
	procedure delete_finish(p_id in nvarchar2, p_payload in xmltype) as
		v_referenceid nvarchar2(20);
	begin
		--notice_pkg.information(v_subject_create_sandbox||':'||p_id, v_subject_create_sandbox||':'||p_id||' START1.');
		if message_pkg.is_complete(p_payload)=1 then
			--notice_pkg.information(v_subject_create_sandbox||':'||p_id, v_subject_create_sandbox||':'||p_id||' START2.');
			--return;

			--notice_pkg.information(v_subject_create_sandbox||':'||p_id, v_subject_create_sandbox||':'||p_id||' START3.');
			v_referenceid := get_referenceid(p_payload);
			if v_referenceid is not null then
				--just in case, should be delete but ...
				--delete from program_sandbox where reference_id=v_referenceid and id=p_id;
				notice_pkg.information(v_subject_delete_sandbox||':'||p_id, v_subject_delete_sandbox||':'||p_id||' sandbox deleted.');
				log_pkg.log('sandbox_pkg.delete_finish', 'p_id='||p_id, 'Sandbox deleted in P6.');
			else
				notice_pkg.error(v_subject_delete_sandbox||':'||p_id, v_subject_delete_sandbox||':'||p_id||' returned reference_id is NULL.');
				log_pkg.log('sandbox_pkg.delete_finish', 'p_id='||p_id, 'Returned reference_id is NULL.');
			end if;
		--else
			--notice_pkg.information(v_subject_create_sandbox||':'||p_id, v_subject_create_sandbox||':'||p_id||' START-ELSE.');
		end if;

	exception when others then
		notice_pkg.error(v_subject_delete_sandbox||':'||p_id, v_subject_delete_sandbox||':'||p_id||' returned reference_id is NULL.'||sqlerrm);
		log_pkg.log('sandbox_pkg.delete_finish', 'p_id='||p_id, sqlerrm);
		raise;
	end;

	/*************************************************************************/
	procedure delete_sandboxTimeline(p_id in nvarchar2) as
    begin 
     delete timeline t 
       where t.id in ( select ps.snd_timeline_id from program_sandbox ps where ps.id = p_id );
    end delete_sandboxTimeline;

end;
/