create or replace TRIGGER IPMS_DATA.PROJECT_TR 
for insert or update or delete on project
compound trigger
before each row is
begin
	if inserting then
		if :new.id is null then
			select :new.program_id||'-'||project_id_seq.nextval into :new.id from dual;
		end if;
		:new.create_date := sysdate;
		:new.create_user_id := nvl(:new.create_user_id,'TRIGGER');
		if :new.phase_code is null then :new.phase_code := '9'; end if;
	end if;
	if inserting or updating then
		select decode(:new.details_progress, :old.details_progress, :old.progress_date, sysdate)
		into :new.progress_date
		from dual
		;
		if :new.area_code = 'D1' then--PROMIS-747
			if :new.is_active = 1 then
				:new.state_code:='1';--=Going
			elsif :new.is_active = 0 and :new.termination_date is not null then--BAY_PROMIS-115
				:new.state_code := '5'; --5=Terminated
			else
				:new.state_code:= null;
			end if;
		end if;
	if inserting or updating then     
        if :old.area_code in('SAMD') then
            select decode(:new.details_risks, :old.details_risks, :old.progress_date, sysdate)--PROMIS 604
            into :new.progress_date
            from dual;
		end if;  
    end if;
		if :new.area_code in ('PRD-MNT','RS','LG','LO','D3-TR','CO','D1') and :new.pidt_release_date is null then
		--jira:PROMIS-68
		--jira:PROMIS-442
			:new.pidt_release_date:=sysdate;
		end if;
	end if;
	if updating then
		:new.update_date := sysdate;
		:new.update_user_id := nvl(:new.update_user_id,'TRIGGER');
		if :new.state_code <> '5' then --5=Terminated
			:new.termination_code := null;
			:new.termination_date := null;
			:new.termination_reason := null;
		end if;
	end if;
end before each row;

after each row is
begin
	if inserting and :new.area_code in ('PRE-POT','POST-POT') then--PROMIS-730,costs_probability applies only for DEV projects!
		insert into costs_probability(project_id,scope_code,phase_code,probability)
		select :new.id,scope_code,phase_code,probability
		from costs_probability
		where scope_code='INT'
		and project_id is null
		and sbe_code is null
		and substance_type_code is null;
	end if;
     if inserting and :new.area_code in ('PRE-POT', 'POST-POT') and :new.predecessor_project_id is not null  --PROMIS-602
      then
      declare countVar NUMBER(10);
      begin 
      select count(*) into countVar from license_details where project_id=:new.predecessor_project_id;
      if countVar > 0 then
       UPDATE ipms_data.license_details SET predecessor_id=:new.id
		WHERE project_id=:new.predecessor_project_id;   
            declare
            cursor license_rec IS select licensor_code,licensee_code,license_type_code,license_agreement_date,license_comment 
            FROM ipms_data.license_details WHERE project_id = :new.predecessor_project_id;
            newId nvarchar2(200);
            newPredId nvarchar2(200);
            p_licensor                 NVARCHAR2(100);
            p_licensee                 NVARCHAR2(100);
            p_license_type             NVARCHAR2(100);
            p_license_agreement_date   DATE;
            p_license_comment          NVARCHAR2(500);
            p_id2                      NUMBER(10);
            begin
            open license_rec;
            loop
            fetch license_rec into p_licensor, p_licensee, p_license_type, p_license_agreement_date,p_license_comment;
            EXIT when license_rec%notfound;
            newId := :new.id;--project id 
            newPredId := :new.predecessor_project_id;-- predecessor_project_id
            SELECT
            license_id_seq.NEXTVAL
            INTO p_id2
            FROM
            dual;

        INSERT INTO ipms_data.license_details (
            id,
            project_id,
            create_user_id,
            update_user_id,
            create_date,
            update_date,
            licensor_code,
            licensee_code,
            license_type_code,
            license_agreement_date,
            license_comment,
            predecessor_id
        ) VALUES (
            p_id2,
            newId,
            'PROC',
            'PROC',
            TO_DATE(SYSDATE,'DD-MM-RR'),
            TO_DATE(SYSDATE,'DD-MM-RR'),
            p_licensor,
            p_licensee,
            p_license_type,
            p_license_agreement_date,
            p_license_comment,
            NULL
        );
            --call (ipms_data.project_license_pkg.update_license_detail(newId, newPredId));
            end loop;
            close license_rec;
            end;            
          end if;            
       end;
       end if; 
end after each row;
end;