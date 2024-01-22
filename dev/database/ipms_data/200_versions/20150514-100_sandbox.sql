
  CREATE TABLE "IPMS_DATA"."PROGRAM_SANDBOX" 
   ("ID" NVARCHAR2(10) NOT NULL ENABLE, 
	"PROGRAM_ID" NVARCHAR2(10) NOT NULL ENABLE, 
	"TIMELINE_ID" NVARCHAR2(20), 
	"CODE" NVARCHAR2(20), 
	"NAME" NVARCHAR2(100), 
	"DESCRIPTION" NVARCHAR2(500), 
	"IS_DATE_CONSTRAINTS" NUMBER(1,0) DEFAULT 1 NOT NULL ENABLE, 
	"CREATE_DATE" TIMESTAMP (6) DEFAULT sysdate NOT NULL ENABLE, 
	"UPDATE_DATE" TIMESTAMP (6), 
	"CREATE_USER_ID" NVARCHAR2(20) DEFAULT 'IPMS' NOT NULL ENABLE, 
	"UPDATE_USER_ID" NVARCHAR2(20), 
	"REFERENCE_ID" NVARCHAR2(20), 
	"SND_TIMELINE_ID" NVARCHAR2(20), 
	"SND_ID" NVARCHAR2(10), 
	 PRIMARY KEY ("ID"), 
	 CONSTRAINT "FK_SND_ID_ID" FOREIGN KEY ("SND_ID")
	  REFERENCES "IPMS_DATA"."PROGRAM_SANDBOX" ("ID") ENABLE
   );

   create sequence SANDBOX_ID_SEQ minvalue 1 maxvalue 999999999999999999 increment by 1 start with 1;

  CREATE UNIQUE INDEX "IPMS_DATA"."SND_UK1" ON "IPMS_DATA"."PROGRAM_SANDBOX" ("SND_TIMELINE_ID");

  CREATE OR REPLACE TRIGGER "IPMS_DATA"."PROGRAM_SANDBOX_ATR" 
	after insert or update or delete on program_sandbox
	for each row

	declare
		pragma autonomous_transaction;
	begin
		if inserting then
			log_pkg.log(program_pkg.get_subject(:new.id), program_pkg.get_summary(:new.id), 'Inserted.');
		end if;

		if updating then
			log_pkg.log(program_pkg.get_subject(:old.id), program_pkg.get_summary(:old.id), 'Updated.');
		end if;

		if deleting then
			log_pkg.log(program_pkg.get_subject(:old.id), program_pkg.get_summary(:old.id), 'Deleted.');
		end if;

		commit;
	end;
	/
	ALTER TRIGGER "IPMS_DATA"."PROGRAM_SANDBOX_ATR" ENABLE;

  CREATE OR REPLACE TRIGGER "IPMS_DATA"."PROGRAM_SANDBOX_TR" 
	before insert or update on program_sandbox
	for each row

	begin
		if inserting then
			if :new.id is null then
				select SANDBOX_ID_SEQ.nextval into :new.id from dual;
			end if;
		
			:new.create_user_id := user_pkg.get_current_user;
			:new.create_date := sysdate;
		end if;

		if updating then
			:new.update_date := sysdate;
			:new.update_user_id := user_pkg.get_current_user;
		end if;
	end;
	/
	ALTER TRIGGER "IPMS_DATA"."PROGRAM_SANDBOX_TR" ENABLE;
	
alter table ltc_instance add(sandbox_id nvarchar2(10) references program_sandbox(id) on delete cascade);