alter table project_category add correlation_id varchar2(4);
alter table project_category add update_date date;
alter table import_subgroup add correlation_id varchar2(4);
comment on column project_category.correlation_id is 'The ID used for data export to MAGIC or other external systems. The column values must be unique.';
comment on column project_category.is_promis is 'Based on the value of this column records are being devided into two sub groups: is_promis=1 means it is a LC Type lokup else it is a Subgroup.';
---------
create or replace trigger project_category_biu_tr
before insert or update on project_category for each row
  begin
    if inserting then
      :new.create_date := sysdate;
      :new.update_date := :new.create_date;
	  if :new.is_promis=1 and :new.correlation_id is null then
		select max(correlation_id)+1 into :new.correlation_id
		from project_category
		where is_promis=1;
	  end if;
    end if;
    if updating then
      :new.update_date := sysdate;
    end if;
  end;
/
--------------
merge into project_category ooo using (select 'ME' code,'molecular entity' name,'1' is_active ,'1' is_promis, '9001' correlation_id from dual) nnn on (ooo.code=nnn.code) when matched then update set ooo.name = 'molecular entity',ooo.is_active = '1',ooo.is_promis = '1', correlation_id='9001' when not matched then insert (code,name,is_active,is_promis,correlation_id) values ('ME','molecular entity','1','1','9001');
merge into project_category ooo using (select 'NF' code,'new formulation' name,'1' is_active ,'1' is_promis, '9002' correlation_id from dual) nnn on (ooo.code=nnn.code) when matched then update set ooo.name = 'new formulation',ooo.is_active = '1',ooo.is_promis = '1', correlation_id='9002' when not matched then insert (code,name,is_active,is_promis,correlation_id) values ('NF','new formulation','1','1','9002');
merge into project_category ooo using (select 'NI' code,'new indication' name,'1' is_active ,'1' is_promis, '9003' correlation_id from dual) nnn on (ooo.code=nnn.code) when matched then update set ooo.name = 'new indication',ooo.is_active = '1',ooo.is_promis = '1', correlation_id='9003' when not matched then insert (code,name,is_active,is_promis,correlation_id) values ('NI','new indication','1','1','9003');
merge into project_category ooo using (select 'NM' code,'new molecule' name,'1' is_active ,'1' is_promis, '9004' correlation_id from dual) nnn on (ooo.code=nnn.code) when matched then update set ooo.name = 'new molecule',ooo.is_active = '1',ooo.is_promis = '1', correlation_id='9004' when not matched then insert (code,name,is_active,is_promis,correlation_id) values ('NM','new molecule','1','1','9004');
merge into project_category ooo using (select 'ped' code,'pediatric project' name,'1' is_active ,'1' is_promis, '9005' correlation_id from dual) nnn on (ooo.code=nnn.code) when matched then update set ooo.name = 'pediatric project',ooo.is_active = '1',ooo.is_promis = '1', correlation_id='9005' when not matched then insert (code,name,is_active,is_promis,correlation_id) values ('ped','pediatric project','1','1','9005');
commit;
----------
declare
begin
	for rr in 
		(
			select code
			from project_category
			where is_promis=1
			and correlation_id is null
		) 
		loop
			null;
			update project_category 
			set correlation_id=
				(
				select max(correlation_id)+1
				from project_category
				where is_promis=1
				)
			where code = rr.code and correlation_id is null;
		end loop;
commit;
end;
/
----------
declare
begin
	for rr in 
		(
			select code
			from project_category
			where is_promis=0
			and correlation_id is null
		) 
		loop
			update project_category 
			set correlation_id=
				(
				select sub.xgs_no
				from bdo_subgroup@combase_db sub 
				where xgs_code=rr.code and status='ACTIVE'
				)
			where code = rr.code and correlation_id is null;
		end loop;
commit;
end;
/
alter table project_category modify correlation_id not null;
create unique index project_category_correl_ui on project_category(correlation_id);
------------
