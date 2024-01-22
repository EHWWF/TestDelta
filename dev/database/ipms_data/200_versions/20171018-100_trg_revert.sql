alter table project modify constraint project_trg_fk disable;
--update project set trg=(select name from therapeutic_research_group where code=trg) where trg is not null;
--commit;