create table study_vw_merge as select * from study_vw;
COMMENT ON TABLE study_vw_merge IS 'Can be used only in IMPORT_PKG and only for performance issues. Data is being refreshed before every data import using procedure: import_pkg.refresh_study_vw_merge.';
create unique index study_vw_merge_ui on study_vw_merge (timeline_id, wbs_id);