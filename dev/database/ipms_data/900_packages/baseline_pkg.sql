create or replace package baseline_pkg as

	--Finish for: Read ALL baselines for selected Timeline
	procedure read_baselines_finish(p_id in nvarchar2, p_payload in xmltype);

	--Start for: Read ONE baseline by ObjectId
	procedure read_baseline(p_id in nvarchar2);
	
	--Finish for: Read ONE baseline by ObjectId
	procedure read_baseline_finish(p_id in nvarchar2, p_payload in xmltype);
	
	/*************************************************************************/
	--Get all missing baselines before updating IPMS_REPO
	--procedure should be started from IPMS_REPO user before running IPMS_REPO Update procedure
	procedure get_missing_baselines;
end;
/
create or replace package body baseline_pkg as

	/*************************************************************************/
	--Get all missing baselines before updating IPMS_REPO
	--procedure should be started from IPMS_REPO user before running IPMS_REPO Update procedure
	procedure get_missing_baselines
	as
		v_log_txt nvarchar2(111):='Getting missing baselines.';
		v_where nvarchar2(99):='baseline_pkg.get_missing_baselines';
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
		iii pls_integer:=0;
	begin
		log_pkg.steps(null,v_step_start,v_steps_result);

		for rr in (select id from timeline_baseline where details is null order by id)
		loop
			iii:=iii+1;
			if iii>1 then
				dbms_lock.sleep(5);
			end if;

			baseline_pkg.read_baseline(rr.id);
			commit; --otherwise it could take ages until Job will commit it.
		end loop;

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, v_log_txt, v_steps_result);

	exception when others then
		log_pkg.catch(v_where, v_log_txt,v_steps_result);
		raise;
	end;

	/*************************************************************************/
	--Start for: Read ONE baseline by ObjectId
	procedure read_baseline(p_id in nvarchar2)
	as
		v_payload xmltype;
		v_study_element_id_list nvarchar2(999):='''nnuull''';
		v_msgid nvarchar2(100);
		v_where nvarchar2(99):='baseline_pkg.read_baseline';
		v_log_txt nvarchar2(111):='Baseline get request sent, ObjectId: '||p_id||' Message ID: ';
		v_subject nvarchar2(99):='baseline:'||p_id;
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
	begin
		log_pkg.steps(null,v_step_start,v_steps_result);

		--validate if Baseline is NULL. we update/insert only once. Baseline is not being changed at P6
		for bb in (select id from timeline_baseline where id=p_id and details is null)
		loop
			for rr in (select value from configuration where code in ('FPFV','LPLV','CSRAPP','PRCOMPL','CDBLOCK'))
			loop
				v_study_element_id_list:=v_study_element_id_list||','''||rr.value||'''';
			end loop;

			v_payload := xmltype('<read xmlns="http://xmlns.bayer.com/ipms/soa">'||
							'<baseline xmlns="http://xmlns.bayer.com/ipms" id="'||p_id||'" >'||
								--'<studyElementIdList>''3200'',''3700'',''4650'',''3604'',''4000''</studyElementIdList>'||
								'<studyElementIdList>'||v_study_element_id_list||'</studyElementIdList>'||
							'</baseline>'||
						  '</read>');

			v_msgid := message_pkg.send(v_subject, v_payload, get_text('begin baseline_pkg.read_baseline_finish(''%1'',:1); end;',varchar2_table_typ(p_id)));
		exit;--just in case
		end loop;

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, v_log_txt||v_msgid, v_steps_result);

	exception when others then
		log_pkg.catch(v_where, v_log_txt||v_msgid,v_steps_result);
		raise;
	end;

	/*************************************************************************/
	--Finish for: Read ONE baseline by ObjectId
	procedure read_baseline_finish(p_id in nvarchar2, p_payload in xmltype)
	as
		v_payload xmltype;
		v_id nvarchar2(30);
		v_where nvarchar2(99):='baseline_pkg.read_baseline_finish';
		v_log_txt nvarchar2(111):='p_id='||p_id;

		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
	begin
		--validate response
		if message_pkg.is_complete(p_payload)=0 then
			return;
		end if;
		log_pkg.steps(null,v_step_start,v_steps_result);

		if p_payload is not null then
			select xt.id, xt.details into v_id, v_payload
			from	xmltable(
						xmlnamespaces(default 'http://xmlns.bayer.com/ipms'),
						'//baselines/baseline' passing p_payload
						columns
							details xmltype path '.',
							id path '/baseline/@id'
							) xt;

			update timeline_baseline
			set details=v_payload, update_date=sysdate
			where id=v_id
			and id=p_id 
			and details is null
			;
		end if;

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, v_log_txt, v_steps_result);

	exception when others then
		log_pkg.catch(v_where, v_log_txt,v_steps_result);
		raise;
	end;

	/*************************************************************************/
	procedure read_baselines_finish(p_id in nvarchar2, p_payload in xmltype)
	as
		v_payload xmltype;
		v_rowcount number:=0;
		----
		v_where nvarchar2(222):='baseline_pkg.read_baselines_finish';
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
		v_log_txt nvarchar2(222);
		----
	begin
		log_pkg.steps(null,v_step_start,v_steps_result);--null=BEGIN
		--check if it is update based on ReadTimeline or based on DeleteBaselines
		--If ReadTimeline then only p_id is provided
		if p_payload is not null then
			v_payload:=p_payload;
		else
			select details into v_payload from timeline where id=p_id;
		end if;

		/* validate response */
		if message_pkg.is_complete(v_payload)=0 then
			return;
		end if;

		delete from timeline_baseline
		where timeline_id = p_id
		and id not in (
							select
								xt.id
							from
							xmltable(
							xmlnamespaces(default 'http://xmlns.bayer.com/ipms'),
								'//baselines/baseline' passing v_payload
							columns
								id nvarchar2(20) path '/baseline/@id'
							) xt );

		v_rowcount := v_rowcount + sql%rowcount;

		merge into timeline_baseline dest
		using (
			select
				id,
				--max(decode (seq, 1, timeline_id)) timeline_id,
				max(decode (seq, 1, baseline_type_id)) baseline_type_id,
				max(decode (seq, 1, create_date_p6)) create_date_p6,
				max(decode (seq, 1, description)) description,
				max(decode (seq, 1, ltci_id)) ltci_id,
				max(decode (seq, 1, ltc_process_id)) ltc_process_id,
				sum(decode (seq, 1, srccnt, dstcnt)) iud
			from (
				select
					id,
					--timeline_id,
					baseline_type_id,
					create_date_p6,
					description,
					ltci_id,
					ltc_process_id,
					srccnt,
					dstcnt,
					row_number() over (partition by id order by dstcnt nulls last) seq
				from (
					select
						id,
						--timeline_id,
						baseline_type_id,
						create_date_p6,
						description,
						ltci_id,
						ltc_process_id,
						count(src) srccnt,
						count(dst) dstcnt
					from (
							select
								xt.id,
								--p_id as timeline_id,
								xt.baseline_type_id,
								get_date(xt.create_date_p6) as create_date_p6,
								xt.description,
								--xt.ltci_id,
								to_number(decode(instr(xt.ltci_id,'.',1),0,xt.ltci_id,substr(xt.ltci_id,1,instr(xt.ltci_id,'.',1)-1))) as ltci_id, 
								to_number(decode(instr(xt.ltci_id,'.',1),0,null,substr(xt.ltci_id,instr(xt.ltci_id,'.',1)+1))) as ltc_process_id,
								1 src,
								to_number(null) dst
							from
								xmltable(
									xmlnamespaces(default 'http://xmlns.bayer.com/ipms'),
									'//baselines/baseline' passing v_payload
									columns
										id nvarchar2(20) path '/baseline/@id',
										baseline_type_id nvarchar2(20) path '/baseline/baselineTypeObjectId',
										create_date_p6 path '/baseline/createDate',
										description nvarchar2(500) path '/baseline/description',
										ltci_id path '/baseline/ltcId'
								) xt
					union all
							select
								id,
								--timeline_id,
								baseline_type_id,
								create_date_p6,
								description,
								ltci_id,
								ltc_process_id,
								to_number(null) src,
								2 dst
							from timeline_baseline
							where timeline_id = p_id
							)
					group by
						id,
						--timeline_id,
						baseline_type_id,
						create_date_p6,
						description,
						ltci_id,
						ltc_process_id
					having count (src) <> count (dst)
				)
			)
			group by id
		) diff
		on (dest.id = diff.id)
		when matched
		then
			 update set
				  dest.baseline_type_id = diff.baseline_type_id
				 ,dest.create_date_p6 = diff.create_date_p6
				 ,dest.description = diff.description
				 ,dest.ltci_id = diff.ltci_id
				 ,dest.ltc_process_id = diff.ltc_process_id
				 ,update_date=sysdate
			 --delete where (diff.iud = 0) --Delete goes sooner
		when not matched
		then
			 insert (
					id,
					timeline_id,
					baseline_type_id,
					create_date_p6,
					description,
					ltci_id,
					ltc_process_id,
					create_date
					)
			 values (
					diff.id,
					p_id,
					diff.baseline_type_id,
					diff.create_date_p6,
					diff.description,
					diff.ltci_id,
					diff.ltc_process_id,
					sysdate
					);

		v_rowcount := v_rowcount + sql%rowcount;

		/* stop sync */
		update timeline set is_syncing=0 where id=p_id and is_syncing<>0;

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, 'timeline_id='||p_id||';rowcount='||v_rowcount||';'||v_log_txt, v_steps_result);

	exception when others then
		log_pkg.catch(v_where,'timeline_id='||p_id||';rowcount='||v_rowcount||';'||v_log_txt,v_steps_result);
		raise;
	end;

end;
/