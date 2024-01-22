prompt ---->
prompt ---->
prompt 
prompt ---->START    business_activity
prompt 
prompt ---->
prompt ---->
SET SCAN OFF;
SET DEFINE OFF;
insert into business_activity(code,name,category_id) select 'estimatesprocessdelete','Delete LE process','6' from dual where not exists(select 1 from business_activity where code = 'estimatesprocessdelete');
insert into business_activity(code,name,category_id) select 'estimatesprocessstart','Start LE process','6' from dual where not exists(select 1 from business_activity where code = 'estimatesprocessstart');
insert into business_activity(code,name,category_id) select 'estimatesprocessterminate','Terminate LE process','6' from dual where not exists(select 1 from business_activity where code = 'estimatesprocessterminate');
insert into business_activity(code,name,category_id) select 'estimatesprocessupdate','Update LE process','6' from dual where not exists(select 1 from business_activity where code = 'estimatesprocessupdate');
insert into business_activity(code,name,category_id) select 'estimatesprovide','Provide latest estimates','6' from dual where not exists(select 1 from business_activity where code = 'estimatesprovide');
insert into business_activity(code,name,category_id) select 'estimatestagcreate','Create LE tag','6' from dual where not exists(select 1 from business_activity where code = 'estimatestagcreate');
insert into business_activity(code,name,category_id) select 'estimatestagfreeze','Freeze/Unfreeze LE tag-specific data','6' from dual where not exists(select 1 from business_activity where code = 'estimatestagfreeze');
insert into business_activity(code,name,category_id) select 'estimatestagmeetingfinalize','Finalize LE values in the tag-specific LE meeting form','6' from dual where not exists(select 1 from business_activity where code = 'estimatestagmeetingfinalize');
insert into business_activity(code,name,category_id) select 'goalscreate','Create project goals','4' from dual where not exists(select 1 from business_activity where code = 'goalscreate');
insert into business_activity(code,name,category_id) select 'goalsdelete','Delete project goals','4' from dual where not exists(select 1 from business_activity where code = 'goalsdelete');
insert into business_activity(code,name,category_id) select 'goalsedit','Edit project goals','4' from dual where not exists(select 1 from business_activity where code = 'goalsedit');
insert into business_activity(code,name,category_id) select 'importstudy','Import Study from Sophia','5' from dual where not exists(select 1 from business_activity where code = 'importstudy');
insert into business_activity(code,name,category_id) select 'importtimelinefps','Import timeline data from FPS','5' from dual where not exists(select 1 from business_activity where code = 'importtimelinefps');
insert into business_activity(code,name,category_id) select 'importtimelineplansophia','Import timeline plan data from Sophia','5' from dual where not exists(select 1 from business_activity where code = 'importtimelineplansophia');
insert into business_activity(code,name,category_id) select 'ltcprovide','Provide long term cost planning data','7' from dual where not exists(select 1 from business_activity where code = 'ltcprovide');
insert into business_activity(code,name,category_id) select 'planningassumptionsprovide','Provide planning assumptions','8' from dual where not exists(select 1 from business_activity where code = 'planningassumptionsprovide');
insert into business_activity(code,name,category_id) select 'planningassumptionsstart','Maintain planning assumptions requests','8' from dual where not exists(select 1 from business_activity where code = 'planningassumptionsstart');
insert into business_activity(code,name,category_id) select 'programcreate','Create program','1' from dual where not exists(select 1 from business_activity where code = 'programcreate');
insert into business_activity(code,name,category_id) select 'programdelete','Delete program','1' from dual where not exists(select 1 from business_activity where code = 'programdelete');
insert into business_activity(code,name,category_id) select 'programedit','Edit program','1' from dual where not exists(select 1 from business_activity where code = 'programedit');
insert into business_activity(code,name,category_id) select 'programroles','Assign program-level user roles','1' from dual where not exists(select 1 from business_activity where code = 'programroles');
insert into business_activity(code,name,category_id) select 'programteam','Maintain program team members','1' from dual where not exists(select 1 from business_activity where code = 'programteam');
insert into business_activity(code,name,category_id) select 'projectcreate','Create project','2' from dual where not exists(select 1 from business_activity where code = 'projectcreate');
insert into business_activity(code,name,category_id) select 'projectdelete','Move project to the Recycle Bin, Delete project from the Recycle Bin','2' from dual where not exists(select 1 from business_activity where code = 'projectdelete');
insert into business_activity(code,name,category_id) select 'projectedit','Edit project data, Maintain PMO comments, Inactivate project','2' from dual where not exists(select 1 from business_activity where code = 'projectedit');
insert into business_activity(code,name,category_id) select 'projecteditid','Provide project ID','2' from dual where not exists(select 1 from business_activity where code = 'projecteditid');
insert into business_activity(code,name,category_id) select 'projectforecast','Calculate project forecast for internal/external cost','2' from dual where not exists(select 1 from business_activity where code = 'projectforecast');
insert into business_activity(code,name,category_id) select 'projectimportd1','Import D1 project from Combase','2' from dual where not exists(select 1 from business_activity where code = 'projectimportd1');
insert into business_activity(code,name,category_id) select 'projectlead','Set lead project in a program','2' from dual where not exists(select 1 from business_activity where code = 'projectlead');
insert into business_activity(code,name,category_id) select 'projectmove','Move Development project to another program','2' from dual where not exists(select 1 from business_activity where code = 'projectmove');
insert into business_activity(code,name,category_id) select 'projectrelease','Release project to the PIDT','2' from dual where not exists(select 1 from business_activity where code = 'projectrelease');
insert into business_activity(code,name,category_id) select 'projectreleasefps','Send project to the FPS','2' from dual where not exists(select 1 from business_activity where code = 'projectreleasefps');
insert into business_activity(code,name,category_id) select 'projectrestore','Restore deleted project','2' from dual where not exists(select 1 from business_activity where code = 'projectrestore');
insert into business_activity(code,name,category_id) select 'projecttypify','Typify planning codes','2' from dual where not exists(select 1 from business_activity where code = 'projecttypify');
insert into business_activity(code,name,category_id) select 'referencesmaintain','Maintain References (e.g. user-community, FAQS, reporting)','9' from dual where not exists(select 1 from business_activity where code = 'referencesmaintain');
insert into business_activity(code,name,category_id) select 'sandboxplancreate','Create sandbox plan','10' from dual where not exists(select 1 from business_activity where code = 'sandboxplancreate');
insert into business_activity(code,name,category_id) select 'sandboxplandelete','Delete sandbox plan','10' from dual where not exists(select 1 from business_activity where code = 'sandboxplandelete');
insert into business_activity(code,name,category_id) select 'sandboxplanimportactuals','Import source project timeline actuals into the Sandbox plan','10' from dual where not exists(select 1 from business_activity where code = 'sandboxplanimportactuals');
insert into business_activity(code,name,category_id) select 'sandboxplanimportplan','Import source project timeline plan into the Sandbox plan','10' from dual where not exists(select 1 from business_activity where code = 'sandboxplanimportplan');
insert into business_activity(code,name,category_id) select 'sandboxplanmodify','Modify source project of a sandbox plan','10' from dual where not exists(select 1 from business_activity where code = 'sandboxplanmodify');
insert into business_activity(code,name,category_id) select 'tppedit','Edit target product profile (TPP)','3' from dual where not exists(select 1 from business_activity where code = 'tppedit');
insert into business_activity(code,name,category_id) select 'timelinepublish','Publish project plan as Current/Approved), Change publication comment','5' from dual where not exists(select 1 from business_activity where code = 'timelinepublish');
insert into business_activity(code,name,category_id) select 'unlocksendreceive','Maintain integration services on any program/project','5' from dual where not exists(select 1 from business_activity where code = 'unlocksendreceive');
insert into business_activity(code,name,category_id) select 'messagefps','FPS Integration','11' from dual where not exists(select 1 from business_activity where code = 'messagefps');
insert into business_activity(code,name,category_id) select 'maintainbaselines','Maintain/delete baselines','5' from dual where not exists(select 1 from business_activity where code = 'maintainbaselines');
insert into business_activity(code,name,category_id) select 'estimatesprocessstartltc','Start LTC/FTE process','7' from dual where not exists(select 1 from business_activity where code = 'estimatesprocessstartltc');
insert into business_activity(code,name,category_id) select 'estimatesprocessterminateltc','Terminate LTC/FTE process','7' from dual where not exists(select 1 from business_activity where code = 'estimatesprocessterminateltc');
insert into business_activity(code,name,category_id) select 'estimatesprocessupdateltc','Update LTC/FTE process','7' from dual where not exists(select 1 from business_activity where code = 'estimatesprocessupdateltc');
insert into business_activity(code,name,category_id) select 'estimatesprovideltc','Provide LTC estimates','7' from dual where not exists(select 1 from business_activity where code = 'estimatesprovideltc');
insert into business_activity(code,name,category_id) select 'estimatestagcreateltc','Create LTC/FTE tag.','7' from dual where not exists(select 1 from business_activity where code = 'estimatestagcreateltc');
insert into business_activity(code,name,category_id) select 'estimatestagprefillltc','Prefill data for all, tag related, LTC/FTE process.','7' from dual where not exists(select 1 from business_activity where code = 'estimatestagprefillltc');
insert into business_activity(code,name,category_id) select 'autoimportstudy','Automatic Study import from Sophia','5' from dual where not exists(select 1 from business_activity where code = 'autoimportstudy');
insert into business_activity(code,name,category_id) select 'importbegin','ProMIS data import has been started.','2' from dual where not exists(select 1 from business_activity where code = 'importbegin');
insert into business_activity(code,name,category_id) select 'importend','ProMIS data import has been finished.','2' from dual where not exists(select 1 from business_activity where code = 'importend');
insert into business_activity(code,name,category_id) select 'importcleanup','ProMIS data import obsolete data cleanup.','2' from dual where not exists(select 1 from business_activity where code = 'importcleanup');
insert into business_activity(code,name,category_id) select 'importareacodeco','ProMIS data import for Controlling Object projects.','2' from dual where not exists(select 1 from business_activity where code = 'importareacodeco');
insert into business_activity(code,name,category_id) select 'importareacoded2prj','ProMIS data import for D2-Project projects.','2' from dual where not exists(select 1 from business_activity where code = 'importareacoded2prj');
insert into business_activity(code,name,category_id) select 'importareacoded3tr','ProMIS data import for D3-Transition projects.','2' from dual where not exists(select 1 from business_activity where code = 'importareacoded3tr');
insert into business_activity(code,name,category_id) select 'importareacodelg','ProMIS data import for Lead Generation projects.','2' from dual where not exists(select 1 from business_activity where code = 'importareacodelg');
insert into business_activity(code,name,category_id) select 'importareacodelo','ProMIS data import for Lead Optimization projects.','2' from dual where not exists(select 1 from business_activity where code = 'importareacodelo');
insert into business_activity(code,name,category_id) select 'importareacodepostpot','ProMIS data import for post-PoT projects.','2' from dual where not exists(select 1 from business_activity where code = 'importareacodepostpot');
insert into business_activity(code,name,category_id) select 'importareacodeprdmnt','ProMIS data import for Product Maintenance projects.','2' from dual where not exists(select 1 from business_activity where code = 'importareacodeprdmnt');
insert into business_activity(code,name,category_id) select 'importareacodeprepot','ProMIS data import for pre-PoT projects.','2' from dual where not exists(select 1 from business_activity where code = 'importareacodeprepot');
insert into business_activity(code,name,category_id) select 'importareacoders','ProMIS data import for Research projects.','2' from dual where not exists(select 1 from business_activity where code = 'importareacoders');
insert into business_activity(code,name,category_id) select 'importloggedchangesemail','ProMIS data import Logged Changes Email.','2' from dual where not exists(select 1 from business_activity where code = 'importloggedchangesemail');
insert into business_activity(code,name,category_id) select 'importreleasedcompletedpidtemail','ProMIS data import Release Completed PID Email.','2' from dual where not exists(select 1 from business_activity where code = 'importreleasedcompletedpidtemail');
insert into business_activity(code,name,category_id) select 'importareacoded1','ProMIS data import for Pre-D2 Area projects.','2' from dual where not exists(select 1 from business_activity where code = 'importareacoded1');
commit;
prompt ---->END    business_activity
prompt ---->
prompt ---->