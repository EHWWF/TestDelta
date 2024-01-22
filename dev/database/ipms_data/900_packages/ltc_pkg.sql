create or replace package ltc_pkg
as
	procedure launch(p_ltci_id in ltc_instance.id%type);
	procedure load(p_ltci_id in ltc_instance.id%type, p_payload in xmltype);
	procedure refresh_totals(p_ltci_id in ltc_instance.id%type default null);
	procedure prefill(p_ltci_id in ltc_instance.id%type default null);
	procedure prefill_profit(p_ltci_id in ltc_instance.id%type default null);
	procedure submit(p_ltci_id in ltc_instance.id%type);
	procedure submit_finish(p_ltci_id in ltc_instance.id%type, p_payload in xmltype);
	procedure submit_receive_finish(p_ltci_id in ltc_instance.id%type, p_payload in xmltype);
	--After generating LTC Excel data should be ASAP transfered to IPMS_REPO
	procedure push_ltc_to_repo(p_ltci_id in ltc_instance.id%type);
	
	--Function for checking if LTC for concrete timeline could be started, is not being blocked
	--if result 0 then it means all is fine and we can continue LTC
	function is_ltc_launch_allowed(p_timeline_id in nvarchar2, p_ltci_id in number) return number;
	
end;
/
create or replace package body ltc_pkg
as
	g_tlid timeline.id%type;
	g_done nvarchar2(99):='Procedure completed.';--standard text for informaing that procedure completed as expected.
	g_ltci ltc_instance%rowtype;


