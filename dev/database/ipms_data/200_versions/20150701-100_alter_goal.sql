alter table goal drop CONSTRAINT "GOAL_PHASE";
alter table goal add CONSTRAINT "GOAL_PHASE" CHECK (phase in ('S', 'T'));
alter table goal add ref_date_type nvarchar2(1);
alter table goal add CONSTRAINT "GOAL_REF_DATE_TYPE" CHECK (ref_date_type in ('A', 'P'));