create or replace view ltc_imp_costs_vw as
    select
        ltcprc.ltc_tag_id                                          ltc_tag_id,
        ltcprc.id                                                  ltc_process_id,
        prj.program_id                                             program_id,
        prg.name                                                   program_name,
        ltcp.project_id                                            project_id,
        prj.code                                                   project_code,
        prj.name                                                   project_name,
        ltcp.id                                                    ltc_project_id,
        cst.study_id                                               study_id,
        std.phase_code                                             study_phase_code,
        std.study_name,
        std.fpfv                                                   study_fpfv,
        std.lplv                                                   study_lplv,
        nvl(sfn.function_code, cst.function_code)                  function_code,
        fnc.name                                                   function_name,
        tfn.name                                                   top_function_name,
        decode(cst.scope_code || cst.subtype_code, 'EXTOEI', 1, 0) is_external_fte,
        cst.scope_code                                             scope_code,
        phs.code                                                   project_phase_code,
        phs.name                                                   project_phase_name,
        phs.ordering                                               project_phase_ordering,
        extract(year from cst.start_date)                          year,
        ltctag.start_year                                          ltc_start_year,
        cst.cost                                                   cost,
        std.timeline_id                                            timeline_id,
        std.wbs_id                                                 wbs_id,
        cst.subtype_code                                           subtype_code,
        cst.start_date                                             cost_start_date,
        cst.finish_date                                            cost_finish_date,
        ltcp.is_initially_prefiled                                 is_initially_prefiled
    from costs cst
        join ltc_project ltcp
            on ltcp.project_id = cst.project_id
        join project prj on prj.id = ltcp.project_id
        join program prg on prg.id = prj.program_id
        join ltc_process ltcprc on ltcprc.id = ltcp.ltc_process_id
        join ltc_tag ltctag on ltctag.id = ltcprc.ltc_tag_id
        left join subfunction sfn on (sfn.code = cst.subfunction_code)
        join function fnc
            on fnc.code = nvl(sfn.function_code, cst.function_code) and fnc.is_active=1
        join top_function tfn on tfn.code = fnc.top_function_code and top_function_code in ('1529', '1530', '1533', '1534', '1535', '1537')
        left join ltc_milestone_phase_vw mph on mph.timeline_id = ltcp.project_id || '-RAW' and
                                                cst.study_id is null and cst.start_date >= nvl(mph.start_date,to_date(ltctag.start_year||'-01-01','YYYY-MM-DD')) and
                                                nvl(cst.finish_date, cst.start_date) <=
                                                nvl(mph.finish_date, nvl(cst.finish_date, cst.start_date))
        left join study_data_vw std
            on std.project_id = cst.project_id and to_nchar(std.study_id) = cst.study_id and
               std.timeline_type_code = 'RAW'
        left join timeline_wbs_category wca
            on wca.timeline_id = std.timeline_id and wca.wbs_id = std.wbs_id
        left join milestone mls on mls.wbs_category = wca.category_name and mls.type_code='DEV' and mls.is_active = 1
        left join ltc_milestone_phase_mapping mpm on mpm.milestone_code = mls.code
        join phase phs on nvl(mph.phase_code, mpm.phase_code) = phs.code
    where cst.method_code = 'DET'
          and
          cst.scope_code || cst.subtype_code in ('EXTECG', 'EXTCRO', 'EXTOEC', 'EXTOEI', 'INT')
          and cst.type_code = 'FCT'
          and nvl(sfn.function_code, cst.function_code) is not null
          and nvl2(cst.study_id, wca.category_name, mph.phase_code) is not null;