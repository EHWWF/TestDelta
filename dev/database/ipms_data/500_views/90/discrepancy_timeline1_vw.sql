create or replace force view discrepancy_timeline1_vw as
		with t_type as (
				select
					tt.code,
					prj.code prj_code,
					tt.name  timeline_name,
					t.id     timeline_id,
					t.reference_id
				from timeline_type tt
					join timeline t on (tt.code = t.type_code)
					join project prj on (prj.id = t.project_id)
				where tt.is_active = 1
		)
		-- 1/2, two cases for one SELECT, if (dis.p6_cnt=1) means that study exists in P6 but is missing in SOPHIA
		select
			decode(dis.timeline_type_code, 'RAW', decode(dis.sophia_cnt, 1, 'ERROR', 'WARNING'), 'WARNING') dis_type_code,
			--ERROR only when missing for RAW in Sophia
			decode(dis.timeline_type_code, 'RAW', decode(dis.sophia_cnt, 1, 'YES', 'NO'), 'NO') as          is_import_study,
			--the flag that shows if study can be imported
			decode(dis.sophia_cnt, 1, 'DIS-01', 'DIS-02')                                                   dis_code,
			--when missing in Sophia then DIS-01
			decode(dis.sophia_cnt, 1,
						 decode(dis.timeline_type_code, 'RAW',
										'Studies exist in IMPACT/SOPHIA, but not in the Raw plan. Studies need to be added in the Raw plan for timeline import.',
										'Studies exist in IMPACT/SOPHIA, but not in the ' || dis.timeline_name || ' plan.'),
						 'Studies exist in the Raw plan, but not in IMPACT/SOPHIA.')                              description,
			decode(dis.sophia_cnt, 1, 'IMPACT/SOPHIA', 'Primavera') || ' : Study (' ||
			nvl(dis.study_id, 'Missing study_id,code=' || dis.study_code || ',wbs_id=' || dis.wbs_id) || ')' ||
			decode(placeh.placeholder, 1, ' exists in Plan but as a Placeholder.', null)        as          verbose,
			decode(dis.sophia_cnt, 1,
						 decode(dis.timeline_type_code, 'RAW', 'Import Studies into the Raw plan.',
										'CUR', 'Import Studies into the Raw plan. Publish Raw plan as Current plan.',
										'Import Studies into the Raw plan. Publish Raw plan as Current plan. Publish Current plan as Approved plan.'),
						 decode(dis.timeline_type_code, 'RAW', 'Add studies to IMPACT/SOPHIA or remove studies from the Raw plan.',
										'CUR',
										'Add studies to IMPACT/SOPHIA or remove studies from the Raw plan. Publish Raw plan as Current plan.',
										'Add studies to IMPACT/SOPHIA or remove studies from the Raw plan. Publish Raw plan as Current plan. Publish Current plan as Approved plan.')
			)                                                                                               solution,
			--'Import Studies into the Raw plan.' solution2,
			dis.project_id,
			dis.study_id,
			null                                                                                as          study_element_id,
			dis.timeline_id,
			dis.reference_id,
			null                                                                                as          integration_type,
			null                                                                                            actual_finish,
			null                                                                                            actual_start,
			null                                                                                            plan_finish,
			null                                                                                            plan_start,
			dis.timeline_type_code                                                              as          timeline_code,
			dis.timeline_name,
			st.study_modus_name,
			st.clin_plan_type,
			'YES'                                                                                           use_in_planning,
			dis.fpfv_date,
			dis.sophia_cnt,
			dis.p6_cnt
		from (
					 select
						 max(decode(p6, 2, wbs_id))     wbs_id,
						 timeline_id,
						 max(decode(p6, 2, study_code)) study_code,
						 reference_id,
						 project_id,
						 --sys_project_id,
						 study_id,
						 timeline_type_code,
						 timeline_name,
						 count(sophia)                  sophia_cnt,
						 count(p6)                      p6_cnt,
						 max(fpfv_date)                 fpfv_date
					 from (
						 select distinct *
						 from (
							 select
								 ttt.timeline_id         as timeline_id,
								 ttt.reference_id,
								 1                          sophia,
								 to_number(null)            p6,
								 to_nchar(tl.project_id) as project_id,
								 --null as sys_project_id,
								 to_char(tl.study_id)    as study_id,
								 ttt.code                as timeline_type_code,
								 ttt.timeline_name,
								 null                    as study_code,
								 null                    as wbs_id,
								 max(case when nvl(cfg.value,-1) = nvl(tl.study_element_id,-1)
									 then nvl(nvl(nvl(tl.act_start_date, tl.plan_start_date), tl.act_finish_date), tl.plan_finish_date)
										 else null end  )            fpfv_date
							 from dis_study_mview tl
								 join t_type ttt on (ttt.prj_code = to_nchar(tl.project_id))
								 join configuration cfg on cfg.code = 'FPFV'
							 group by timeline_id,reference_id,project_id,tl.study_id,ttt.code,ttt.timeline_name
						 )
						 union all
						 select distinct *
						 from (
							 select
								 twbs.timeline_id,
								 t.reference_id,
								 to_number(null) sophia,
								 2               p6,
								 prj.code  as    project_id,
								 --prj.id as sys_project_id,
								 twbs.study_id,
								 twbs.timeline_type_code,
								 tt.name   as    timeline_name,
								 twbs.code as    study_code,
								 twbs.wbs_id,
								 null            fpfv_date
							 from timeline_wbs twbs
								 join timeline t on (t.id = twbs.timeline_id)
								 join project prj on (twbs.project_id = prj.id)
								 join timeline_type tt on (tt.code = twbs.timeline_type_code)
								 left join timeline_activity tact
									 on (twbs.wbs_id = tact.parent_wbs_id and twbs.timeline_id = tact.timeline_id)
							 --SOPHIA has only NUMBER Project_Id so only number CODEs joind with ProMIS
							 where regexp_like(prj.code, '^[[:digit:]]+$')
						 )
					 )
					 group by
						 timeline_id,
						 reference_id,
						 project_id,
						 --sys_project_id,
						 study_id,
						 timeline_type_code,
						 timeline_name
					 having count(sophia) <> count(p6)
				 ) dis
			left join (select
									 st.study_id                   as id,
									 to_nchar(st.study_modus_name) as study_modus_name,
									 to_nchar(st.clin_plan_type)   as clin_plan_type,
									 st.project_id
								 from sophia_study_vw st
								) st on (st.id = nvl(dis.study_id, '###') and st.project_id = dis.project_id)
			left join timeline_wbs placeh
				on (placeh.timeline_id = dis.timeline_id and placeh.study_id = dis.study_id and placeh.placeholder = 1 and
						dis.sophia_cnt = 1) --PROMIS-556 inform about Placeholders
		where decode(dis.timeline_type_code, 'RAW', decode(dis.sophia_cnt, 1, 'YES', 'NO'), 'NO') = 'YES';