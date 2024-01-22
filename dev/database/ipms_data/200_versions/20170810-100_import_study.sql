alter table import_study add (budget_class nvarchar2(4));
comment on column import_study.budget_class is 'Data is being taken from the view: combase_study_vw and decoded from: MASTERDATA.BDO_LABEL.BT_NO by following rule: 0128=ED,0129=LD';
alter table study add (budget_class nvarchar2(4));
comment on column study.budget_class is 'Data is being taken (during nightly import) from the view: combase_study_vw and decoded from: MASTERDATA.BDO_LABEL.BT_NO by following rule: 0128=ED,0129=LD';
