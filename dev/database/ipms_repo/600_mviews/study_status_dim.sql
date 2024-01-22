drop materialized view study_status_dim;

create materialized view study_status_dim as
select 1 study_status_id, 'RUN' study_status_code, 'Running' study_status_name from dual
union all 
select 2, 'COMM', 'Committed' from dual
union all 
select 3, 'PLAN', 'Planned' from dual
union all 
select 4, 'OEI', 'Other External Cost Insourced' from dual
union all 
select 5, 'OEC', 'Other External Cost' from dual;

grant select on study_status_dim to mycsd;