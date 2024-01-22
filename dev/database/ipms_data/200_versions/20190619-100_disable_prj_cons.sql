alter table PROJECT disable constraint PROJECT_REGULATORY_CODE_FK;
alter table PROJECT modify REGULATORY_CODE VARCHAR2(200);