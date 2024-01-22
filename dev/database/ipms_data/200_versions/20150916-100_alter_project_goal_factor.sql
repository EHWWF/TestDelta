alter table project_goal_factor DROP column "PROJECT_ID";
alter table project_goal_factor add "ID" NVARCHAR2(20) NOT NULL PRIMARY KEY;
alter table project_goal_factor add "PROJECT_ID" NVARCHAR2(20) NOT NULL;
alter table project_goal_factor MODIFY "MILESTONE_CODE" NVARCHAR2(20) NOT NULL;

alter table project_goal_factor add "CREATE_DATE" DATE DEFAULT sysdate NOT NULL; 
alter table project_goal_factor add "UPDATE_DATE" DATE;
alter table project_goal_factor add "CREATE_USER_ID" NVARCHAR2(20) DEFAULT 'IPMS' NOT NULL; 
alter table project_goal_factor add "UPDATE_USER_ID" NVARCHAR2(20); 

CREATE SEQUENCE PRJ_GOAL_FACTOR_SEQ  MINVALUE 1 MAXVALUE 999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20;