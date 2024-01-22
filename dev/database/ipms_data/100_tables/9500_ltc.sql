CREATE TABLE ltc_instance
  ( id NUMBER NOT NULL PRIMARY KEY,
    project_id NVARCHAR2(20) REFERENCES Project(id) ON DELETE CASCADE,
    status_code NVARCHAR2(10) DEFAULT 'NEW' NOT NULL REFERENCES Import_Status(code),
    create_date DATE DEFAULT sysdate NOT NULL,
    create_user_id NVARCHAR2(20) DEFAULT 'IPMS' NOT NULL,
    is_syncing NUMBER(1) DEFAULT 0 NOT NULL CHECK(is_syncing IN (1,0))
  );

CREATE sequence ltci_id_seq minvalue 1 maxvalue 999999999999999999 increment BY 1 start with 1;

CREATE TABLE ltc_plan
  ( id NUMBER NOT NULL PRIMARY KEY,
    ltci_id NUMBER NOT NULL REFERENCES ltc_instance(id) ON DELETE CASCADE,
    project_id NVARCHAR2(20) NOT NULL REFERENCES Project(id) ON DELETE CASCADE,
    wbs_id NVARCHAR2(20),
    parent_wbs_id NVARCHAR2(20),
    code NVARCHAR2(20),
    name NVARCHAR2(100),
    create_date DATE DEFAULT sysdate NOT NULL
  );
  
CREATE INDEX ltc_plan_idx1 ON ltc_plan (project_id);
  
CREATE sequence ltcp_id_seq minvalue 1 maxvalue 999999999999999999 increment BY 1 start with 1;

CREATE TABLE ltc_value
  ( id NUMBER NOT NULL PRIMARY KEY,
    ltcp_id NUMBER NOT NULL REFERENCES ltc_plan(id) ON DELETE CASCADE,
    function_code NVARCHAR2(15) NOT NULL REFERENCES FUNCTION(code),
    lt_int_cost NUMBER(20,10),
    lt_cro_cost NUMBER(20,10),
    lt_ecg_cost NUMBER(20,10),
    lt_oec_cost NUMBER(20,10),
    fc_int_cost NUMBER(20,10),
    fc_cro_cost NUMBER(20,10),
    fc_ecg_cost NUMBER(20,10),
    fc_oec_cost NUMBER(20,10)
  );
CREATE sequence ltcv_id_seq minvalue 1 maxvalue 999999999999999999 increment BY 1 start with 1;