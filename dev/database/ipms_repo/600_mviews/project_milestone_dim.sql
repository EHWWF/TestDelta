drop materialized view project_milestone_dim;

create materialized view project_milestone_dim as
select * from project_milestone_dim_vw;

grant select on project_milestone_dim to mycsd;