  CREATE OR REPLACE FORCE EDITIONABLE VIEW "IPMS_DATA"."PRJ_AUDIT_MILESTONES_SRC_VW" ("AUDIT_ID", "PRJ_ID", "PARENT_ID", "MS_TYPE_CODE", "MS_CODE", "MS_NAME", "MS_PLAN", "MS_ACHIEVED") AS 
  select
	audit_id,
	prj_id,
	parent_id,
	ms_type_code,
	extractvalue(ms_xml, '/MILESTONE/@CODE') ms_code,
	extractvalue(ms_xml, '/MILESTONE/@NAME') ms_name,
	extractvalue(ms_xml, '/MILESTONE/@PLAN') ms_plan,
	extractvalue(ms_xml, '/MILESTONE/@ACHIEVED') ms_achieved
from (
    select 'DEC' ms_type_code,
           pa.id audit_id,
           pa.project_id prj_id,
		   pa.parent_id,
           ms.column_value ms_xml
    from project_audit pa, xmltable('/PROJECT/DECISIONS/MILESTONE' passing pa.details) ms
            union all           -- Promis 604
    select 'DEC-SAMD' ms_type_code,         
           pa.id audit_id,
           pa.project_id prj_id,
		   pa.parent_id,
           ms.column_value ms_xml
    from project_audit pa, xmltable('/PROJECT/DECISIONS/MILESTONE' passing pa.details) ms
			union all
    select 'DEV',
           pa.id,
           pa.project_id,
		   pa.parent_id,
           ms.column_value
    from project_audit pa, xmltable('/PROJECT/DEVELOPMENT/MILESTONE' passing pa.details) ms
			union all
    select 'REG',
           pa.id,
           pa.project_id,
		   pa.parent_id,
           ms.column_value
    from project_audit pa, xmltable('/PROJECT/REGIONAL/MILESTONE' passing pa.details) ms
);


  GRANT SELECT ON "IPMS_DATA"."PRJ_AUDIT_MILESTONES_SRC_VW" TO "PMO_READ";
  GRANT SELECT ON "IPMS_DATA"."PRJ_AUDIT_MILESTONES_SRC_VW" TO "IPMS_REPO";
