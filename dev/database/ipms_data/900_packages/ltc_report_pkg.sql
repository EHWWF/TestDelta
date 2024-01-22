create or replace package ltc_report_pkg as

	procedure generate(p_ltci_id ltc_instance.id%type);

	function generate(p_timeline_id timeline.id%type) return nclob;

	-- Helper functions to generate necessary periods (months and years)

	type date_rec_typ is record (
		year			number,
		start_date		date,
		finish_date		date,
		cnt_full_months	number
	);
	type date_rec_set is table of date_rec_typ;

	function years(p_start_date in date, p_finish_date in date) return date_rec_set pipelined;

	function months(p_start_date in date, p_finish_date in date) return date_rec_set pipelined;

	--parameters are being passed to LTC VIEW during Excel generation
	function get_project_id return nvarchar2;
	procedure set_project_id(p_project_id nvarchar2);
	function get_timeline_id return nvarchar2;
	procedure set_timeline_id(p_timeline_id nvarchar2);
	
end;
/
create or replace package body ltc_report_pkg as

	g_xls_rows nclob;
	g_xls_row_cnt number;
	g_xls_col_cnt number;
	g_xls_col_cnt_max number;
	--g_done nvarchar2(99):='Procedure completed.';--standard text for informaing that procedure completed as expected.
	g_project_id nvarchar2(99); --used for setting internal param for ltc_costs_vw
	g_timeline_id nvarchar2(99); --used for setting internal param for ltc_costs_vw



	/*************************************************************************/
	procedure set_timeline_id(p_timeline_id nvarchar2) 
	as
		v_where nvarchar2(99):='ltc_report_pkg.set_timeline_id';
	begin
		g_timeline_id := p_timeline_id;
		log_pkg.log(v_where, 'p_timeline_id='||p_timeline_id, g_timeline_id);
	end set_timeline_id;

	/*************************************************************************/
	function get_timeline_id return nvarchar2 as
	begin
	 return g_timeline_id;
	end get_timeline_id;

	/*************************************************************************/
	function get_project_id return nvarchar2 as
	begin
	 return g_project_id;
	end get_project_id;

	/*************************************************************************/
	procedure set_project_id(p_project_id nvarchar2) 
	as
		v_where nvarchar2(99):='ltc_report_pkg.set_project_id';
	begin
		g_project_id := p_project_id;
		log_pkg.log(v_where, 'project_id='||p_project_id, g_project_id);
	end set_project_id;

	/*************************************************************************/
	function years(p_start_date in date, p_finish_date in date) return date_rec_set pipelined
	is
		v_out_rec date_rec_typ;
	begin
		if p_start_date is null or p_finish_date is null then return; end if;


		for yy in 0  .. extract(year from p_finish_date) - extract(year from p_start_date)
		loop

			v_out_rec.year := extract(year from p_start_date) + yy;
			v_out_rec.start_date := greatest(p_start_date, trunc(add_months(p_start_date, 12*yy), 'YY'));
			v_out_rec.finish_date := least(p_finish_date, trunc(add_months(p_start_date, 12*(yy+1)), 'YY')-1/24/60/60);
			v_out_rec.cnt_full_months := ceil(months_between(v_out_rec.finish_date, v_out_rec.start_date));

			pipe row (v_out_rec);
		end loop;
	end;

	/*************************************************************************/
	function months(p_start_date in date, p_finish_date in date) return date_rec_set pipelined
	is
		v_out_rec date_rec_typ;
	begin
		if p_start_date is null or p_finish_date is null then return; end if;

		for mm in 0  .. months_between(trunc(p_finish_date, 'MM'), trunc(p_start_date, 'MM'))
		loop

			v_out_rec.start_date := greatest(p_start_date, add_months(trunc(p_start_date, 'MM'), mm));
			v_out_rec.finish_date := least(p_finish_date, add_months(v_out_rec.start_date, 1)-1/24/60/60);
			v_out_rec.cnt_full_months := 1;
			v_out_rec.year := extract(year from v_out_rec.start_date);

			pipe row (v_out_rec);
		end loop;
	end;

	/*************************************************************************/
	procedure xls_init
	is
	begin
		g_xls_row_cnt := 0;
		g_xls_col_cnt := 0;
		g_xls_col_cnt_max := 0;

		if g_xls_rows is null then
			dbms_lob.createTemporary(g_xls_rows, false);
		else
			dbms_lob.trim(g_xls_rows, 0);
		end if;

	end;

	/*************************************************************************/
	function xls_to_lob return nclob
	is
		v_xls nclob;
		v_xls_header nvarchar2(16000);
		v_xls_footer nvarchar2(16000);
	begin

		v_xls_header :=
			'<?xml version="1.0"?>'||
			'<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" xmlns:html="http://www.w3.org/TR/REC-html40">'||
				'<DocumentProperties xmlns="urn:schemas-microsoft-com:office:office"><Author>ProMIS</Author><LastAuthor>ProMIS</LastAuthor><Created>2015-06-26T12:25:42Z</Created><Company>BHC</Company><Version>14.0</Version></DocumentProperties>'||
				'<OfficeDocumentSettings xmlns="urn:schemas-microsoft-com:office:office"><AllowPNG/></OfficeDocumentSettings>'||
				'<ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel"><WindowHeight>19540</WindowHeight><WindowWidth>38080</WindowWidth><WindowTopX>240</WindowTopX><WindowTopY>240</WindowTopY><ProtectStructure>False</ProtectStructure><ProtectWindows>False</ProtectWindows></ExcelWorkbook>'||
				'<Styles>'||
					'<Style ss:ID="Default" ss:Name="Normal"><Alignment ss:Vertical="Bottom"/><Borders/><Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="12" ss:Color="#000000"/><Interior/><NumberFormat/><Protection/></Style>'||
					'<Style ss:ID="s62"><Alignment ss:Vertical="Bottom" ss:WrapText="1"/></Style>'||
					'<Style ss:ID="s63"><Alignment ss:Vertical="Bottom" ss:WrapText="1"/><NumberFormat ss:Format="Fixed"/></Style>'||
					'<Style ss:ID="s64"><Alignment ss:Horizontal="Center" ss:Vertical="Bottom" ss:WrapText="1"/><NumberFormat ss:Format="Short Date"/></Style>'||
					'<Style ss:ID="s69"><Alignment ss:Vertical="Center" ss:WrapText="1"/><Font ss:FontName="Calibri" ss:Size="12" ss:Color="#000000" ss:Bold="1"/></Style>'||
					'<Style ss:ID="s70"><Alignment ss:Vertical="Center"/><Font ss:FontName="Calibri" ss:Size="12" ss:Color="#000000" ss:Bold="1"/></Style>'||
					'<Style ss:ID="s74" ss:Parent="s63"><Font ss:Color="#006100"/></Style>'||
				'</Styles>'||
			'<Worksheet ss:Name="LTC">'||
			'<Table ss:ExpandedColumnCount="'||(g_xls_col_cnt_max+10)||'" ss:ExpandedRowCount="'||g_xls_row_cnt||'">'||
			'<Column ss:AutoFitWidth="1" ss:Width="157"/><Column ss:AutoFitWidth="1" ss:Width="335"/><Column ss:Index="9" ss:AutoFitWidth="1" ss:Width="220"/><Column ss:Index="10" ss:AutoFitWidth="1" ss:Width="120"/>'||
			'<Row ss:Height="75">';

		v_xls_footer :=
			'</Row>'||
			'</Table>'||
			'</Worksheet>'||
			'</Workbook>';

		dbms_lob.createTemporary(v_xls, false);
		dbms_lob.writeAppend(v_xls, length(v_xls_header), v_xls_header);
		dbms_lob.append(v_xls, g_xls_rows);
		dbms_lob.writeAppend(v_xls, length(v_xls_footer), v_xls_footer);

		return v_xls;
	end;

	/*************************************************************************/
	function xls_cell(p_val in nvarchar2, p_style in nvarchar2 := 's62', p_type in nvarchar2:='String') return nvarchar2
	is
	begin
		return case
			when p_val is null then '<Cell ss:StyleID="'||p_style||'"/>'
			else '<Cell ss:StyleID="'||p_style||'"><Data ss:Type="'||p_type||'">'||htf.escape_sc(p_val)||'</Data></Cell>'
		end;
	end;

	/*************************************************************************/
	procedure xls_new_row
	is
	begin
		g_xls_row_cnt := g_xls_row_cnt + 1;

		if g_xls_row_cnt = 1 then
			--g_xls_rows := g_xls_rows || '<Row ss:Height="45"></Row>';
			return;
		end if;

		dbms_lob.writeAppend(g_xls_rows, 11, '</Row><Row>');
		--g_xls_rows := g_xls_rows || '<Row></Row>';

	end;

	/*************************************************************************/
	procedure xls_add_cell(p_val in nvarchar2, p_style in nvarchar2 := null, p_type in nvarchar2:='String')
	is
		v_style nvarchar2(20);
		v_cell_txt nvarchar2(10000);
	begin

		v_style := case
			when p_style is null and g_xls_row_cnt = 1
			then 's69'
			when p_style is null
			then 's62'
			else p_style
		end;


		g_xls_col_cnt := g_xls_col_cnt + 1;
		g_xls_col_cnt_max := greatest(g_xls_col_cnt, g_xls_col_cnt_max);

		v_cell_txt := xls_cell(p_val, v_style, p_type);
		dbms_lob.writeAppend(g_xls_rows, length(v_cell_txt), v_cell_txt);

	end;

	/*************************************************************************/

	procedure xls_add_cell(p_val in number, p_style in nvarchar2 := 's63')
	is
	begin
		xls_add_cell(to_char(p_val, 'FM999999999990.009999'), p_style, 'Number');
	end;

	/*************************************************************************/

	procedure xls_add_cell(p_val in date, p_style in nvarchar2 := 's64')
	is
	begin
		xls_add_cell(to_char(p_val, 'YYYY-MM-DD"T"HH24:MI:SS".000"'), p_style, 'DateTime');
	end;

	/*************************************************************************/

	procedure generate(p_ltci_id ltc_instance.id%type)
	as
		v_timeline_id timeline.id%type;
		v_report nclob;
		v_where nvarchar2(99):='ltc_report_pkg.generate.p';
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
		v_project_id nvarchar2(99);
	begin
		log_pkg.steps(null,v_step_start,v_steps_result);

		select timeline_id, src_project_id
		into v_timeline_id, v_project_id
		from ltc_instance
		where id=p_ltci_id;

		if v_project_id is not null then
			ltc_report_pkg.set_project_id(v_project_id);
		end if;
		if v_timeline_id is not null then
			ltc_report_pkg.set_timeline_id(v_timeline_id);
		end if;

		v_report := generate(v_timeline_id);

		update ltc_instance
		set excel_report = v_report,
			stage_number=40,
			update_date=sysdate
		where id=p_ltci_id;

		log_pkg.steps('GENERATE',v_step_start,v_steps_result);

		--Send ASAP data to IPMS_REPO
		ltc_pkg.push_ltc_to_repo(p_ltci_id);

		--update ltc_instance set update_date=sysdate where id=p_ltci_id;
		ltc_report_pkg.set_project_id(null);--just in case, clean
		ltc_report_pkg.set_timeline_id(null);

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, 'p_ltci_id='||p_ltci_id, v_steps_result);

	exception when others then
		notice_pkg.catch(v_where, 'p_ltci_id='||p_ltci_id||v_steps_result);
		--raise;
	end;

	/*************************************************************************/
	function generate(p_timeline_id in timeline.id%type) return nclob
	as
		v_act_start date;
		v_act_finish date;
		v_fct_start date;
		v_fct_finish date;
		v_ltc_rmng_start date;
		v_ltc_rmng_finish date;
		
		v_mm_finish date;
		v_case1_style nvarchar2(22);
		v_is_rmng_case1 pls_integer;
		v_least_start date;
		v_greatest_finish date;
		v_least_start_case1 date;
		v_greatest_finish_case1 date;
		
		v_where nvarchar2(99):='ltc_report_pkg.generate.f';
		v_step_start timestamp:= systimestamp;
		v_steps_result nvarchar2(4000);
		v_procedure_start timestamp:= systimestamp;
		iii pls_integer:=0;
	begin
		log_pkg.steps(null,v_step_start,v_steps_result);
		-- These will be used to show constant number of dynamic columns

		select
			min(act_cost_start_date), max(act_cost_finish_date),
			min(fct_cost_fps_start_date), max(fct_cost_fps_finish_date),
			min(lt_cost_rmng_start_date), max(lt_cost_rmng_finish_date),
			max(is_rmng_case1)
		into
			v_act_start, v_act_finish,
			v_fct_start, v_fct_finish,
			v_ltc_rmng_start, v_ltc_rmng_finish,
			v_is_rmng_case1
		from ltc_report_vw
		where timeline_id = p_timeline_id;

		v_least_start := least(nvl(v_fct_start, v_ltc_rmng_start), nvl(v_ltc_rmng_start, v_fct_start));
		v_greatest_finish := greatest(nvl(v_fct_finish, v_ltc_rmng_finish), nvl(v_ltc_rmng_finish, v_fct_finish));
		if v_is_rmng_case1 = 1 then --we will need MAX column range
			v_least_start_case1 := v_least_start;
			v_greatest_finish_case1 := v_greatest_finish;
		else -- just remaining MAXs
			v_least_start_case1 := v_ltc_rmng_start;
			v_greatest_finish_case1 := v_ltc_rmng_finish;
		end if;

		log_pkg.steps('a',v_step_start,v_steps_result);

		--- Generate XLS

		xls_init();

		-- Header
		xls_new_row();

		xls_add_cell('Project');
		xls_add_cell('WBS Element / Trial Objective');
		xls_add_cell('Project Phase');
		xls_add_cell('GPDC Approved');
		xls_add_cell('Trial Number');
		xls_add_cell('Trial Phase');
		xls_add_cell('Start Date');
		xls_add_cell('Finish Date');
		xls_add_cell('Function');
		xls_add_cell('Cost Type');
		xls_add_cell('FTE Average');

		-- LT costs

		xls_add_cell('LTC Total') ;
		xls_add_cell('Remaining Estimate LTC Total');

		for v_val_row in (
			select year||' Remaining Estimate LTC' val
			from table(years(v_least_start_case1, v_greatest_finish_case1))
			order by year
		)
		loop
			xls_add_cell(v_val_row.val);
		end loop;

		log_pkg.steps('b',v_step_start,v_steps_result);
		--- Actual costs

		xls_add_cell('Actuals Total');
		xls_add_cell('Actual Start Date');
		xls_add_cell('Actual Finish Date');
		
		for v_val_row in (
			select year||' Actuals' val
			from table(years(v_act_start, v_act_finish))
			order by year
		) loop
			xls_add_cell(v_val_row.val);
		end loop;

		log_pkg.steps('c',v_step_start,v_steps_result);
		--- LTC comment

		xls_add_cell('LTC Comment');

		-- Forecast costs

		xls_add_cell('Remaining Estimate ProFIT Total');
		xls_add_cell('Remaining Estimate ProFIT Total Start Date');
		xls_add_cell('Remaining Estimate ProFIT Total Finish Date');

		for v_val_row in (
			select year||' Remaining Estimate ProFIT' val
			from table(years(v_fct_start, v_fct_finish))
			order by year
		) loop
			xls_add_cell(v_val_row.val);
		end loop;

		log_pkg.steps('d',v_step_start,v_steps_result);
		-- Actual costs monthly

		for v_val_row in (
			select to_char(start_date, 'MM-YYYY')||' Actuals' as val
			from table(months(v_act_start, v_act_finish))
			order by start_date
		) loop
			xls_add_cell(v_val_row.val);
		end loop;

		-- Forecast and LTC costs monthly

		for v_val_row in (
			select to_char(start_date, 'MM-YYYY') as val
			from table(months(v_least_start, v_greatest_finish))
			order by start_date
		) loop
			xls_add_cell(v_val_row.val||' Remaining Estimate ProFIT');
			xls_add_cell(v_val_row.val||' Remaining Estimate LTC');
		end loop;

		log_pkg.steps('e.top',v_step_start,v_steps_result);

		--------------------------------------------------------------------------
		-- WBS rows
		--------------------------------------------------------------------------
		for v_row in (
			select *
			from ltc_report_vw
			where timeline_id=p_timeline_id
			order by parent_wbs_id nulls first, wbs_id, wbs_start_date, phase_name, function_name, cost_type_name
		)
		loop
			--declare
			--	v_where2 nvarchar2(99):='ltc_report_pkg.generate.row';
			--	v_step_start2 timestamp:= systimestamp;
			--	v_steps_result2 nvarchar2(4000);
			--	v_procedure_start2 timestamp:= systimestamp;
			--begin
					--log_pkg.steps(null,v_step_start2,v_steps_result2);
					
			iii:=iii+1; --just for logging rows performance
			xls_new_row();

			xls_add_cell(v_row.project_name);
			xls_add_cell(v_row.wbs_name);
			xls_add_cell(v_row.phase_name);
			xls_add_cell(v_row.is_gpdc_approved_desc);
			xls_add_cell(nvl(v_row.study_id,v_row.root_study_id));--Trial number
			xls_add_cell(v_row.study_phase);--Trial Phase
			xls_add_cell(v_row.wbs_start_date);
			xls_add_cell(v_row.wbs_finish_date);
			xls_add_cell(v_row.function_name);
			xls_add_cell(v_row.cost_type_name);
			xls_add_cell(v_row.fte_avg);

			-- Yearly LTC remaining

			xls_add_cell(v_row.lt_cost); -- L -- LTC Total

			-- this IF could be also moved to the main SQL as decode
			-- M -- Remaining Estimate LTC Total
			if v_row.is_rmng_case1=1 then -- just simply take FPS/ProFIT values as it happens later (below) in the next rows.

				v_case1_style:='s74';--green number just for testing, for making sure if the Case1 happened
				xls_add_cell(v_row.fct_cost_fps,v_case1_style);

				for v_val_row in (
					select sum(fct_cost_fps) as val
					--from table(years(v_fct_start, v_fct_finish)) years
					from table(years(v_least_start_case1, v_greatest_finish_case1)) years
					left join ltc_imported_costs_excel_vw cst
						on extract(year from cst.start_date) = years.year
							and fct_cost_fps is not null
							and wbs_id = v_row.wbs_id and function_code=v_row.function_code and cost_type_code=v_row.cost_type_code
							and cst.start_date between v_row.fct_cost_fps_start_date and v_row.fct_cost_fps_finish_date
					group by years.year
					order by years.year
				) loop
					xls_add_cell(v_val_row.val,v_case1_style);
				end loop;

			else

				v_case1_style:='s63';-- usual number, no collors
				xls_add_cell(v_row.lt_cost_rmng);

				for v_val_row in (
					with
						ltcr as (
							select
								mm.start_date,
								decode(ltcrv.lt_cost_rmng_fct_ratio, null, ltcrv.lt_cost_rmng_mm, imp.fct_cost_fps_sum * ltcrv.lt_cost_rmng_fct_ratio) as lt_cost_rmng_mm
							from ltc_rmng_excel_vw ltcrv
							inner join calendar_month mm on mm.start_date between trunc(v_row.lt_cost_rmng_start_date, 'mm') and trunc(v_row.lt_cost_rmng_finish_date, 'mm')
							left join (
								select
									start_date as mm_start_date,
									sum(fct_cost_fps) as fct_cost_fps_sum
								from ltc_imported_costs_excel_vw
								where timeline_id=v_row.timeline_id
								and wbs_id = v_row.wbs_id
								and function_code=v_row.function_code
								and cost_type_code=v_row.cost_type_code
								group by
									timeline_id,
									wbs_id,
									function_code,
									cost_type_code,
									start_date
							) imp on (imp.mm_start_date=mm.start_date)
							where ltcrv.timeline_id=v_row.timeline_id
							and ltcrv.wbs_id = v_row.wbs_id
							and ltcrv.function_code=v_row.function_code
							and ltcrv.cost_type_code=v_row.cost_type_code
						)
					select sum(ltcr.lt_cost_rmng_mm) as val
					from table(years(v_least_start_case1, v_greatest_finish_case1)) years
					left join ltcr on extract(year from ltcr.start_date) = years.year
					group by years.year
					order by years.year
				) loop
					xls_add_cell(v_val_row.val);
				end loop;
			end if;

			--log_pkg.steps('a',v_step_start2,v_steps_result2);

			-- Yearly actual costs

			xls_add_cell(v_row.act_cost); -- Actuals Total
			xls_add_cell(v_row.act_cost_start_date);
			xls_add_cell(v_row.act_cost_finish_date);

			for v_val_row in (
				select sum(act_cost) as val
				from table(years(v_act_start, v_act_finish)) years
				left join ltc_imported_costs_excel_vw cst
					on extract(year from cst.start_date) = years.year
						and act_cost is not null
						and wbs_id = v_row.wbs_id and function_code=v_row.function_code and cost_type_code=v_row.cost_type_code
						and cst.start_date between v_row.act_cost_start_date and v_row.act_cost_finish_date
				group by years.year
				order by years.year
			) loop
				xls_add_cell(v_val_row.val);
			end loop;
			--log_pkg.steps('b',v_step_start2,v_steps_result2);
			xls_add_cell(v_row.lt_cost_comments);

			xls_add_cell(v_row.fct_cost_fps); -- Remaining Estimate (Functional Planning System)/ProFIT Total
			xls_add_cell(v_row.fct_cost_fps_start_date);
			xls_add_cell(v_row.fct_cost_fps_finish_date);

			for v_val_row in (
				select sum(fct_cost_fps) as val
				from table(years(v_fct_start, v_fct_finish)) years
				left join ltc_imported_costs_excel_vw cst
					on extract(year from cst.start_date) = years.year
						and fct_cost_fps is not null
						and wbs_id = v_row.wbs_id and function_code=v_row.function_code and cost_type_code=v_row.cost_type_code
						and cst.start_date between v_row.fct_cost_fps_start_date and v_row.fct_cost_fps_finish_date
				group by years.year
				order by years.year
			) loop
				xls_add_cell(v_val_row.val);
			end loop;
			--log_pkg.steps('c',v_step_start2,v_steps_result2);

			-- Monthly values (ACT, FCT, LTC).

			-- Since generating cells impacts performance let's try to generate only what's necessary and avoid
			-- empty cells at the end of the row.

			if v_row.act_cost_finish_date is null and v_row.fct_cost_fps_finish_date is null and v_row.lt_cost_rmng_finish_date is null then continue; end if;

			v_mm_finish := coalesce(v_row.act_cost_finish_date, v_row.fct_cost_fps_finish_date, v_row.lt_cost_rmng_finish_date);
			v_mm_finish := greatest(v_mm_finish, nvl(v_row.fct_cost_fps_finish_date, v_mm_finish));
			v_mm_finish := greatest(v_mm_finish, nvl(v_row.lt_cost_rmng_finish_date, v_mm_finish));


			for v_val_row in (
				select sum(act_cost) as val, mm.start_date
				from table(months(v_act_start, v_act_finish)) mm
				left join ltc_imported_costs_excel_vw cst
					on trunc(cst.start_date, 'MM') = trunc(mm.start_date, 'MM')
						and act_cost is not null
						and cst.timeline_id=v_row.timeline_id
						and cst.wbs_id = v_row.wbs_id and cst.function_code=v_row.function_code and cst.cost_type_code=v_row.cost_type_code
						and cst.start_date between v_row.act_cost_start_date and v_row.act_cost_finish_date
				group by mm.start_date
				order by mm.start_date
			) loop
				if v_val_row.start_date > v_mm_finish then continue; end if;

				xls_add_cell(v_val_row.val);
			end loop;
			--log_pkg.steps('d',v_step_start2,v_steps_result2);
			for v_val_row in (

				with
					cst as (
						select
								start_date,
								fct_cost_fps,
								decode(v_row.is_rmng_case1, 1, fct_cost_fps,lt_cost_rmng) lt_cost_rmng
						from (
							select
								start_date,
								sum(fct_cost_fps) as fct_cost_fps,
								sum(decode(lt_cost_rmng_fct_ratio, null, lt_cost_rmng_mm, fct_cost_fps * lt_cost_rmng_fct_ratio)) as lt_cost_rmng
							from (
								select
									start_date,
									fct_cost_fps,
									to_number(null) as lt_cost_rmng_mm,
									to_number(null) as lt_cost_rmng_fct_ratio
								from ltc_imported_costs_excel_vw cst
								where cst.fct_cost_fps is not null
									and cst.timeline_id=v_row.timeline_id
									and cst.wbs_id = v_row.wbs_id and cst.function_code=v_row.function_code and cst.cost_type_code=v_row.cost_type_code
									and cst.start_date between v_row.fct_cost_fps_start_date and v_row.fct_cost_fps_finish_date
								union all
								select
									mm.start_date,
									to_number(null),
									lt_cost_rmng_mm,
									lt_cost_rmng_fct_ratio
								from ltc_rmng_excel_vw ltcr
								cross join table(months(trunc(v_row.lt_cost_rmng_start_date, 'MM'), trunc(v_row.lt_cost_rmng_finish_date, 'MM'))) mm
								where timeline_id=v_row.timeline_id
									and wbs_id = v_row.wbs_id and function_code=v_row.function_code and cost_type_code=v_row.cost_type_code
									and mm.start_date between trunc(v_row.lt_cost_rmng_start_date, 'MM') and v_row.lt_cost_rmng_finish_date--PROMISIII-315 must be: mm, the first day of moth
							)
							group by start_date
						)
					)
				select fct_cost_fps as val1, lt_cost_rmng as val2, mm.start_date
				from table(months(v_least_start, v_greatest_finish)) mm
				left join cst on trunc(cst.start_date, 'MM') = trunc(mm.start_date, 'MM')
				order by mm.start_date
			) loop
				if v_val_row.start_date > v_mm_finish then continue; end if;

				xls_add_cell(v_val_row.val1);
				xls_add_cell(v_val_row.val2,v_case1_style);
			end loop;

				--log_pkg.steps(iii,v_step_start,suvstr(v_steps_result,1,4000));
				
				--log_pkg.steps('END',v_procedure_start2,v_steps_result2);
				--log_pkg.log(v_where2, 'p_timeline_id='||p_timeline_id||';wbs_id='||v_row.wbs_id||';function_code='||v_row.function_code||';cost_type_code='||v_row.cost_type_code
				--||';study_id='||nvl(v_row.study_id,v_row.root_study_id)||';study_phase='||v_row.study_phase||';phase_name='||v_row.phase_name, v_steps_result2);
			--end;
		end loop;

		log_pkg.steps('END',v_procedure_start,v_steps_result);
		log_pkg.log(v_where, 'p_timeline_id='||p_timeline_id, v_steps_result);

		return xls_to_lob();
	end;
end;
/