/*************************************************************************/
	function is_ltc_unique(p_ltci_id ltc_instance.id%type) return boolean as
		l_res smallint :=0;
	begin
	select 1 into l_res from dual 
	where not exists (
		select 1 from ltc_value ltcv 
		join ltc_plan ltcp on ltcp.id=ltcv.ltcp_id
		where ltcp.ltci_id=p_ltci_id
		group by ltcv.ltcp_id, ltcv.function_code
		having count(1) >1
	);
	return true;
	
	exception when no_data_found then
	return false;

	end is_ltc_unique;

	/*************************************************************************/
	--if result 1 then it means all is fine and we can continue LTC
	function is_ltc_launch_allowed(p_timeline_id in nvarchar2, p_ltci_id in number) return number
	as
		v_time_diff number:=1/48;--how long we look to past for ongoing LTC 1/24 means 1h
		v_response number:=1; --by default - allowed;
	begin
		-- Check if there are no any running/ not expired LTC instances
			for rr in (
							select 0 response 
							from dual 
							where exists (
								select 1 from ltc_instance li
								join ltc_plan lp on (li.id=lp.ltci_id)
								where li.timeline_id=p_timeline_id--g_tlid
									and li.id != p_ltci_id--g_ltci.id
									and li.stage_number!=0
									and (nvl(li.update_date,li.create_date) > sysdate-v_time_diff or li.create_date is null) 
									-- There is a period of time when LTC instance can be active without plan data (timeline receive in progress)
									and (nvl(lp.update_date,lp.create_date) > sysdate-v_time_diff or lp.create_date is null) 
									--after user selects Apply update_date will be changed at the table: ltc_plan ...and ... timeOut will be reseted
								)
							)
			loop
				v_response:=rr.response;
				exit;
			end loop;
		
		return v_response; --case when v_response = 0 then false else true end;
	end;

	/*****************************************************************************/
	procedure init_g_vars(p_ltci_id in ltc_instance.id%type)
	as
		v_where nvarchar2(222):='ltc_pkg.init_g_vars';
	begin
		begin
			select * into g_ltci from ltc_instance where id=p_ltci_id;
		exception when others then
			log_pkg.catch(v_where,'LTC:timeline_id='||g_tlid,'p_ltci_id='||p_ltci_id);
			raise;
		end;

		begin
			select id into g_tlid from timeline where id=g_ltci.timeline_id and is_syncing=0;
		exception when others then
			log_pkg.catch(v_where,'TIMELINE:timeline_id='||g_tlid,'p_ltci_id='||p_ltci_id);
			raise;
		end;

	end;

	/*****************************************************************************/
	procedure handle_exception(p_ltci_id in ltc_instance.id%type, p_steps_result in nvarchar2 default null) as
	begin
		update ltc_instance set status_code='FAIL', stage_number=0, is_syncing=0, update_date=sysdate where id=p_ltci_id;
		notice_pkg.catch('ltc:'||p_ltci_id, '[LTC planning '||p_ltci_id||'] failed.'||p_steps_result);
	end;

	/*****************************************************************************/
	function is_valid_msg_reply(p_payload in xmltype) return boolean
	as
		invalid_reply_error exception;
	begin
		if message_pkg.is_error(p_payload) = 1 then
			raise invalid_reply_error;
		end if;
		if message_pkg.is_complete(p_payload) = 0 then
			return false;
		end if;
		return true;
	end;

	/*****************************************************************************/
	procedure launch(p_ltci_id in ltc_instance.id%type)
	is
		v_rowcount number:=0;
		v_where nvarchar2(99):='ltc_pkg.launch';
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
	begin
		log_pkg.steps(null,v_step_start,v_steps_result);--null=BEGIN
		notice_pkg.information('ltc:'||p_ltci_id, '[LTC planning '||p_ltci_id||'] started.');

		-- Set src_project_id and timeline_id for easier joins

		update ltc_instance ltci
		set
			timeline_id = (
				select tl.id
				from timeline tl
				where
					ltci.project_id = tl.project_id and tl.type_code='RAW'
					or
					ltci.project_id is null and tl.id = (select snd_timeline_id from program_sandbox where id=ltci.sandbox_id)

			),
			src_project_id = (
				select id
				from project prj
				where
					ltci.project_id = prj.id
					or
					ltci.project_id is null and prj.id=(
						select sbx_src_tl.project_id
						from program_sandbox sbx
						inner join timeline sbx_src_tl on sbx_src_tl.id=sbx.timeline_id
						where sbx.id=ltci.sandbox_id
					)
		),update_date=sysdate
		where ltci.id=p_ltci_id;

		v_rowcount := v_rowcount + sql%rowcount;
		log_pkg.steps('a',v_step_start,v_steps_result);

		init_g_vars(p_ltci_id);--it is just a simple select inside
		
		if is_ltc_launch_allowed(g_tlid,g_ltci.id)=0 then 
			update ltc_instance set status_code='FAIL', stage_number=0 where id=g_ltci.id;
			notice_pkg.information('ltc:'||p_ltci_id, '[LTC planning '||p_ltci_id||'] is blocked.');
			v_steps_result:=v_steps_result||';LTC is blocked!';
		else
			-- Set initial Excel report the same as last one sucessfully submitted
			update ltc_instance ltci
			set
				excel_report = (
					select excel_report from (
						select *
						from ltc_instance
						where (project_id=g_ltci.project_id or sandbox_id=g_ltci.sandbox_id)
							and status_code='DONE'
							--and excel_report is not null
						order by create_date desc
					) where rownum = 1
				),update_date=sysdate
			where ltci.id=g_ltci.id;
	
			v_rowcount := v_rowcount + sql%rowcount;
	
			-- Retrieve timeline from P6
			update ltc_instance set is_syncing=1,update_date=sysdate where id = p_ltci_id;-- and is_syncing<>1;
			timeline_pkg.receive(g_tlid, 'begin ltc_pkg.load('||p_ltci_id||', :1); end;');

		end if;

		v_rowcount := v_rowcount + sql%rowcount;
		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, 'p_ltci_id='||p_ltci_id||';rowcount='||v_rowcount, v_steps_result);
	exception when others then
		handle_exception(p_ltci_id,v_where||':'||v_steps_result);
	end;

	/*************************************************************************/
	procedure load(p_ltci_id in ltc_instance.id%type, p_payload in xmltype)
	is
		v_rowcount number:=0;
		v_where nvarchar2(99):='ltc_pkg.load';
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
	begin
		log_pkg.steps(null,v_step_start,v_steps_result);--null=BEGIN

		if not is_valid_msg_reply(p_payload) then return; end if;

			update ltc_instance set is_syncing=0,update_date=sysdate where id = p_ltci_id;-- and is_syncing<>0;

			init_g_vars(p_ltci_id);

			--Delete previous values
			delete from ltc_plan
			where ltci_id in (select id from ltc_instance where project_id=g_ltci.project_id or sandbox_id=g_ltci.sandbox_id);

			v_rowcount := v_rowcount + sql%rowcount;
			log_pkg.steps('a',v_step_start,v_steps_result);

			-----------------------------------------------------------------------
			-- Load all WBS elements for LTC planning - including root WBS element
			for rr in (
				select
					g_ltci.id as ltci_id,
	
					wbs.wbs_id,	wbs.parent_wbs_id,
					wbs.code, wbs.name,
					wbs.start_date, wbs.finish_date,
	
					st.study_id,
					st.plan_patients, st.actual_patients,
					st.int_ext_flag, st.study_modus_no,	st.study_modus_name, st.clin_plan_type,	st.study_unit_count, st.study_unit_count_plan,
	
					cst.int_act_total, cst.cro_act_total, cst.ecg_act_total, cst.oec_act_total,
					cst.int_fct_total, cst.cro_fct_total, cst.ecg_fct_total, cst.oec_fct_total
				from ltc_wbs_vw wbs
				left join study_data_vw st on st.timeline_id=wbs.timeline_id and st.wbs_id=wbs.wbs_id
				left join 
							(
									select
										timeline_id, wbs_id,
										int_act_total, cro_act_total, ecg_act_total, oec_act_total,
										int_fct_total, cro_fct_total, ecg_fct_total, oec_fct_total
									from (
											select
												cst.timeline_id,
												cst.wbs_id,
												cst.cost_type_code,
												sum(cst.act_cost) act_cost,
												sum(cst.fct_cost_fps) fct_cost_fps
											from ltc_imported_costs_vw cst-- PROMISIII-262
											group by cst.timeline_id,cst.wbs_id,cst.cost_type_code
									)
									pivot (
										sum(act_cost) act_total, sum(fct_cost_fps) fct_total
										for cost_type_code in ('INT' as int, 'CRO' as cro, 'ECG' as ecg, 'OEC' as oec)
									)
									where timeline_id=g_ltci.timeline_id
							) cst on cst.timeline_id=wbs.timeline_id and cst.wbs_id=wbs.wbs_id
				where wbs.timeline_id=g_ltci.timeline_id
			)
			loop
				insert into ltc_plan
				(
					ltci_id,
	
					wbs_id,	parent_wbs_id,
					code, name,
					start_date,	finish_date,
	
					study_id,
					plan_patients, actual_patients,
					int_ext_flag, study_modus_no, study_modus_name, clin_plan_type, study_unit_count, study_unit_count_plan,
	
					act_int_cost_total, act_cro_cost_total, act_ecg_cost_total, act_oec_cost_total,
					fc_int_cost_total, fc_cro_cost_total, fc_ecg_cost_total, fc_oec_cost_total
				)
				values
				(
					rr.ltci_id,
	
					rr.wbs_id,	rr.parent_wbs_id,
					rr.code, rr.name,
					rr.start_date,	rr.finish_date,
	
					rr.study_id,
					rr.plan_patients, rr.actual_patients,
					rr.int_ext_flag, rr.study_modus_no, rr.study_modus_name, rr.clin_plan_type, rr.study_unit_count, rr.study_unit_count_plan,
	
					rr.int_act_total, rr.cro_act_total, rr.ecg_act_total, rr.oec_act_total,
					rr.int_fct_total, rr.cro_fct_total, rr.ecg_fct_total, rr.oec_fct_total								
				);
				v_rowcount := v_rowcount + 1;
			end loop;
			-----------------------------------------------------------------------

			--v_rowcount := v_rowcount + sql%rowcount;
			log_pkg.steps('b',v_step_start,v_steps_result);

			-----------------------------------------------------------------------
			-- Load existing LTC expenses
			insert into ltc_value (
				ltcp_id,
				function_code,
				lt_int_cost, lt_cro_cost, lt_ecg_cost, lt_oec_cost,
				comments
			)
			with
				cst as (
					select
						timeline_id, wbs_id,
						function_code,
						int_lt_total, cro_lt_total, ecg_lt_total, oec_lt_total,
						lt_cost_comments
					from (
						select
							timeline_id, wbs_id, function_code, cost_type_code,
							sum(lt_cost) lt_cost,
							max(lt_cost_comments) lt_cost_comments
						from ltc_rmng_vw
						where timeline_id=g_ltci.timeline_id
						group by timeline_id, wbs_id, function_code, cost_type_code
					)
					pivot (
						sum(lt_cost) lt_total
						for cost_type_code in ('INT' as int, 'CRO' as cro, 'ECG' as ecg, 'OEC' as oec)
					)

				)
			select
				ltcp.id,
				function_code,
				int_lt_total, cro_lt_total, ecg_lt_total, oec_lt_total,
				lt_cost_comments
			from ltc_plan ltcp
			inner join cst on ltcp.wbs_id=cst.wbs_id
			where ltcp.ltci_id=g_ltci.id;
			-----------------------------------------------------------------------

			v_rowcount := v_rowcount + sql%rowcount;
			log_pkg.steps('c',v_step_start,v_steps_result);

			-- Refresh the 'LTC Total' row
			refresh_totals(p_ltci_id);

			v_rowcount := v_rowcount + sql%rowcount;
			log_pkg.steps('d',v_step_start,v_steps_result);

			-- That's it
			update ltc_instance set status_code='READY',update_date=sysdate,stage_number=10 where id=p_ltci_id;

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, 'p_ltci_id='||p_ltci_id||';rowcount='||v_rowcount, v_steps_result);

	exception when others then
		handle_exception(p_ltci_id,v_steps_result);
	end;

	/*************************************************************************/
	procedure refresh_totals(p_ltci_id in ltc_instance.id%type default null)
	as
		v_rowcount number:=0;
		v_where nvarchar2(99):='ltc_pkg.refresh_totals';
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
	begin
		log_pkg.steps(null,v_step_start,v_steps_result);--null=BEGIN

		-- Insert the 'totals' row by checking how many rows there are without parent row. There will 2: project and totals.
		-- If LTC Instance Id is not supplied - then check all instances with status READY
		insert into ltc_plan (
			ltci_id, name,
			fc_int_cost_total, fc_cro_cost_total, fc_ecg_cost_total, fc_oec_cost_total,
			act_int_cost_total, act_cro_cost_total, act_ecg_cost_total, act_oec_cost_total
		)
		select
			ltci_id, 'Long-term Costs Total',
			sum(fc_int_cost_total), sum(fc_cro_cost_total), sum(fc_ecg_cost_total), sum(fc_oec_cost_total),
			sum(act_int_cost_total), sum(act_cro_cost_total), sum(act_ecg_cost_total), sum(act_oec_cost_total)
		from ltc_plan
		where (ltci_id=p_ltci_id or p_ltci_id is null and exists(select * from ltc_instance where id=ltci_id and status_code='READY'))
		group by ltci_id
		having count(decode(parent_wbs_id, null, 1)) = 1;

		v_rowcount := v_rowcount + sql%rowcount;
		log_pkg.steps('a',v_step_start,v_steps_result);

		-- Add/update/delete total row values for each function. ADF will do the rest.
		-- Calculate sums of all rows except the totals row (that's why decode is there).
		-- If LTC Instance Id is not supplied - then update all instances with status READY
		-- Delete rows where we don't have data after update.
		merge into ltc_value ltcv
			using (
				select
					ltcp_tgt.ltci_id, ltcp_tgt.id as ltcp_id, ltcv.function_code,
					sum(decode(ltcv.ltcp_id, ltcp_tgt.id, null, lt_int_cost)) as lt_int_cost,
					sum(decode(ltcv.ltcp_id, ltcp_tgt.id, null, lt_cro_cost)) as lt_cro_cost,
					sum(decode(ltcv.ltcp_id, ltcp_tgt.id, null, lt_ecg_cost)) as lt_ecg_cost,
					sum(decode(ltcv.ltcp_id, ltcp_tgt.id, null, lt_oec_cost)) as lt_oec_cost
				from ltc_plan ltcp
				inner join ltc_value ltcv on ltcv.ltcp_id=ltcp.id
				inner join ltc_plan ltcp_tgt on ltcp_tgt.ltci_id=ltcp.ltci_id and ltcp_tgt.wbs_id is null and ltcp_tgt.name='Long-term Costs Total'
				where (ltcp_tgt.ltci_id=p_ltci_id or p_ltci_id is null and exists(select * from ltc_instance where id=ltcp_tgt.ltci_id and status_code='READY'))
				group by ltcp_tgt.ltci_id, ltcp_tgt.id, ltcv.function_code
			) ltct on (ltct.ltcp_id=ltcv.ltcp_id and ltct.function_code=ltcv.function_code)
			when matched then
				update set ltcv.lt_int_cost = ltct.lt_int_cost, ltcv.lt_cro_cost = ltct.lt_cro_cost, ltcv.lt_ecg_cost=ltct.lt_ecg_cost, ltcv.lt_oec_cost=ltct.lt_oec_cost
				delete where lt_int_cost is null and lt_cro_cost is null and lt_ecg_cost is null and lt_oec_cost is null
			when not matched then
				insert (ltcp_id, function_code, lt_int_cost, lt_cro_cost, lt_ecg_cost, lt_oec_cost)
					values (ltct.ltcp_id, ltct.function_code, ltct.lt_int_cost, ltct.lt_cro_cost, ltct.lt_ecg_cost, ltct.lt_oec_cost);

		v_rowcount := v_rowcount + sql%rowcount;
		log_pkg.steps('b',v_step_start,v_steps_result);

		-- Update all ltc_plan rows with totals
		update ltc_plan ltcp
		set (lt_int_cost_total, lt_cro_cost_total, lt_ecg_cost_total, lt_oec_cost_total) =
		(select sum(lt_int_cost), sum(lt_cro_cost), sum(lt_ecg_cost), sum(lt_oec_cost) from ltc_value where ltcp_id=ltcp.id)
		where ltci_id=p_ltci_id;

		v_rowcount := v_rowcount + sql%rowcount;
		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, 'p_ltci_id='||p_ltci_id||';rowcount='||v_rowcount, v_steps_result);
	end;

	/*************************************************************************/
	procedure prefill(p_ltci_id in ltc_instance.id%type default null) as
		v_rowcount number;
		v_where nvarchar2(99):='ltc_pkg.prefill';
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
	begin
		log_pkg.steps(null,v_step_start,v_steps_result);
		-- Select FPS costs and pivot them into columns. Time slices are ignored.
		-- Refresh LTC costs per WBS/function. If LTCs exist for a certain function then all cost type values are updated.

		merge into ltc_value ltcv
		using (
			select * from (
				select
					ltcp.id as ltcp_id,
					function_code,
					cost_type_code,
					sum(nvl(act_cost, fct_cost_fps)) as lt_cost_pre
				from ltc_instance ltci
				inner join ltc_plan ltcp on ltcp.ltci_id=ltci.id
				inner join ltc_imported_costs_vw cst on cst.timeline_id=ltci.timeline_id and cst.wbs_id=ltcp.wbs_id
				where ltci.id=p_ltci_id
				group by ltcp.id, function_code, cost_type_code
				having count(fct_cost_fps) > 0
			)
			pivot (
				sum(lt_cost_pre) for cost_type_code in ('INT' as lt_int_cost, 'ECG' as lt_ecg_cost, 'CRO' as lt_cro_cost, 'OEC' as lt_oec_cost)
			)
		) ltcpf on (ltcpf.ltcp_id=ltcv.ltcp_id and ltcpf.function_code=ltcv.function_code)
		when matched then
			update set ltcv.lt_int_cost = ltcpf.lt_int_cost, ltcv.lt_cro_cost = ltcpf.lt_cro_cost, ltcv.lt_ecg_cost=ltcpf.lt_ecg_cost, ltcv.lt_oec_cost=ltcpf.lt_oec_cost
		when not matched then
			insert (ltcp_id, function_code, lt_int_cost, lt_cro_cost, lt_ecg_cost, lt_oec_cost)
				values (ltcpf.ltcp_id, ltcpf.function_code, ltcpf.lt_int_cost, ltcpf.lt_cro_cost, ltcpf.lt_ecg_cost, ltcpf.lt_oec_cost);

		v_rowcount:=sql%rowcount;
		log_pkg.steps('a',v_step_start,v_steps_result);
		--------------------------------------------------------------------------
		-- Now refresh the totals rows
		refresh_totals(p_ltci_id);

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, 'p_ltci_id='||p_ltci_id||';v_rowcount='||v_rowcount,v_steps_result);
	end;

	/*************************************************************************/	
	procedure prefill_profit(p_ltci_id in ltc_instance.id%type default null) as
		v_rowcount number;
		v_where nvarchar2(99):='ltc_pkg.prefill_profit';
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
	begin
		log_pkg.steps(null,v_step_start,v_steps_result);
		-- Select FPS costs and pivot them into columns. Time slices are ignored.
		-- Refresh LTC costs per WBS/function. If LTCs exist for a certain function then all cost type values are updated.

		merge into ltc_value ltcv
		using (
			select * from (
				select
					ltcp.id as ltcp_id,
					function_code,
					cost_type_code,
					sum(nvl(act_cost, fct_cost_fps)) as lt_cost_pre
				from ltc_instance ltci
				inner join ltc_plan ltcp on (ltcp.ltci_id=ltci.id)
				inner join ltc_imported_costs_vw cst on (cst.timeline_id=ltci.timeline_id and cst.wbs_id=ltcp.wbs_id)
				where ltci.id=p_ltci_id
				group by ltcp.id, function_code, cost_type_code
				having count(fct_cost_fps) > 0
			)
			pivot (
				sum(lt_cost_pre) for cost_type_code in ('INT' as lt_int_cost, 'ECG' as lt_ecg_cost, 'CRO' as lt_cro_cost, 'OEC' as lt_oec_cost)
			)
		) ltcpf on (ltcpf.ltcp_id=ltcv.ltcp_id and ltcpf.function_code=ltcv.function_code)
		when matched then
			update set ltcv.lt_int_cost = ltcpf.lt_int_cost, ltcv.lt_cro_cost = ltcpf.lt_cro_cost, ltcv.lt_ecg_cost=ltcpf.lt_ecg_cost, ltcv.lt_oec_cost=ltcpf.lt_oec_cost
		when not matched then
			insert (ltcp_id, function_code, lt_int_cost, lt_cro_cost, lt_ecg_cost, lt_oec_cost)
				values (ltcpf.ltcp_id, ltcpf.function_code, ltcpf.lt_int_cost, ltcpf.lt_cro_cost, ltcpf.lt_ecg_cost, ltcpf.lt_oec_cost);

		v_rowcount:=sql%rowcount;
		log_pkg.steps('a',v_step_start,v_steps_result);
		--------------------------------------------------------------------------
		-- Now refresh the totals rows
		refresh_totals(p_ltci_id);

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, 'p_ltci_id='||p_ltci_id||';v_rowcount='||v_rowcount,v_steps_result);
	end;

	/*************************************************************************/
	procedure submit(p_ltci_id in ltc_instance.id%type)
	is
		v_timeline_xml xmltype;
		v_where nvarchar2(99):='ltc_pkg.submit';
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
	begin
		log_pkg.steps(null,v_step_start,v_steps_result);--null=BEGIN
		
		if not is_ltc_unique(p_ltci_id) then 
			raise dup_val_on_index;
		end if;

		init_g_vars(p_ltci_id);

		-- Create timeline payload

		v_timeline_xml := timeline_pkg.xml(g_tlid);

		log_pkg.steps('a',v_step_start,v_steps_result);

		with
			expenses as (
				select
					wbs_id,
					wbs_id||'-'||rownum as id,
					function_code,
					decode(lower(cost_type_code), 'lt_int_cost', 'Internal Cost', 'lt_cro_cost', 'External Cost - CRO', 'lt_ecg_cost', 'External Cost - ECG', 'lt_oec_cost', 'External Cost - OEC') as cost_type,
					plan_cost,
					comments
				from ltc_value ltcv
				inner join ltc_plan ltcp on ltcp.id=ltcv.ltcp_id
				unpivot (plan_cost for cost_type_code in (lt_int_cost, lt_cro_cost, lt_ecg_cost, lt_oec_cost))
				where ltci_id=g_ltci.id
					and wbs_id is not null -- do not submit totals
			),
			expenses_xml as (
				select
					xmlelement("expenses",
						xmlattributes(message_pkg.nsuri_ipms as "xmlns"),
						xmlagg(
						xmlelement("expense",
							xmlattributes(
								wbs_id as "wbsId",
								id as "id"
							),
							xmlforest(
								function_code as "functionCode",
								cost_type as "costType",
								to_char(plan_cost, 'FM999999999990.00999999') as "planCost",
								comments as "comments"
							)
						))
					) payload
				from expenses
				where plan_cost is not null
			)
		select v_timeline_xml.appendChildXML('/*', payload)
		into v_timeline_xml
		from expenses_xml;

		log_pkg.steps('b',v_step_start,v_steps_result);

		--Assign Ltc ID for Project, because later it will be needed for Baselines (after Publications)
		select
			insertxmlafter(
				v_timeline_xml,
				'//timeline/comments',
				xmltype('<ltcId '||message_pkg.xmlns_ipms||'>'||p_ltci_id||'</ltcId>'),
				message_pkg.xmlns_ipms
		)
		into v_timeline_xml from dual;

		-- The monkey has a gift that keeps sending back to you

		notice_pkg.debug('LTC','Submitting instance ID='||p_ltci_id);
		timeline_pkg.send(g_tlid, v_timeline_xml, 'ltc_pkg.submit_finish('||p_ltci_id||', :1);');
		update ltc_instance set status_code='SEND', is_syncing=1, excel_report=null,update_date=sysdate,stage_number=20 where id = p_ltci_id;

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, 'p_ltci_id='||p_ltci_id,v_steps_result);
	exception when others then
		handle_exception(p_ltci_id,v_steps_result);
	end;

	/*************************************************************************/
	procedure submit_finish(p_ltci_id in ltc_instance.id%type, p_payload in xmltype)
	is
		v_report nclob;
		v_where nvarchar2(99):='ltc_pkg.submit_finish';
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
	begin
		log_pkg.steps(null,v_step_start,v_steps_result);--null=BEGIN

		if not is_valid_msg_reply(p_payload) then return; end if;

		init_g_vars(p_ltci_id);

		-- Request updated timeline and proceed to report generation
		--log_pkg.log(v_where, 'p_ltci_id='||p_ltci_id, 'Timelien submit successful. Reading back timeline from P6.');
		log_pkg.steps('a',v_step_start,v_steps_result);
		timeline_pkg.receive(g_tlid, 'ltc_pkg.submit_receive_finish('||p_ltci_id||', :1);');

		-- Mark LTC instance as done
		update ltc_instance set status_code='DONE', is_syncing=0,update_date=sysdate,stage_number=30 where id = p_ltci_id;-- and is_syncing<>0;

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, 'p_ltci_id='||p_ltci_id,v_steps_result);
	exception when others then
		handle_exception(p_ltci_id,v_steps_result);
	end;

	/*************************************************************************/
	procedure submit_receive_finish(p_ltci_id in ltc_instance.id%type, p_payload in xmltype)
	is
		v_where nvarchar2(99):='ltc_pkg.submit_receive_finish';
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
		v_job_name nvarchar2(99):='LTC_GENERATE_REPORT_JOB';
		v_count pls_integer;
	begin
		log_pkg.steps(null,v_step_start,v_steps_result);

		if not is_valid_msg_reply(p_payload) then return; end if;

		--JOB name must be unique
		--reuse existing SEQuence, e.g. ANNOUNCEMENT_ID_SEQ
		select v_job_name||announcement_id_seq.nextval into v_job_name from dual;

		--this part, with COUNT is not mandatory, but better to have it (low cost of having).
			select count(1)
			into v_count
			from user_scheduler_jobs
			where job_name = v_job_name;

			if v_count = 0 then
				dbms_scheduler.create_job(
					job_name=>v_job_name,
					job_type=>'plsql_block',
					job_action=>'ltc_report_pkg.generate('||p_ltci_id||');',
					enabled=>true
				);
			else
				log_pkg.steps('JOB_EXISTS',v_step_start,v_steps_result);
			end if;

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, 'p_ltci_id='||p_ltci_id,v_steps_result);

	exception when others then
		handle_exception(p_ltci_id,v_steps_result);
	end;


	/*************************************************************************/
	procedure push_ltc_to_repo(p_ltci_id in ltc_instance.id%type)
	is
		v_where nvarchar2(99):='ltc_pkg.push_ltc_to_repo';
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
		v_count pls_integer;
	begin
		log_pkg.steps(null,v_step_start,v_steps_result);

		insert into ipms_repo.promis_task(id,create_date) values(p_ltci_id,sysdate);

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, 'p_ltci_id='||p_ltci_id,v_steps_result);

	exception when others then
		--handle_exception(p_ltci_id,v_steps_result);
		log_pkg.catch(v_where, 'p_ltci_id='||p_ltci_id, v_steps_result);
	end;

end;
/
