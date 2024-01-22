create or replace view combase_project_name_vw as
select prj.pjx_no as code,prj.pjx_name as name,prj.modify_date
from bdo_project@combase_db prj
where prj.status = 'ACTIVE'
and prj.pjx_no in (select project_id from combase_project_vw);