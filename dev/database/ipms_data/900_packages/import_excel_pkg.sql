create or replace package import_excel_pkg as

	procedure d2_projects;
	procedure typify;
	procedure ipowner;
	procedure costs_fps_import(p_file_name nvarchar2);

end;
/
create or replace package body import_excel_pkg as

	/*************************************************************************/
	procedure d2_projects
	as
		v_program_id nvarchar2(20); --D2 reserved program id
		--v_project_id nvarchar2(20);
		v_status nvarchar2(4000);
		v_state_code nvarchar2(20);
		v_SUBSTANCE_TYPE_CODE nvarchar2(20);
		v_phase_code nvarchar2(20);
		--v_ipowner_code nvarchar2(20);
		v_ta_code nvarchar2(20);
		v_area_code nvarchar2(20):='D2-PRJ';
		o_prj project%rowtype;
		v_category_code nvarchar2(20);
		v_source_code nvarchar2(20);
		v_termination_date date;
		v_termination_code nvarchar2(20);
		v_xml xmltype;
		v_timeline_id nvarchar2(88);
		v_stop_error nvarchar2(4000);
		v_action nvarchar2(99);
		v_date_now nvarchar2(99):=to_char(sysdate,'yyyy-mm-dd')||'T08:00:00';
		v_date_send nvarchar2(99);
		v_mustbedeleted nvarchar2(99);
		v_count number;
	begin

		select id into v_program_id
		from program
		where code='RESERVED-PT-D2-PRJ';

