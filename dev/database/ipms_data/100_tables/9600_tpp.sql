CREATE SEQUENCE tpp_id_seq MINVALUE 1 MAXVALUE 999999999999999999 INCREMENT BY 1 START WITH 1;
CREATE SEQUENCE tpp_values_id_seq MINVALUE 1 MAXVALUE 999999999999999999 INCREMENT BY 1 START WITH 1;

CREATE TABLE target_product_profile
  ( id NVARCHAR2(20) not null primary key,
    name NVARCHAR2(200),
    project_id NVARCHAR2(20) REFERENCES project(id) ON DELETE CASCADE,
    version NVARCHAR2(200) DEFAULT 'Current' NOT NULL,
    description NVARCHAR2(500),
    indication NVARCHAR2(2000),
    references NVARCHAR2(2000),
    approval_date DATE,
    create_user_id NVARCHAR2(20) DEFAULT 'IPMS' NOT NULL,
    update_user_id NVARCHAR2(20),
    create_date DATE DEFAULT sysdate NOT NULL,
    update_date DATE
  );

CREATE TABLE tpp_category
  ( code NVARCHAR2(20) NOT NULL PRIMARY KEY, 
    name NVARCHAR2(200) NOT NULL, 
    description NVARCHAR2(500),
    is_active number(1) default 1 not null check(is_active in (0,1)),
    modify_date DATE DEFAULT sysdate NOT NULL);

CREATE TABLE tpp_subcategory
  ( code NVARCHAR2(20) NOT NULL PRIMARY KEY, 
    name NVARCHAR2(200) NOT NULL, 
    description NVARCHAR2(500),
    category_code nvarchar2(20) not null references tpp_category(code),
    is_active number(1) default 1 not null check(is_active in (0,1)),
    modify_date DATE DEFAULT sysdate NOT NULL);

CREATE TABLE tpp_values
  ( id nvarchar2(20) not null primary key,
    tpp_id NVARCHAR2(20) REFERENCES target_product_profile(id),
    subcategory_code nvarchar2(20) not null references tpp_subcategory(code),
    key_edv_proposition NVARCHAR2(200), 
    standard_of_care NVARCHAR2(200), 
    targeted_profile NVARCHAR2(200), 
    upside NVARCHAR2(200), 
    targeted_in NVARCHAR2(200), 
    key_driver number(1) default 0 not null check(key_driver in (0,1)),
    unique_selling_point number(1) default 0 not null check(unique_selling_point in (0,1)),
    create_user_id NVARCHAR2(20) DEFAULT 'IPMS' NOT NULL,
    update_user_id NVARCHAR2(20),
    create_date DATE DEFAULT sysdate NOT NULL,
    update_date DATE
  );

create index tpp_values_idx1 on tpp_values(tpp_id);
create index tpp_values_idx2 on tpp_values(subcategory_code);