
  CREATE OR REPLACE FORCE VIEW "IPMS_DATA"."PRJ_REASON_CODES_VW" ("CODE", "NAME", "IS_ACTIVE", "DESCRIPTION", "REF_REASON_CODE", "D1", "D2", "PRD_MNT", "DEV") AS 
  WITH termReasonD1
     AS (SELECT termination_code,
                area_code
         FROM   termination_reason_area_code
         WHERE  area_code = 'D1'),
     termReasonD2
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
       tr.name,
       tr.is_active,
       tr.description,
       tr.ref_reason_code,
       Least(1,Count(trd1.termination_code))  AS D1,
       Least(1,Count(trd2.termination_code))  AS D2,
       Least(1,Count(trpm.termination_code))  AS PRD_MNT,
       Least(1,Count(trdev.termination_code)) AS Dev
FROM   termination_reason tr
       left join termReasonD1 trd1
              ON trd1.termination_code = tr.code
       left join termReasonD2 trd2
              ON trd2.termination_code = tr.code
       left join termReasonPRDMNT trpm
              ON trpm.termination_code = tr.code
       left join termReasondDEV trdev
              ON trdev.termination_code = tr.code
GROUP  BY tr.code,
          tr.name,
          tr.is_active,
          tr.description,
          tr.ref_reason_code;

  CREATE OR REPLACE TRIGGER "IPMS_DATA"."PRJ_REASON_CODES_VW_IOD_TR" 
  instead OF DELETE ON prj_reason_codes_vw
BEGIN
    DELETE FROM termination_reason
    WHERE  code = :OLD.code;
END;
/
ALTER TRIGGER "IPMS_DATA"."PRJ_REASON_CODES_VW_IOD_TR" ENABLE;

  CREATE OR REPLACE TRIGGER "IPMS_DATA"."PRJ_REASON_CODES_VW_IOU_TR" 
  instead OF UPDATE ON prj_reason_codes_vw
BEGIN
    IF updating THEN

      --Name--
      IF :OLD.Name != :NEW.Name THEN
         UPDATE TERMINATION_REASON set Name = :NEW.Name where code = :OLD.code;
      END IF;
      
      --Reference Code --      
      IF :OLD.REF_REASON_CODE != :NEW.REF_REASON_CODE then
         UPDATE TERMINATION_REASON set REF_REASON_CODE = :NEW.REF_REASON_CODE where code = :OLD.code;      
      end if;

      --Description --      
      IF :OLD.DESCRIPTION != :NEW.DESCRIPTION then
         UPDATE TERMINATION_REASON set DESCRIPTION = :NEW.DESCRIPTION where code = :OLD.code;      
      end if;

      --D1--  
      IF :OLD.d1 != :NEW.d1 THEN
        IF :NEW.d1 = 1 THEN
          INSERT INTO termination_reason_area_code
                      (area_code,termination_code)
          VALUES      ('D1',:NEW.code);
        END IF;

        IF :NEW.d1 = 0 THEN
          BEGIN
              DELETE FROM termination_reason_area_code
              WHERE  area_code = 'D1'
                     AND termination_code = :NEW.code;
          EXCEPTION
              WHEN no_data_found THEN
                NULL;
          END;
        END IF;
      END IF;
      
      --D2--  
      IF :OLD.d2 != :NEW.d2 THEN
        IF :NEW.d2 = 1 THEN
          INSERT INTO termination_reason_area_code
                      (area_code,termination_code)
          VALUES      ('D2-PRJ',:NEW.code);
        END IF;

        IF :NEW.d2 = 0 THEN
          BEGIN
              DELETE FROM termination_reason_area_code
              WHERE  area_code = 'D2-PRJ'
                     AND termination_code = :NEW.code;
          EXCEPTION
              WHEN no_data_found THEN
                NULL;
          END;
        END IF;
      END IF;

      --DEV--  
      IF :OLD.dev != :NEW.dev THEN
        IF :NEW.dev = 1 THEN
          INSERT INTO termination_reason_area_code
                      (area_code,termination_code)
          VALUES      ('PRE-POT',:NEW.code);

          INSERT INTO termination_reason_area_code
                      (area_code,termination_code)
          VALUES      ('POST-POT',:NEW.code);

        END IF;

        IF :NEW.dev = 0 THEN
          BEGIN
              DELETE FROM termination_reason_area_code
              WHERE  area_code in ('POST-POT', 'PRE-POT')
                     AND termination_code = :NEW.code;
          EXCEPTION
              WHEN no_data_found THEN
                NULL;
          END;
        END IF;
      END IF;
      
      --PRD-MNT--
      IF :OLD.prd_mnt != :NEW.prd_mnt THEN
        IF :NEW.prd_mnt = 1 THEN
          INSERT INTO termination_reason_area_code
                      (area_code,termination_code)
          VALUES      ('PRD-MNT',:NEW.code);
        END IF;

        IF :NEW.prd_mnt = 0 THEN
          BEGIN
              DELETE FROM termination_reason_area_code
              WHERE  area_code = 'PRD-MNT'
                     AND termination_code = :NEW.code;
          EXCEPTION
              WHEN no_data_found THEN
                NULL;
          END;
        END IF;
      END IF;
      
    END IF;
END; 
/
ALTER TRIGGER "IPMS_DATA"."PRJ_REASON_CODES_VW_IOU_TR" ENABLE;

  CREATE OR REPLACE TRIGGER "IPMS_DATA"."PRJ_REASON_CODES_VW_IOI_TR" 
  instead OF INSERT ON prj_reason_codes_vw
BEGIN
    IF inserting THEN
      INSERT INTO termination_reason
                  (code,name,is_active,description,ref_reason_code)
      VALUES      (:NEW.code,:NEW.name, nvl(:NEW.is_active,1), :NEW.description, :NEW.ref_reason_code);

      --D1--  
      IF :NEW.d1 = 1 THEN
        INSERT INTO termination_reason_area_code
                    (area_code,termination_code)
        VALUES      ('D1',:NEW.code);
      END IF;

      --D2--  
      IF :NEW.d2 = 1 THEN
        INSERT INTO termination_reason_area_code
                    (area_code,termination_code)
        VALUES      ('D2-PRJ',:NEW.code);
      END IF;

      --DEV--  
      IF :NEW.dev = 1 THEN
        INSERT INTO termination_reason_area_code
                    (area_code,termination_code)
        VALUES      ('PRE-POT',:NEW.code);

        INSERT INTO termination_reason_area_code
                    (area_code,termination_code)
        VALUES      ('POST-POT',:NEW.code);
      END IF;
      
      --PRD-MNT--
      IF :NEW.prd_mnt = 1 THEN
        INSERT INTO termination_reason_area_code
                    (area_code,termination_code)
        VALUES      ('PRD-MNT',:NEW.code);
      END IF;      
      
    END IF;
END;
/
ALTER TRIGGER "IPMS_DATA"."PRJ_REASON_CODES_VW_IOI_TR" ENABLE;
