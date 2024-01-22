alter table ltc_estimate
    add (
    project_phase_name nvarchar2(100),
    study_phase_code nvarchar2(10),
    study_name nvarchar2(100),
    study_fpfv date,
    study_lplv date,
    top_function_name nvarchar2(100),
    function_name nvarchar2(100)
    );