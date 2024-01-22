create or replace package import_d1_pkg as

	--the main procedure that does all steps:
	--1. merge=sync data
	--2. update imported projects
	--3. import missing/marked projects
	procedure start_d1_import;
	--Update only D2 projects only for 5 fields
	--D2 Compound (only D2)
	--Therapeutic Research Group (TRG)
	--Target Gene Code (available for D1)
	--Exploratory Research (ER)
	--General Project Frame
	procedure update_d2_fields;

	--procedure that does simple data synch from external to internal table
	procedure merge_into_import_d1(p_import_id in nvarchar2);

	--update existing projects and import READY
	procedure loop_for_all_updated_d1(p_import_id in nvarchar2);

end;
/
create or replace package body import_d1_pkg as

	/*************************************************************************/
	procedure update_trg as
	begin
		merge into therapeutic_research_group dest
		using (
			select
				trg_code,
				max(decode(seq, 1, trg)) trg,
				sum(decode (seq, 1, srccnt, dstcnt)) iud
			from (
				select
					trg_code,
					trg,
					srccnt,
					dstcnt,
					row_number () over (partition by trg_code order by dstcnt nulls last) seq
				from (
					select
						trg_code,
						trg,
						count (src) srccnt,
						count (dst) dstcnt
					from (
						select
							code as trg_code,
							name as trg,
							to_number(null) src,2 dst
						from therapeutic_research_group
							union all
						select
							trg_code,
							trg,
							1 src,to_number(null) dst
						from import_d1 
						where trg_code is not null 
						group by trg_code,trg
					)
					group by
							trg_code,
							trg
					having count (src) <> count (dst)
				)
			)
			group by trg_code
		) diff
		ON (dest.code = diff.trg_code)
		WHEN MATCHED
		THEN
			 UPDATE SET
				dest.name = diff.trg
				,dest.update_date = sysdate
			 --DELETE WHERE (diff.iud = 0)
		WHEN NOT MATCHED
		then
			 insert (code,name,create_date,update_date)
			 values (diff.trg_code,diff.trg,sysdate,sysdate);
	end;

	/*************************************************************************/
	procedure start_d1_import as
		v_id import.id%type;
	begin
		insert into import(
			type_mask,
			source,
			is_manual
		)
		values(
			1024,
			'CMBS', --COMBASE
			0
		)
		returning id into v_id;

		-- Commented out to avoid loosing guid for BA logging
		--commit;

		import_d1_pkg.merge_into_import_d1(v_id);
		import_d1_pkg.loop_for_all_updated_d1(v_id);

	end;

	/*************************************************************************/
	procedure loop_for_all_updated_d1(p_import_id in nvarchar2) as
		v_phase_code nvarchar2(20);
		v_status_code nvarchar2(20);
		v_status_desc nvarchar2(50);
		v_prj_id nvarchar2(20);
		v_sqlerrm nvarchar2(4000);
		v_program_id nvarchar2(20);
		v_ordering number;
	begin
		select id into v_program_id from program where code='RESERVED-PT-D1';

		for rr in (
					select prj.area_code, prj.code,prj.id, d1.*
					from import_d1 d1
					left join project prj on (to_char(d1.project_id)=prj.code and prj.area_code='D1')-- we are updating only D1
					where d1.import_id=p_import_id
					or status_code='READY' -- marked by user to import
					-- and d1.project_id='477500'
						)
		loop
			if rr.status_code='READY' or rr.id is not null then --take only READY or already imported
				begin
					begin
						select code into v_phase_code from phase
						where replace(upper(name),' ')=replace(upper(rr.project_phase),' ');
					exception when no_data_found then
						select max(ordering)+10 into v_ordering from phase;
						insert into phase (code,name,is_active,ordering)
						values ('D1.'||rr.project_phase_no,rr.project_phase,1,v_ordering) returning code into v_phase_code;
					end;

					if rr.status_code='READY' and rr.id is null then

						insert into project 
							(
								code,
								name,
								program_id,
								is_active,
								area_code,
								phase_code,
								trg,
								er,
								target_gene_code,
								d2_compound,
								start_hts_date,
								general_project_frame
							)
						values
							(
								rr.project_id,
								rr.project_name,
								v_program_id,
								1,
								'D1',
								v_phase_code,
								--rr.trg_code,
								rr.trg,
								rr.er,
								rr.target_gene_code,
								rr.d2_compound,
								rr.start_hts_date,
								rr.general_project_frame
							)
						returning id into v_prj_id;

						if v_prj_id is not null then
							v_status_code:='DONE';
							v_status_desc:='Inserted.';
						else
							v_status_code:='ERROR';
							v_status_desc:='Error,no rows inserted.';
						end if;

					elsif rr.id is not null and rr.area_code='D1' then
						update project set
							name=rr.project_name,
							phase_code=v_phase_code,
							--trg=rr.trg_code,
							trg=rr.trg,
							er=rr.er,
							target_gene_code=rr.target_gene_code,
							d2_compound=rr.d2_compound,
							start_hts_date=rr.start_hts_date,
							general_project_frame=rr.general_project_frame,
							update_date=sysdate
						--where code=rr.project_id;
						where id=rr.id and code=rr.project_id
						returning id into v_prj_id;

						if v_prj_id is not null then
							v_status_code:='DONE';
							v_status_desc:='Updated.';
						else
							v_status_code:='ERROR';
							v_status_desc:='Error,no rows updated.';
						end if;
					else
						v_status_code:='ERROR';
						v_status_desc:='Error.';
					end if;

					v_prj_id:=null;

					update import_d1 set
						status_code=v_status_code ,
						status_description=v_status_desc,
						update_date=sysdate
					where project_id=rr.project_id;

				exception when others then
					v_sqlerrm:=substr(sqlerrm,1,500);
					update import_d1 set
						status_code='ERROR' ,
						status_description=v_sqlerrm,
						update_date=sysdate
					where project_id=rr.project_id;
			end;
			end if;
		end loop;

	end;

	/*************************************************************************/
	procedure merge_into_import_d1(p_import_id in nvarchar2) as
		v_rowcount number;
		v_timestamp_log import.timestamp_log%type;
		v_sqlerrm nvarchar2(4000);
	begin

		merge into import_d1 dest
		using (
			select
				project_id,
				max(decode(seq, 1, project_name)) project_name,
				max(decode(seq, 1, project_phase_no)) project_phase_no,
				max(decode(seq, 1, project_phase)) project_phase,
				max(decode(seq, 1, trg_code)) trg_code,
				max(decode(seq, 1, trg)) trg,
				max(decode(seq, 1, er)) er,
				max(decode(seq, 1, target_gene_code)) target_gene_code,
				max(decode(seq, 1, d2_compound)) d2_compound,
				max(decode(seq, 1, start_hts_date)) start_hts_date,
				--max(decode(seq, 1, general_project_frame)) general_project_frame,
				max(decode(seq, 1, status)) status,
				max(decode(seq, 1, modifier)) modifier,
				max(decode(seq, 1, modify_date)) modify_date,
				max(decode(seq, 1, isnew)) isnew,
				sum(decode (seq, 1, srccnt, dstcnt)) iud
			from (
				select
					project_id,
					project_name,
					project_phase_no,
					project_phase,
					trg_code,
					trg,
					er,
					target_gene_code,
					d2_compound,
					start_hts_date,
					--general_project_frame,
					status,
					modifier,
					modify_date,
					isnew,
					srccnt,
					dstcnt,
					row_number () over (partition by project_id order by dstcnt nulls last) seq
				from (
					select
						project_id,
						project_name,
						project_phase_no,
						project_phase,
						trg_code,
						trg,
						er,
						target_gene_code,
						d2_compound,
						start_hts_date,
						--general_project_frame,
						status,
						modifier,
						modify_date,
						isnew,
						count (src) srccnt,
						count (dst) dstcnt
					from (
						select
							project_id,
							project_name,
							project_phase_no,
							project_phase,
							trg_code,
							trg,
							er,
							target_gene_code,
							d2_compound,
							trunc(start_hts_date) start_hts_date,
							--general_project_frame,
							status,
							modifier,
							modify_date,
							isnew
							,to_number(null) src
							,2 dst
						from import_d1
						union all
						select
							project_no project_id,
							to_nchar(project_name),
							project_phase_no,
							to_nchar(project_phase_name),
							to_nchar(trg_code),
							to_nchar(trg),
							to_nchar(er),
							to_nchar(target_gene_code),
							to_nchar(d2_compound),
							trunc(start_hts_date) start_hts_date,
							--to_nchar(general_project_frame),
							to_nchar(null) status, --to_nchar(status),
							to_nchar(null) modifier,--to_nchar(modifier),
							to_date(null) modify_date,--modify_date,
							to_nchar(1) isnew,--to_nchar(isnew)
							1 src
							,to_number(null) dst
						from pix_project_attributes@sophia_db
						--where status='ACTIVE'
					)
					group by
							project_id,
							project_name,
							project_phase_no,
							project_phase,
							trg_code,
							trg,
							er,
							target_gene_code,
							d2_compound,
							start_hts_date,
							--general_project_frame,
							status,
							modifier,
							modify_date,
							isnew
					having count (src) <> count (dst)
				)
			)
			group by project_id
		) diff
		ON (dest.project_id = diff.project_id)
		WHEN MATCHED
		THEN
			 UPDATE SET
				import_id = p_import_id
				,dest.project_name = diff.project_name
				,dest.project_phase_no = diff.project_phase_no
				,dest.project_phase = diff.project_phase
				,dest.trg_code = diff.trg_code
				,dest.trg = diff.trg
				,dest.er = diff.er
				,dest.target_gene_code = diff.target_gene_code
				,dest.d2_compound = diff.d2_compound
				,dest.start_hts_date = diff.start_hts_date
				--,dest.general_project_frame = diff.general_project_frame
				,dest.status = diff.status
				,dest.modifier = diff.modifier
				,dest.modify_date = diff.modify_date
				,dest.isnew = diff.isnew
				,dest.status_code = 'UPDATED'
				--,dest.status_description =
				,dest.update_date = sysdate
			 DELETE
					WHERE (diff.iud = 0)
		WHEN NOT MATCHED
		THEN
			 insert (import_id,project_id,project_name,project_phase_no,project_phase,trg_code,trg,er,target_gene_code,
						d2_compound,start_hts_date,status,modifier,modify_date,isnew,status_code,
						status_description,create_date)
			 values (p_import_id,diff.project_id,diff.project_name,diff.project_phase_no,diff.project_phase,diff.trg_code,diff.trg,diff.er,diff.target_gene_code,
			 diff.d2_compound,diff.start_hts_date,diff.status,diff.modifier,diff.modify_date,diff.isnew,'NEW',
			 null,sysdate);

		v_rowcount:=sql%rowcount;
		v_timestamp_log := 'p_import_id='||p_import_id||';v_rowcount='||v_rowcount;

		update_trg;

		update import set
			timestamp_log = v_timestamp_log,
			status_code = 'DONE',
			update_date = sysdate
		where id = p_import_id;

		log_pkg.log('import_d1_pkg.merge_into_import_d1',v_timestamp_log,'Updated.');

	exception when others then
		v_sqlerrm:=substr(sqlerrm,1,4000);
		log_pkg.log('import_d1_pkg.merge_into_import_d1', nvl(v_timestamp_log,'p_import_id='||p_import_id||';v_rowcount='||v_rowcount), v_sqlerrm);

		update import set
			timestamp_log = substr(v_timestamp_log||v_sqlerrm,1,4000),
			status_code = 'ERROR',
			update_date = sysdate
		where id = p_import_id;

	end;

	/*************************************************************************/
	procedure update_d2_fields as
		v_where nvarchar2(99):='import_d1_pkg.update_d2_fields';
		v_count pls_integer:=0;
	begin
		for rr in (
					select
						prj.id,
						prj.d2_compound,
						d2.d2_compound d2_compound_d2,
						prj.trg,
						--d2.trg_code trg_d2,
						d2.trg trg_d2,
						prj.target_gene_code,
						d2.target_gene_code target_gene_code_d2,
						prj.er,
						d2.er er_d2,
						prj.general_project_frame,
						d2.general_project_frame general_project_frame_d2
					from project prj
					join pix_project_attributes@sophia_db d2 on (to_nchar(d2.project_no)=prj.code and prj.area_code='D2-PRJ')-- and d2.status='ACTIVE')-- we are updating only D2
					where
						nvl(prj.d2_compound,'###')<>nvl(d2.d2_compound,'###')
					or
						--nvl(prj.trg,'###')<> nvl(d2.trg_code,'###')
						nvl(prj.trg,'###')<> nvl(d2.trg,'###')
					or
						nvl(prj.target_gene_code,'###')<> nvl(d2.target_gene_code,'###')
					or
						nvl(prj.er,'###')<> nvl(d2.er,'###')
					or
						nvl(prj.general_project_frame,'###')<> nvl(d2.general_project_frame,'###')
					)
		loop
			begin
				update project set
					d2_compound = rr.d2_compound_d2,
					trg = rr.trg_d2,
					target_gene_code = rr.target_gene_code_d2,
					er = rr.er_d2,
					general_project_frame = rr.general_project_frame_d2,
					update_date = sysdate
				where id=rr.id
				and area_code='D2-PRJ';--just in case

				v_count:=v_count+1;
			exception when others then
				log_pkg.log(v_where, 'OTHERS.LOOP.prj.id='||rr.id,sqlerrm);
			end;
		end loop;

		log_pkg.log(v_where, 'loop count',v_count);

	exception when others then
		log_pkg.log(v_where, 'OTHERS.',sqlerrm);
	end;


end;
/