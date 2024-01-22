prompt ---->
prompt ---->
prompt 
prompt ---->START    help_bundle
prompt 
prompt ---->Inserts ONLY If the row is missing!!!
prompt ---->
prompt ---->
SET SCAN OFF;
SET DEFINE OFF;

insert into help_bundle(code, name, definition, url)
select 'TOP-EXP-ONC-URL', 'TOP Onc Export to PDF Link', 'PDF',
'https://by-polaris-test.bayer-ag.com:443/MicroStrategy/servlet/mstrWeb?evt=2048001&src=mstrWeb.2048001&documentID=AC139C7811E56C0F01B30080EFD57317&visMode=0&currentViewMedia=2&server=BYMST5.BAYER-AG.COM&Project=ProMIS%20Reporting&port=0&share=1&promptAnswerMode=2&promptsAnswerXML=<rsl><pa pt="7" pin="0" did="A173BEC7464F8B3DDD13E295F30480D7" tp="10"><mi><es><at did="EA8CC86D42669B2F4195648A5B156D19" tp="12"/><e emt="1" ei="EA8CC86D42669B2F4195648A5B156D19:#ProjectId#" art="1" disp_n="#ProjectId#"/></es></mi></pa><pa pt="7" pin="0" did="EEC2A7B64045511E4CA60EB890082DEF" tp="10"><mi><es><at did="DB2FE90345ED2F886DFB1C9625E0F7E6" tp="12"/><e emt="1" ei="DB2FE90345ED2F886DFB1C9625E0F7E6:#Version#" art="1" disp_n="#Version#"/></es></mi></pa></rsl>' 
from dual
where not exists(select 1 from help_bundle where code = 'TOP-EXP-ONC-URL');

insert into help_bundle(code, name, definition, url)
select 'TOP-EXP-NONC-URL', 'TOP Non-Onc Export to PDF Link', 'PDF',
'https://by-polaris-test.bayer-ag.com:443/MicroStrategy/servlet/mstrWeb?evt=2048001&src=mstrWeb.2048001&documentID=AC139C7811E56C0F01B30080EFD57317&visMode=0&currentViewMedia=2&server=BYMST5.BAYER-AG.COM&Project=ProMIS%20Reporting&port=0&share=1&promptAnswerMode=2&promptsAnswerXML=<rsl><pa pt="7" pin="0" did="A173BEC7464F8B3DDD13E295F30480D7" tp="10"><mi><es><at did="EA8CC86D42669B2F4195648A5B156D19" tp="12"/><e emt="1" ei="EA8CC86D42669B2F4195648A5B156D19:#ProjectId#" art="1" disp_n="#ProjectId#"/></es></mi></pa><pa pt="7" pin="0" did="EEC2A7B64045511E4CA60EB890082DEF" tp="10"><mi><es><at did="DB2FE90345ED2F886DFB1C9625E0F7E6" tp="12"/><e emt="1" ei="DB2FE90345ED2F886DFB1C9625E0F7E6:#Version#" art="1" disp_n="#Version#"/></es></mi></pa></rsl>' 
from dual
where not exists(select 1 from help_bundle where code = 'TOP-EXP-NONC-URL');

insert into help_bundle(code, name, definition, url)
select 'TPP-EXPURL', 'TPP Export to PDF Link', 'PDF',
'https://by-polaris.bayer-ag.com:443/MicroStrategy/servlet/mstrWeb?evt=2048001&src=mstrWeb.2048001&documentID=92D755C311E65D6500000080EF554D61&visMode=0&currentViewMedia=2&server=BYMST8.BAYER-AG.COM&Project=ProMIS%20Reporting&port=0&share=1&promptAnswerMode=2&promptsAnswerXML=<rsl><pa pt="7" pin="0" did="BE4E3DF411E65D3AC4280080EF452C00" tp="10"><mi><es><at did="EA8CC86D42669B2F4195648A5B156D19" tp="12"/><e emt="1" ei="EA8CC86D42669B2F4195648A5B156D19:#ProjectId#" art="1" disp_n="#ProjectId#"/></es></mi></pa><pa pt="7" pin="0" did="EEC2A7B64045511E4CA60EB890082DEF" tp="10"><mi><es><at did="DB2FE90345ED2F886DFB1C9625E0F7E6" tp="12"/><e emt="1" ei="DB2FE90345ED2F886DFB1C9625E0F7E6:#Version#" art="1" disp_n="#Version#"/></es></mi></pa></rsl>' 
from dual
where not exists(select 1 from help_bundle where code = 'TPP-EXPURL');

commit;
prompt ---->END    help_bundle
prompt ---->
prompt ---->
/
prompt ---->START    help_bundle
prompt ---->
prompt ---->
SET SCAN OFF;
SET DEFINE OFF;

Insert into HELP_BUNDLE (CODE,NAME,DEFINITION,URL) values ('PROJECT_SAMD_OVERVIEW_CHARACTERISTICS','SaMD Project -> Overview -> Characteristics','Help','http://sp-coll-bhc.bayer-ag.com/sites/221953/ProMIS_UserGuide/Under%20Construction.aspx');
Insert into HELP_BUNDLE (CODE,NAME,DEFINITION,URL) values ('PROJECT_SAMD_OVERVIEW_PLANS','SaMD Project -> Overview -> Plan Versions','Help','http://sp-coll-bhc.bayer-ag.com/sites/221953/ProMIS_UserGuide/Under%20Construction.aspx');

commit;
prompt ---->END    help_bundle
prompt ---->
prompt ---->