--,utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(column3))) name --TESTING
	 --Project ID
	 --Project-ID (Planned)	
	 --Project Name	
	 --Project Area	
	 --Status	
	 --LC Type	
	 --DS Type	
	 --Phase	
	 --D2 Compound	
	 --Priority	
	 --IP Owner	
	 --Project Source	
	 --Lead Project	
	 --Therapeutic Area (CODE)	Collaboration	Collaboration Partner	D1 Actual	D2 Actual	CSM Actual	eD3 Actual	D3ctual	Termination Date	Termination Reason	Spalte1	Spalte2
	 
    for rr in (
					select
							column1 code --project_id
							,column2 planning_code
							,column3 name
							--,'D2-PRJ' area_code --D2-Project --Project Area
							,column5 state_name --Status --:=--Terminated --Completed
							,column6 category_name --LC Type --:=--new indication --new molecule
							--,'LO' category_code --always: "Lead Optimisation"
							,column7 substance_type_name --DS Type --chem--biol
							,column8 phase_name --Phase --Lead Optimization
							,column9 D2_Compound --D2 Compound
							,'n.a.' priority_code
							--,column11 ipowner_name --always null
							,decode(column12,'lic in/aquired','lic in/acquired', column12) source_name --Project Source --source_code --self-originated --lic in/aquired
							,decode(column13,'yes',1,0) is_lead ----Lead Project
							--,decode(column14,'RAI','R&I','CMR','CRM',column14) ta_code --Therapeutic Area (CODE)
							,decode(column14,
								'CAR','CRM',
								'CMR','CMR',
								'HEM','Hem',
								'ONC','Onc',
								'OPH','Oph',
								'RAI','CME',
								'WHC','WHC',
								column14) ta_code --Therapeutic Area (CODE)							
							--,column15 --just a flag
							,decode(column16,null,0,1) is_collaboration
							,column16 details_partner
							,column22 termination_date
							,column23 termination_reason
							,column17 d1_actual
							,column18 d2_actual
							,column19 csm_actual
							,column20 ed3_actual
							,column21 d3ctual
							--inActive must be
               from import_excel
               where file_name='D2' 
					--and column1='442000'
					--and column1='188101'
					--and ref_id is null
					--and status like '%ORA-%'
					order by 1
					)
    loop
		v_status:= null;
		v_stop_error:=null;
		v_action:=null;
		--1 Project ID	= code
		--Project-ID (Planned)	= planning_code
		--Project Name	= name
		--Project Area	= area_code
		--5 Status	= state_code - select * from project_state
		--LC Type	- category_code - project_category
		--DS Type	- SUBSTANCE_TYPE_CODE - SUBSTANCE_TYPE
		--Phase	- PHASE_CODE - PHASE
		--Priority	- priority_code - PRIORITY
		--10 IP Owner	- ipowner_code - ipowner
		--Project Source	- source_code - PROJECT_SOURCE
		--Lead Project	- Y=1
		--Therapeutic Area (CODE) - TA_CODE - THERAPEUTIC_AREA

		-------------------------
		--validate
		begin
			select prj.*
			into o_prj 
			from project prj
			where prj.code=rr.code
			and nvl(prj.area_code,v_area_code)<>'D1';
			
			v_status:=v_status||'Project already exists!v_area_code='||nvl(o_prj.area_code,'UNT');

		exception when no_data_found then
			o_prj.id :=null;
		end;--continue checking for changes that could be logged in import table
			
		if rr.state_name is not null then
			begin
				select code into v_state_code from project_state where upper(name)=upper(rr.state_name);
				if o_prj.id is not null then
					if nvl(v_state_code,'#') <> nvl(o_prj.state_code,v_state_code) then
						v_status:=v_status||';project_state is DIFF.new<>old:'||v_state_code||'<>'||o_prj.state_code;
					end if;
				end if;
			exception when others then
				v_state_code:=null;
				v_stop_error:=v_stop_error||';Project project_state rr.state_name='||rr.state_name||';error='||sqlerrm;
			end;
		end if;

		if rr.category_name is not null then
			begin
				select code into v_category_code from project_category where upper(name)=upper(rr.category_name);
				if o_prj.id is not null then
					if nvl(v_category_code,'#') <> nvl(o_prj.category_code,v_category_code) then
						v_status:=v_status||';category_code is DIFF.new<>old:'||v_category_code||'<>'||o_prj.category_code;
					end if;
				end if;
			exception when others then
				v_category_code:=null;
				v_stop_error:=v_stop_error||';Project category_code rr.category_name='||rr.category_name||';error='||sqlerrm;
			end;
		end if;

		if rr.substance_type_name is not null then
			begin
				select code into v_substance_type_code from substance_type where upper(name)=upper(rr.substance_type_name);
				if o_prj.id is not null then
					if nvl(v_substance_type_code,'#') <> nvl(o_prj.substance_type_code,v_substance_type_code) then
						v_status:=v_status||';SUBSTANCE_TYPE is DIFF.new<>old:'||v_substance_type_code||'<>'||o_prj.substance_type_code;
					end if;
				end if;				
			exception when others then
				v_substance_type_code:=null;
				v_stop_error:=v_stop_error||';Project SUBSTANCE_TYPE rr.substance_type_name='||rr.substance_type_name||';error='||sqlerrm;
			end;
		end if;

		if rr.phase_name is not null then
			begin
				select code into v_phase_code from phase where upper(name)=upper(rr.phase_name);
				if o_prj.id is not null then
					if nvl(v_phase_code,'#') <> nvl(o_prj.phase_code,v_phase_code) then
						v_status:=v_status||';phase_code is DIFF.new<>old:'||v_phase_code||'<>'||o_prj.phase_code;
					end if;
				end if;	
			exception when others then
				v_phase_code:=null;
				v_status:=v_status||';Project PHASE rr.phase_name='||rr.phase_name||';error='||sqlerrm;
			end;
		end if;

		if rr.d2_compound is not null then
			if o_prj.id is not null then
				if nvl(rr.d2_compound,'#') <> nvl(o_prj.d2_compound,rr.d2_compound) then
					v_status:=v_status||';D2_Compound is DIFF.new<>old:'||rr.D2_Compound||'<>'||o_prj.D2_Compound;
				end if;
			end if;
		end if;

			--begin
				--select code into v_ipowner_code from ipowner where upper(name)=upper(rr.ipowner_name);
			--	null;
			--exception when others then
				--v_ipowner_code:=null;
			--	v_status:=v_status||';Project ipowner error='||sqlerrm;
			--end;

		if rr.source_name is not null then
			begin
				select code into v_source_code from PROJECT_SOURCE where upper(name)=upper(rr.source_name);
				if o_prj.id is not null then
					if nvl(v_source_code,'#') <> nvl(o_prj.source_code,v_source_code) then
						v_status:=v_status||';source_code is DIFF.new<>old:'||v_source_code||'<>'||o_prj.source_code;
					end if;
				end if;	
			exception when others then
				v_source_code:=null;
				v_stop_error:=v_stop_error||';Project source_code rr.source_name='||rr.source_name||';error='||sqlerrm;
			end;
		end if;

		if rr.ta_code is not null then
			if o_prj.id is not null then
				if nvl(rr.is_lead,9) <> nvl(o_prj.is_lead,rr.is_lead) then
					v_status:=v_status||';is_lead is DIFF.new<>old:'||rr.is_lead||'<>'||o_prj.is_lead;
				end if;
			end if;
		end if;

		if rr.ta_code is not null then
			begin
				begin
					select code into v_ta_code from therapeutic_area where (code)=(rr.ta_code) and is_active=1;
				exception when no_data_found then
					select code into v_ta_code from therapeutic_area where (code)=(rr.ta_code);
				end;
				if o_prj.id is not null then
					if nvl(v_ta_code,'#') <> nvl(o_prj.ta_code,v_ta_code) then
						v_status:=v_status||';ta_code is DIFF.new<>old:'||v_ta_code||'<>'||o_prj.ta_code;
					end if;
				end if;	
			exception when others then
				v_ta_code:=null;
				v_stop_error:=v_stop_error||';THERAPEUTIC_AREA---TA_CODE='||rr.TA_CODE||';error='||sqlerrm;
			end;
		end if;

		if rr.details_partner is not null then
			if o_prj.id is not null then
				if nvl(rr.details_partner,'#') <> nvl(o_prj.details_partner,rr.details_partner) then
					v_status:=v_status||';details_partner is DIFF.new<>old:'||rr.details_partner||'<>'||o_prj.details_partner;
				end if;
			end if;
		end if;

		if rr.termination_date is not null then --check if date is fine
			begin
				v_termination_date := to_date(rr.termination_date,'mm/dd/yyyy');
			exception when others then
				v_termination_date := null;
				v_stop_error:=v_stop_error||';details_partner is DIFF.new<>old:'||rr.details_partner||'<>'||o_prj.details_partner;
			end;
		end if;

		if v_termination_date is not null then
			if o_prj.id is not null then
				if nvl(v_termination_date,sysdate+111) <> nvl(o_prj.termination_date,v_termination_date) then
					v_status:=v_status||';termination_date is DIFF.new<>old:'||v_termination_date||'<>'||o_prj.termination_date;
				end if;
			end if;
		end if;

		if rr.termination_reason is not null then
			begin
				select code into v_termination_code from termination_reasons4prjarea_vw 
				where replace(replace(upper(reason||reasonsubcatname),' '),'-')=replace(replace(upper(rr.termination_reason),' '),'-')
				and area_code=v_area_code;
				if o_prj.id is not null then
					if nvl(v_termination_code,'#') <> nvl(o_prj.termination_code,v_termination_code) then
						v_status:=v_status||';termination_code is DIFF.new<>old:'||v_termination_code||'<>'||o_prj.termination_code;
					end if;
				end if;	
			exception when others then
				v_termination_code:=null;
				v_stop_error:=v_stop_error||';Project termination_code rr.termination_reason='||rr.termination_reason||';error='||sqlerrm;
			end;
		end if;

		if rr.name is not null then
			if o_prj.id is not null then
				if replace(upper(nvl(rr.name,'#')),' ') <> replace(upper(nvl(o_prj.name,rr.name)),' ') then
					v_status:=v_status||';Project Name is DIFF.new<>old:'||rr.name||'<>'||o_prj.name;
				end if;
			end if;
		end if;
		
		
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
if nvl(o_prj.area_code,v_area_code)=v_area_code then --continue
	if o_prj.id is null and v_status||v_stop_error is null then
		v_action:='INSERT';
		v_status:=v_action||'.OK.';
	elsif o_prj.id is null and v_status is not null and v_stop_error is null then
		v_action:='INSERT';
		v_status:=v_action||'.with.WARNINGS.'||v_status;
	elsif o_prj.id is null and v_stop_error is not null then
		v_action:='SKIP';
		v_status:=v_action||'.INSERT.'||v_stop_error||v_status;
	elsif o_prj.id is not null and v_status||v_stop_error is null then
		v_action:='UPDATE';
		v_status:=v_action||'.OK.';
	elsif o_prj.id is not null and v_status is not null and v_stop_error is null then
		v_action:='UPDATE';
		v_status:=v_action||'.with.WARNINGS.'||v_status;
	elsif o_prj.id is not null and v_stop_error is not null then
		v_action:='SKIP';
		v_status:=v_action||'.UPATE.'||v_stop_error||v_status;
	else
		v_action:='ELSE';
		v_status:=v_action||'.'||v_stop_error||v_status;	
	end if;
