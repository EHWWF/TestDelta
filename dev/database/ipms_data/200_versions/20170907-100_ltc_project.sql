alter table ltc_project add is_initially_prefiled number default 0 constraint ltc_project_is_refiled_cc not null;
comment on column ltc_project.is_initially_prefiled is 'Column is being set to true=1 after initial prefill is done. It is especially important when updating process by adding new projects.';