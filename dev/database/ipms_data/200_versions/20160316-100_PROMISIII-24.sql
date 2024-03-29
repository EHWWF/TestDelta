alter table lead_study_map add (status nvarchar2(100));
alter table lead_study_instance add(status_code nvarchar2(15) default 'NEW' not null references import_status(code));
alter table lead_study_instance add(notify_id nvarchar2(50) not null);
alter table lead_studies add(is_lead number(1) default 0);
alter table lead_study_instance add(details sys.xmltype);
alter table lead_study_config add (relationship_type nvarchar2(50) check(relationship_type in ('Start to Finish','Start to Start')));
alter table lead_study_map rename column status to status_code;
alter table lead_study_instance drop (is_syncing);
alter table study add(is_lead number(1) default 0 not null);
alter table lead_study_map add(error_code nvarchar2(100));
alter table lead_study_map add constraint lsm_pk primary key (lsi_id,dev_mlstn_code);