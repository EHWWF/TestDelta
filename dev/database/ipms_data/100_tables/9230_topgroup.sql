CREATE TABLE "IPMS_DATA"."TOPGROUP" 
("CODE" NVARCHAR2(20) NOT NULL ENABLE, 
"NAME" NVARCHAR2(200) NOT NULL ENABLE, 
"IS_ACTIVE" number(1,0), 
"MODIFY_DATE" date default sysdate, 
CONSTRAINT "TOPGROUP_PK" PRIMARY KEY ("CODE"));