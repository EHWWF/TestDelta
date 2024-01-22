prompt ---->
prompt ---->
prompt 
prompt ---->START    news_category
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;
insert into news_category(code,name,is_active) select '1','Top line results','1' from dual where not exists(select 1 from news_category where code = '1');
insert into news_category(code,name,is_active) select '2','Publication','1' from dual where not exists(select 1 from news_category where code = '2');
insert into news_category(code,name,is_active) select '3','AdCom','1' from dual where not exists(select 1 from news_category where code = '3');
insert into news_category(code,name,is_active) select '4','CHMP opinion','1' from dual where not exists(select 1 from news_category where code = '4');
insert into news_category(code,name,is_active) select '5','other','1' from dual where not exists(select 1 from news_category where code = '5');

commit;
prompt ---->END    news_category
prompt ---->
prompt ---->