else
	v_action:='STOP';	
	v_status:=v_action||'.area_code.error!'||v_status;
end if;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

		if v_action ='INSERT' then
			--INSERT
			begin
/*--TODO
				insert into project (
											program_id
											,code
											,planning_code
											,name
											,area_code
											,state_code
											,category_code
											,SUBSTANCE_TYPE_CODE
											,PHASE_CODE
											,D2_Compound
											,priority_code
											--,ipowner_code
											,source_code
											,is_lead
											,ta_code
											,is_collaboration
											,details_partner
											,termination_date
											,termination_code
											,is_active
											)
								values(
											v_program_id
											,rr.code
											,rr.planning_code
											,rr.name
											,v_area_code
											,v_state_code
											,v_category_code
											,v_SUBSTANCE_TYPE_CODE
											,v_PHASE_CODE
											,rr.D2_Compound
											,rr.priority_code
											--,v_ipowner_code
											,v_source_code
											,rr.is_lead
											,v_ta_code
											,rr.is_collaboration
											,rr.details_partner
											,v_termination_date
											,v_termination_code
											,0 --D2 always Active/InActive
										)
								returning id into o_prj.id;
*/--TODO
				COMMIT;

				----------------
				-- SOA-P6
				dbms_lock.sleep(3);
				project_pkg.send( o_prj.id, null);
				dbms_lock.sleep(10);
			exception when others then
				v_status:=v_status||';INSERT error='||sqlerrm;
			end;
			
		elsif v_action='UPDATE' then
		
		--v_status:='GOU.'||v_status;
			update project set 
				 code=rr.code
				 ,program_id=v_program_id
				 ,area_code=v_area_code
				,planning_code=rr.planning_code
				,name=rr.name
				,state_code=v_state_code
				,category_code=v_category_code
				,substance_type_code=v_substance_type_code
				,phase_code=v_phase_code
				,d2_compound=rr.d2_compound
				,priority_code=rr.priority_code
				--,ipowner_code
				,source_code=v_source_code
				,is_lead=rr.is_lead
				,ta_code=v_ta_code
				,is_collaboration=rr.is_collaboration
				,details_partner=rr.details_partner
				,termination_date=v_termination_date
				,termination_code=v_termination_code
				,is_active=0
		   where id = o_prj.id --and nvl(phase_code,'###')<>nvl(v_phase_code,'###')
       ;
			COMMIT;
		--else
		 --v_status:='??.'||v_status;
		end if;

