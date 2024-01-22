  CREATE OR REPLACE FORCE VIEW "IPMS_DATA"."TERMINATION_REASONS4PRJAREA_VW" ("CODE", "REASON", "REASONSUBCATNAME", "AREA_CODE", "IS_ACTIVE") AS 
  WITH  termReasonD1
     AS (SELECT termination_code,
                area_code
         FROM   termination_reason_area_code
         WHERE  area_code = 'D1'),
      termreasond2
     AS (SELECT termination_code,
                area_code
         FROM   termination_reason_area_code
         WHERE  area_code = 'D2-PRJ'),
     termReasonPRDMNT
     AS (SELECT termination_code,
                area_code
         FROM   termination_reason_area_code
         WHERE  area_code = 'PRD-MNT'),
     termReasondDEV
     AS (SELECT termination_code,
                area_code
         FROM   termination_reason_area_code
         WHERE  area_code IN ( 'PRE-POT', 'POST-POT' ))         
SELECT tr.code,
       tre.name Reason,
       tr.name ReasonSubCatName,
       trd1.area_code,
       tr.is_active
FROM   termination_reason tr
    join termReasonD1 trd1   ON trd1.termination_code = tr.code
    left join termination_reason tre ON tre.code = tr.ref_reason_code
union all
SELECT tr.code,
       tre.name Reason,
       tr.name ReasonSubCatName,
       trd2.area_code,
       tr.is_active
FROM   termination_reason tr
    join termreasond2 trd2   ON trd2.termination_code = tr.code
    left join termination_reason tre ON tre.code = tr.ref_reason_code
union all
SELECT tr.code,
       tre.name Reason,
       tr.name ReasonSubCatName,
       trpm.area_code,
       tr.is_active
FROM   termination_reason tr
    join termReasonPRDMNT trpm   ON trpm.termination_code = tr.code
    left join termination_reason tre ON tre.code = tr.ref_reason_code    
union all
SELECT tr.code,
       tre.name Reason,
       tr.name ReasonSubCatName,
       trdev.area_code,
       tr.is_active
FROM   termination_reason tr
    join termReasondDEV trdev   ON trdev.termination_code = tr.code
    left join termination_reason tre ON tre.code = tr.ref_reason_code 
 order by area_code, Reason desc, ReasonSubCatName;