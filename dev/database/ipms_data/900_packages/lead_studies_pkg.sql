create or replace package lead_studies_pkg as

	/**
	 * Initiates receive from P6 of current lead studies and their mapping with development milestones
	 * Requires lead study mapping instance to be created
	 * Throws no_data_found exception if requirements unmatched.
	 * Asynchronous.
	 */
	procedure receive(p_lsi_id in lead_study_instance.id%type);


	/**
	 * Process lead study data received from P6. Fills up relevant tables
	 * Callback.
	 */
	procedure receive_finish(p_lsi_id in lead_study_instance.id%type,p_payload in xmltype);
	
	/**
	 * Initiates send to P6 of current lead studies and their mapping with development milestones
	 * Requires lead study mapping instance to be created
	 * Throws no_data_found exception if requirements unmatched.
	 * Asynchronous.
	 */
	procedure send(p_lsi_id in lead_study_instance.id%type);


	/**
	 * Process response from P6 after data has beed sent. Fills up relevant tables
	 * Callback.
	 */
	procedure send_finish(p_lsi_id in lead_study_instance.id%type,p_payload in xmltype);

end;
/

create or replace package body lead_studies_pkg as

	/*************************************************************************/
	procedure receive(p_lsi_id in lead_study_instance.id%type) as
		v_ls_instance lead_study_instance%rowtype;
		v_payload xmltype;
		v_msgid nvarchar2(100);
		v_where nvarchar2(99):='lead_studies_pkg.receive';
		v_log_txt nvarchar2(111):='Receive lead study mapping from P6';
		v_subject nvarchar2(99):='receive_lead_study_mapping';
		v_dev_mlstn_code_list nvarchar2(1000);
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;

		cursor c_dev_mlstn is
			select listagg(''''||code||'''',',') within group (order by code)
			from milestone 
			where type_code='DEV' 
			and is_active=1 
			and is_lead_study_relevant=1;

	begin
		log_pkg.steps(null,v_step_start,v_steps_result);--null=BEGIN

		notice_pkg.information('MaintainLeadStudies:'||p_lsi_id, '[Lead study mapping '||p_lsi_id||'] started.');
	
		select * into v_ls_instance from lead_study_instance where id=p_lsi_id;
	
		open c_dev_mlstn;
		fetch c_dev_mlstn into v_dev_mlstn_code_list;
		close c_dev_mlstn;
	
		v_payload := xmltype('<read '||message_pkg.xmlns_ipms_soa||'><leadStudies projectId="'||v_ls_instance.project_id||'" '||message_pkg.xmlns_ipms||'><devMilestones><codeList>'||v_dev_mlstn_code_list||'</codeList></devMilestones></leadStudies></read>');
		v_msgid := message_pkg.send(v_subject||':'||v_ls_instance.project_id, v_payload, get_text('begin lead_studies_pkg.receive_finish(''%1'',:1); end;',varchar2_table_typ(p_lsi_id)));

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, v_log_txt||';lsi_id='||p_lsi_id, v_steps_result);

	exception when others then
		notice_pkg.catch(v_where, v_log_txt||';lsi_id='||p_lsi_id);
		raise;
	end;


	/*************************************************************************/
	procedure receive_finish(p_lsi_id in lead_study_instance.id%type,p_payload in xmltype) as
		v_ls_instance lead_study_instance%rowtype;
		--v_payload xmltype;
		--v_msgid nvarchar2(100);
		v_where nvarchar2(99):='lead_studies_pkg.receive_finish';
		v_log_txt nvarchar2(111):='Receive lead study mapping from P6';
		--v_subject nvarchar2(99):='receive_lead_study_mapping';
		--v_guid sys_guid_transaction.guid%type;
		--testxml xmltype;
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
	begin
		/* validate response */
		if message_pkg.is_complete(p_payload)=0 then
			return;
		end if;
		log_pkg.steps(null,v_step_start,v_steps_result);

		select * into v_ls_instance from lead_study_instance where id=p_lsi_id;
	
		-- After successfull receive remove previous instance
		delete from lead_study_instance where project_id=v_ls_instance.project_id and id !=v_ls_instance.id;
	
		--Save payload
		update lead_study_instance set details=extract(p_payload,'//complete',message_pkg.xmlns_ipms_soa) where id=p_lsi_id;
	
		-- Fill study lookup
		insert into lead_studies(lsi_id,wbs_id,name,is_lead)
		select
			p_lsi_id,wbs_id,nvl2(phaseName,phaseName||': '||name, name),decode(is_lead,'true',1,0)
		from
		xmltable(
			xmlnamespaces(default 'http://xmlns.bayer.com/ipms'),
			'//leadStudies/studies/study' passing p_payload
			columns
				wbs_id path '/study/@wbsId',
				is_lead path '/study/@isLead',
				name path '/study/name',
				phaseName path '/study/phaseName'
		) xt;
	
		-- Add DRV milestone ids to lead studies lookup
		merge into lead_studies ls
		using(
		select lsi_id, wbs_id , "3200_ACTIVITY_ID" as fpfv_activity_id, "3500_ACTIVITY_ID" as lpfv_activity_id, "3700_ACTIVITY_ID"  as lplv_activity_id , "3604_ACTIVITY_ID" as pc_activity_id, "3200_ACTIVITY_TYPE" as fpfv_activity_type, "3500_ACTIVITY_TYPE" as lpfv_activity_type, "3700_ACTIVITY_TYPE" as lplv_activity_type, "3604_ACTIVITY_TYPE" as pc_activity_type
from (
  select
    p_lsi_id lsi_id,wbs_id,study_element_id,activity_id,type
  from
    xmltable(
    xmlnamespaces(default 'http://xmlns.bayer.com/ipms'),
    '//drvMilestones/drvMilestone' passing p_payload
    columns
        wbs_id path '/drvMilestone/@wbsId',
    study_element_id path '/drvMilestone/@studyElementId',
    activity_id path '/drvMilestone/@activityId',
    type path '/drvMilestone/@type'
    ) xt
)
  pivot(
    max (activity_id) as activity_id,
    max (type) as activity_type
    for study_element_id in (3200,3500,3700,3604)
  )
		)drvm on (ls.lsi_id=p_lsi_id and drvm.wbs_id=ls.wbs_id)
		when matched then update
			set ls.fpfv_activity_id=drvm.fpfv_activity_id,
				ls.lplv_activity_id=drvm.lplv_activity_id,
				ls.lpfv_activity_id=drvm.lpfv_activity_id,
        ls.pc_activity_id=drvm.pc_activity_id,
				ls.fpfv_activity_type=drvm.fpfv_activity_type,
				ls.lplv_activity_type=drvm.lplv_activity_type,
				ls.lpfv_activity_type=drvm.lpfv_activity_type,
        ls.pc_activity_type=drvm.pc_activity_type;
	
		-- Fill DEV milestones
		insert into lead_study_map(lsi_id,dev_mlstn_code,dev_mlstn_activity_id,dev_mlstn_type)
		select
			p_lsi_id,code,activity_id,type
		from
		xmltable(
			xmlnamespaces(default 'http://xmlns.bayer.com/ipms'),
			'//devMilestones/devMilestone' passing p_payload
			columns
				activity_id path '/devMilestone/@activityId',
				type path '/devMilestone/@type',
				code path '/devMilestone/name'
				
		) xt;
	
		--Fill current relationships
		merge into lead_study_map lsm
		using(
		select
			dev_activity_id,max(ls.wbs_id) wbs_id, count(ls.wbs_id) cnt
		from
		xmltable(
			xmlnamespaces(default 'http://xmlns.bayer.com/ipms'),
			'//relationships/relationship' passing p_payload
			columns
				dev_activity_id path '/relationship/@devActivityId',
				drv_activity_id path '/relationship/@drvActivityId'
			) xt
		join lead_studies ls on ls.lsi_id=p_lsi_id and ls.is_lead=1 and (xt.drv_activity_id=ls.fpfv_activity_id or  xt.drv_activity_id=ls.lplv_activity_id or xt.drv_activity_id=ls.lpfv_activity_id or xt.drv_activity_id=ls.pc_activity_id)
		group by dev_activity_id
			) src on (lsm.lsi_id=p_lsi_id and src.dev_activity_id=lsm.dev_mlstn_activity_id)
		when matched then
			update set lsm.curr_study_wbs_id=decode(src.cnt,1,src.wbs_id,null),
							lsm.error_code=decode(src.cnt,1,null,'errorRelUK');
	
	
		update lead_study_instance set status_code='READY' where id=p_lsi_id;

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, v_log_txt||';lsi_id='||p_lsi_id, v_steps_result);

	exception when others then
		notice_pkg.catch(v_where, v_log_txt||';lsi_id='||p_lsi_id);
	end;

	/*************************************************************************/
	procedure send(p_lsi_id in lead_study_instance.id%type) as
		v_ls_instance lead_study_instance%rowtype;
		v_payload xmltype;
		v_msgid nvarchar2(100);
		v_where nvarchar2(99):='lead_studies_pkg.send';
		v_log_txt nvarchar2(111):='Send lead study mapping to P6';
		v_subject nvarchar2(99):='send_lead_study_mapping';
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
	begin
		log_pkg.steps(null,v_step_start,v_steps_result);
	
		notice_pkg.information('MaintainLeadStudies:'||p_lsi_id, '[Lead study send '||p_lsi_id||'] started.');
	
		select * into v_ls_instance from lead_study_instance where id=p_lsi_id;
	
		v_payload := xmltype('<update '||message_pkg.xmlns_ipms_soa||'><leadStudies projectId="'||v_ls_instance.project_id||'" '||message_pkg.xmlns_ipms||'/></update>');
	
		--Fill studies to be updated
		begin
		select appendchildxml(v_payload, '//leadStudies',studies, message_pkg.xmlns_ipms)
			into v_payload
		from ( select xmlelement("studies",
											XMLAttributes(message_pkg.nsuri_ipms as "xmlns"),
											xmlagg( XMLElement("study",
																		XMLAttributes(message_pkg.nsuri_ipms as "xmlns",
																							chng.wbs_id as "wbsId",
																							decode(max(chng.is_lead),0,'false','true')  AS "isLead"
																						)
																	)
	
									)) as studies
					from (
							select distinct nvl(lsm.new_study_wbs_id,lsm.curr_study_wbs_id) wbs_id,1 is_lead
							from lead_study_map lsm
							where lsm.lsi_id=p_lsi_id and nvl(lsm.new_study_wbs_id,lsm.curr_study_wbs_id) is not null
									and nvl(lsm.new_study_wbs_id,lsm.curr_study_wbs_id) not in (select ls.wbs_id from lead_studies ls where ls.lsi_id=p_lsi_id and is_lead=1)
	
							union all
	
							select ls.wbs_id,0
							from lead_studies ls
							where ls.lsi_id=p_lsi_id and ls.is_lead=1
									and ls.wbs_id not in (select nvl(lsm.new_study_wbs_id,lsm.curr_study_wbs_id) from lead_study_map lsm where lsm.lsi_id=p_lsi_id and nvl(lsm.new_study_wbs_id,lsm.curr_study_wbs_id) is not null)
	
							) chng
					group by chng.wbs_id
				) where existsnode(studies,'/studies/study',message_pkg.xmlns_ipms) =1;
		exception
			when no_data_found then null;
		end;
	
		--Fill relationships to be created
		begin
		select appendchildxml(v_payload, '//leadStudies',relationships, message_pkg.xmlns_ipms)
			into v_payload
		from (
		 select xmlelement("relationships",
											XMLAttributes(message_pkg.nsuri_ipms as "xmlns"),
											xmlagg( XMLElement("relationship",
																		XMLAttributes(message_pkg.nsuri_ipms as "xmlns",
																							rel.dev_mlstn_activity_id as "devActivityId",
																							rel.drv_mlstn_activity_id  AS "drvActivityId",
																							case when rel.dev_mlstn_type = 'Start Milestone' and rel.drv_mlstn_type = 'Start Milestone' then 'Start to Start' 
																									when rel.dev_mlstn_type = 'Finish Milestone' and rel.drv_mlstn_type = 'Start Milestone' then 'Start to Finish'	
																									when rel.dev_mlstn_type = 'Start Milestone' and rel.drv_mlstn_type = 'Finish Milestone' then 'Finish to Start'	
																									when rel.dev_mlstn_type = 'Finish Milestone' and rel.drv_mlstn_type = 'Finish Milestone' then 'Finish to Finish' end	as "type"
																						)
																	)
	
									)) as relationships
									from(
									
									select lsm.dev_mlstn_activity_id, lsm.dev_mlstn_type, rel2.drv_mlstn_activity_id, decode(lsc.drv_mlstn_code,3200,ls.fpfv_activity_type,3500,ls.lpfv_activity_type,3604,ls.pc_activity_type,ls.lplv_activity_type) drv_mlstn_type from (
										select lsm.dev_mlstn_activity_id, decode(lsc.drv_mlstn_code,3200,ls.fpfv_activity_id,3500,ls.lpfv_activity_id,3604,ls.pc_activity_id,ls.lplv_activity_id) drv_mlstn_activity_id
										from lead_study_map lsm
										join lead_studies ls on ls.lsi_id=p_lsi_id and ls.wbs_id=lsm.new_study_wbs_id
										join lead_study_config lsc on lsc.dev_mlstn_code=lsm.dev_mlstn_code
										where lsm.lsi_id=p_lsi_id
										minus
										select to_nchar(dev_activity_id),to_nchar(drv_activity_id)
										from
										xmltable(
													xmlnamespaces(default 'http://xmlns.bayer.com/ipms'),'//relationships/relationship' passing v_ls_instance.details columns
														dev_activity_id path '/relationship/@devActivityId',
														drv_activity_id path '/relationship/@drvActivityId'
													) xt
										) rel2
										join lead_study_map lsm on lsm.dev_mlstn_activity_id=rel2.dev_mlstn_activity_id
										join lead_studies ls on ls.lsi_id=p_lsi_id and ls.wbs_id=lsm.new_study_wbs_id
										join lead_study_config lsc on lsc.dev_mlstn_code=lsm.dev_mlstn_code
										)rel
										
										
		) where existsnode(relationships,'/relationships/relationship',message_pkg.xmlns_ipms) =1;
		exception
			when no_data_found then null;
		end;
	
		v_msgid := message_pkg.send(v_subject||':'||v_ls_instance.project_id, v_payload, get_text('begin lead_studies_pkg.send_finish(''%1'',:1); end;',varchar2_table_typ(p_lsi_id)));
	
		--Assuming all relationships created successfully. This is needed in case of no changes in P6 required to be done. For those objects which need changes statuses will be updated accordingly.
		update lead_study_map set status_code='DONE' where lsi_id=p_lsi_id and new_study_wbs_id is not null;
	
		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, v_log_txt||';lsi_id='||p_lsi_id, v_steps_result);

	exception when others then
		notice_pkg.catch(v_where, v_log_txt||';lsi_id='||p_lsi_id);
		raise;
	end;

	/*************************************************************************/
	procedure send_finish(p_lsi_id in lead_study_instance.id%type,p_payload in xmltype) as
		v_ls_instance lead_study_instance%rowtype;
		--v_payload xmltype;
		--v_msgid nvarchar2(100);
		v_where nvarchar2(99):='lead_studies_pkg.send_finish';
		v_log_txt nvarchar2(111):='Send (finish) lead study mapping to P6';
		--v_subject nvarchar2(99):='send_lead_study_mapping';
		--v_guid sys_guid_transaction.guid%type;
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
	begin
		/* validate response */
		if message_pkg.is_complete(p_payload)=0 then
			return;
		end if;
		log_pkg.steps(null,v_step_start,v_steps_result);
		
		select * into v_ls_instance from lead_study_instance where id=p_lsi_id;
	
		-- Update is_lead flag among studies available in DB
			merge into study std
			using(
				select
					tm.study_id,decode(is_lead,'true',1,0) is_lead
				from
					xmltable(
							xmlnamespaces(default 'http://xmlns.bayer.com/ipms'), '//studies/study' passing p_payload
				columns
					wbs_id path '/study/@wbsId',
					status path '/study/@status',
					is_lead path '/study/@isLead'
							) xt
					join timeline_wbs tm on tm.project_id=v_ls_instance.project_id and tm.timeline_type_code='RAW' and tm.wbs_id=xt.wbs_id
					where status='DONE'
					) src on (std.id=src.study_id)
		when matched then
			update set std.is_lead=src.is_lead;
	
	
		--Update create relationship statuses
		merge into lead_study_map lsm
		using(
		select
			dev_activity_id,status
		from
		xmltable(
			xmlnamespaces(default 'http://xmlns.bayer.com/ipms'),
			'//relationships/relationship' passing p_payload
			columns
				dev_activity_id path '/relationship/@devActivityId',
				status path '/relationship/@status'
			) xt
			) src on (lsm.lsi_id=p_lsi_id and src.dev_activity_id=lsm.dev_mlstn_activity_id)
		when matched then
			update set lsm.status_code=src.status;
	
		--Update lead study statuses
			merge into lead_study_map lsm
		using(
		select
			wbs_id,status
		from
		xmltable(
			xmlnamespaces(default 'http://xmlns.bayer.com/ipms'),
			'//studies/study' passing p_payload
			columns
				wbs_id path '/study/@wbsId',
				status path '/study/@status'
			) xt
			) src on (lsm.lsi_id=p_lsi_id and (src.wbs_id=lsm.new_study_wbs_id or src.wbs_id=lsm.curr_study_wbs_id))
		when matched then
			update set lsm.status_code=src.status where lsm.status_code!='FAIL';
	
		notice_pkg.information('MaintainLeadStudies','MaintainLeadStudies: send finish done');
	
		update lead_study_instance set status_code='DONE' where id=p_lsi_id;

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, v_log_txt||';lsi_id='||p_lsi_id, v_steps_result);

	exception when others then
		notice_pkg.catch(v_where, v_log_txt||';lsi_id='||p_lsi_id);
	end;

	/*************************************************************************/
end;
/