/*--TODO
		 begin
			v_timeline_id := null;
			
			begin
				select id into v_timeline_id from timeline where id=o_prj.id||'-RAW';
				--v_status:=v_status||';1T;';
			exception when no_data_found then
			   --v_status:=v_status||';2T;';
				dbms_lock.sleep(10);
				project_pkg.send(o_prj.id, null);
				--v_status:=v_status||';3T;';
				dbms_lock.sleep(15);
				select id into v_timeline_id from timeline where id=o_prj.id||'-RAW';
				--v_status:=v_status||';4T;';
			end;
			--v_status:=v_status||';5T;';

			--select count(1) into v_count from timeline_activity where timeline_id=v_timeline_id and milestone_code in ('eD3','D1','D2','CSM','D3');
			--if v_count=0 then
				dbms_lock.sleep(15);
				timeline_pkg.receive(v_timeline_id);
				commit;
				dbms_lock.sleep(15);
			--end if;
		 --------------------------------
		 --what of RAW exsists? then Updating based on Data and Publish, alwyas take RAW
		 --Make Active, or just Publish
		 --TESTING: select * from timeline_activity where timeline_id='1027-8373-RAW';
		 --create XML bsed on:  select * from timeline_activity where timeline_id='1027-8373-RAW';
		 --loop, because it must be 5 nodes:
			--v_status:=v_status||';1T;';
			select timeline_pkg.xml(v_timeline_id) into v_xml from dual;--:=xmltype('<timeline/>');
			--v_status:=v_status||';2T;';
			select insertchildxml(v_xml, '/*', 'wbsNodes', xmltype('<wbsNodes '||message_pkg.xmlns_ipms||'/>'))
			into v_xml
			from dual;
			--v_status:=v_status||';3T;';
			select insertchildxml(v_xml, '/*', 'activities', xmltype('<activities '||message_pkg.xmlns_ipms||'/>'))
			into v_xml
			from dual;
			--v_status:=v_status||';4T;';
			for aa in (select * from timeline_activity where timeline_id=v_timeline_id and milestone_code in ('eD3','D1','D2','CSM','D3') order by milestone_code) 
			loop
				if aa.milestone_code = 'D1' then --ObjectId exists
					if rr.d1_actual is not null then --Just Update
						v_date_send:=to_char(to_date(rr.d1_actual,'mm/dd/yyyy'),'yyyy-mm-dd')||'T08:00:00';
						v_mustBeDeleted:='false';
					else
						v_date_send:=v_date_now;
						v_mustBeDeleted:='true';
					end if;
				end if;

				if aa.milestone_code = 'D2' then --ObjectId exists
					if rr.d2_actual is not null then --Just Update
						v_date_send:=to_char(to_date(rr.d2_actual,'mm/dd/yyyy'),'yyyy-mm-dd')||'T08:00:00';
						v_mustBeDeleted:='false';
					else
						v_date_send:=v_date_now;
						v_mustBeDeleted:='true';
					end if;
				end if;
				
				if aa.milestone_code = 'D3' then --ObjectId exists
					if rr.d3ctual is not null then --Just Update
						v_date_send:=to_char(to_date(rr.d3ctual,'mm/dd/yyyy'),'yyyy-mm-dd')||'T08:00:00';
						v_mustBeDeleted:='false';
					else
						v_date_send:=v_date_now;
						v_mustBeDeleted:='true';
					end if;
				end if;
				
				if aa.milestone_code = 'CSM' then --ObjectId exists
					if rr.csm_actual is not null then --Just Update
						v_date_send:=to_char(to_date(rr.csm_actual,'mm/dd/yyyy'),'yyyy-mm-dd')||'T08:00:00';
						v_mustBeDeleted:='false';
					else
						v_date_send:=v_date_now;
						v_mustBeDeleted:='true';
					end if;
				end if;
				
				if aa.milestone_code = 'eD3' then --ObjectId exists
					if rr.ed3_actual is not null then --Just Update
						v_date_send:=to_char(to_date(rr.ed3_actual,'mm/dd/yyyy'),'yyyy-mm-dd')||'T08:00:00';
						v_mustBeDeleted:='false';
					else
						v_date_send:=v_date_now;
						v_mustBeDeleted:='true';
					end if;
				end if;
				
					select insertchildxml(v_xml,'//activities','activity',
					xmltype('<activity id="'||aa.activity_id||'" timelineId="'||aa.timeline_id||'" wbsId="'||aa.parent_wbs_id||'" mustBeDeleted="'||v_mustBeDeleted||'" '||message_pkg.xmlns_ipms||'><type>'||aa.type||'</type>'||
					'<planStart>'||v_date_send||'</planStart><planFinish>'||v_date_send||'</planFinish><actualStart>'||v_date_send||'</actualStart><actualFinish>'||v_date_send||'</actualFinish></activity>'),
					message_pkg.xmlns_ipms)
					into v_xml from dual;
--v_status:=v_status||';55555T;';
			end loop;		
			--v_status:=v_status||';5aT;';
			dbms_lock.sleep(15);
			  timeline_pkg.send(v_timeline_id,v_xml);--Update Timeline
			  commit;
			  --v_status:=v_status||';5bT;';
			  dbms_lock.sleep(15);
			  --v_status:=v_status||';6T;';
			  timeline_pkg.publish(v_timeline_id);
			  commit;
			  dbms_lock.sleep(15);
			--v_status:=v_status||';7T;';
			
			exception when others then
				v_stop_error:=v_stop_error||'.LOOP-TIMELINE.'||sqlerrm;
			end;

*/--TODO
		update import_excel set
										ref_id=o_prj.id,
										status=v_status||v_stop_error||';v_timeline_id='||v_timeline_id--||v_xml
		where column1=rr.code
		and file_name='D2'
		;
		-- and ROWID = rr.ROWID AND ORA_ROWSCN = rr.ORA_ROWSCN;

		COMMIT;


    end loop;
	 

	 
	 
	 
	end;
	/*************************************************************************/
	/*************************************************************************



	/*************************************************************************/
	procedure typify
	as
		v_program_id nvarchar2(20);
		v_project_id nvarchar2(20);
		v_status nvarchar2(4000);
		v_area_code nvarchar2(20);
		v_is_syncing number(2);
		v_import_program_code nvarchar2(99);

	begin

    for rr in (
					select
						a.*
						,nvl('RESERVED-PT-'||a.area_code,'#####MISSING#####') program_code
					from (
								select
										column1 code
										,decode(column7
													,'Controlling Object','CO'
													,'Research','RS'
													,'Lead Optimization','LO'
													,'D3-Transition','D3-TR'
													,'Lead Generation','LG'
													,'Product Maintenance Projects','PRD-MNT'
													,column7) area_code
								from import_excel
								where ref_id is null
								and column7 not in ('Development'
															,'D2-Projects'
															,'PIDT 31.10.14; ProMIS Liste 14.11.14'
															,'Untypified Projects')

								--and column1 in ('215399','310196','800246','800504','800243','800244','800242')--testing

							) a
					)
    loop
		v_status:=null;
		v_area_code:=null;
		v_project_id:=null;
		v_program_id:=null;
		v_import_program_code:=null;

		-------------------------
		--validate
		begin
			select id, area_code, is_syncing, import_program_code
			into v_project_id, v_area_code, v_is_syncing, v_import_program_code
			from project
			where code=rr.code;


			if v_area_code is not null then
				v_status:=v_status||'Project already typified! area_code='||v_area_code;
			else
					begin
						if rr.program_code <> 'RESERVED-PT-PRD-MNT' then
							v_import_program_code :=null;
						end if;

							select id into v_program_id
							from program
							where code=nvl(v_import_program_code,rr.program_code);


							if v_project_id is NOT null and v_program_id is NOT null and v_status is null then

								begin
									--UPDATE
									update project set area_code=rr.area_code, program_id=v_program_id
									where id=v_project_id
									and area_code is null
									and is_syncing=0
									returning id into v_project_id;

									if rr.program_code = 'RESERVED-PT-PRD-MNT' and v_project_id is not null then
										-- SOA-P6
										dbms_lock.sleep(3);
										program_pkg.send(v_program_id, 'dbms_lock.sleep(5); project_pkg.send('''||v_project_id||''');', 'create');
									elsif rr.program_code = 'RESERVED-PT-D3-TR' and v_project_id is not null then
										dbms_lock.sleep(3);
										project_pkg.send(v_project_id);
									end if;

									if v_project_id is not null then
										v_status:='OK';
									else
										v_status:='ERROR';
									end if;
									COMMIT;

								exception when others then
									v_status:=v_status||';Project UPDATE error='||sqlerrm;
								end;
							else
								v_status:=v_status||'Project cant be updated! v_project_id='||v_project_id||';v_program_id='||v_program_id||';rr.program_code='||rr.program_code;
							end if;

						exception when no_data_found then
							v_program_id :=null;
							v_status:=v_status||'Program is missing in ProMIS! program_code='||rr.program_code;
						end;
			end if;


		exception when no_data_found then
			v_project_id :=null;
			v_status:=v_status||'Project is missing in ProMIS!';
		end;


		-------------------------------------------------------------
		update import_excel set
										ref_id=v_project_id,
										status=v_status
		WHERE column1=rr.code;

		COMMIT;

    end loop;
	end;

	/*************************************************************************/
	procedure ipowner as
		v_project_id nvarchar2(20);
		v_ipowner_code nvarchar2(2220);
		v_status nvarchar2(4000);
	begin
		for rr in (
						select
							column1 code
							,column3 ipowner_code
						from import_excel
						where ref_id is null
						and column3<>'NA'
						--and column1='441700'--testing
						)
		loop
			v_project_id:=null;
			v_ipowner_code:=null;
			v_status:=null;
			-------------------------
			--validate
				begin
					select id, ipowner_code
					into v_project_id, v_ipowner_code
					from project
					where code=rr.code;

					if v_ipowner_code is null then
						begin
							select code into v_ipowner_code
							from ipowner
							where replace(upper(name),' ') = replace(upper(rr.ipowner_code),' ');

							update project set ipowner_code=v_ipowner_code
							where id = v_project_id and ipowner_code is null;

							v_status:=v_status||'OK;Updated.';

						exception
							when no_data_found then
								v_status:=v_status||'Provided IPOwner is missing='||rr.ipowner_code;
							when others then
								v_status:=v_status||'IPOwner issue='||rr.ipowner_code||';sqlerrm='||sqlerrm;
						end;
					else
						v_status:=v_status||'OK;IPOwner exists='||v_ipowner_code||';provided='||rr.ipowner_code;
					end if;

				exception when no_data_found then
					v_project_id :=null;
					v_status:=v_status||'Project is missing in ProMIS!';
				end;
			-------------------------------------------------------------
			update import_excel set
											ref_id=v_project_id,
											status=v_status
			WHERE column1=rr.code;

			COMMIT;
		end loop;
	end;



	/*************************************************************************/
	procedure costs_fps_import(p_file_name nvarchar2) as
		v_status nvarchar2(4000);
		v_function_code nvarchar2(200);
		v_id nvarchar2(200);
		v_project_id nvarchar2(200);
		v_subfunction_code nvarchar2(200);
	begin
		for rr in (
						select
							--decode(column1,'307110','','') project_id
							column1 project_id
							,decode(column2,'0',null, column2) study_id
							,replace(column3,'.0') function_id
							,replace(column4,'.0') subfunction_id
							,column5 cost_subtype_code
							,column6 int_ext_code
							,column7 year
							,column8 month
							,replace(column9,'.',',') cost_forecast
							,column10 prob_det_code
							,column11 commited_state
							,id
							--,rowid
							--,ora_rowscn
						from import_excel
						where ref_id is null
						and file_name=p_file_name
						--and column9='11.53537' and rownum=1
						)
		loop
			-------------------------
			--validate
			v_status:=null;
				begin
					if rr.function_id='111' then
						v_function_code:='CTPS_PO';

						select min(s.code) into v_subfunction_code
						from subfunction s where s.function_code=v_function_code;

					else
						select column3
						into v_function_code
						from import_excel
						where file_name='functionsCosts'
						and column1=rr.function_id and rownum=1;

						v_subfunction_code := rr.subfunction_id;
					end if;

					select id
					into v_project_id
					from project
					where code=rr.project_id;

					insert into ipms_data.costs_fps (
						project_id --1
						,study_id --2
						,subfunction_code --3
						,function_code --4
						,scope_code --5
						,method_code --6
						,type_code --7
						,subtype_code --8
						,cost --9
						,committed_state --10
						,start_date --11
						,finish_date --12
						)
					values (
						v_project_id --1
						,rr.study_id --2
						,v_subfunction_code --3
						,v_function_code --4
						,rr.int_ext_code --5
						,rr.prob_det_code --6
						,'FCT' --7
						,rr.cost_subtype_code --8
						,rr.cost_forecast --9
						,rr.commited_state --10
						,to_date('01-'||rr.month||'-'||rr.year,'DD-MM-YYYY') --11
						,last_day(to_date('01-'||rr.month||'-'||rr.year,'DD-MM-YYYY'))--12
						)
					returning id into v_id;
					v_status:='OK';

				exception when others then
					v_id :=null;
					v_status:=v_status||';rr.function_id='||rr.function_id||';sqlerrm='||sqlerrm;
				end;
			-------------------------------------------------------------
			update import_excel set
											ref_id=v_id,
											status=v_status
			--WHERE rowid = rr.rowid and ora_rowscn = rr.ora_rowscn and ref_id is null;
			WHERE id = rr.id;


			COMMIT;
		end loop;

		update costs_fps c set subfunction_code=(select min(s.code) from subfunction s where s.function_code=c.function_code );
		commit;

	end;


end;
/