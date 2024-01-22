create or replace package qplan_pkg as

-- TODO: Move this to message_pkg
	nsuri_ipms_qplan constant nvarchar2(100) := 'http://xmlns.bayer.com/ipms/qplan';


--**************************************************************************
--* Error message prefix
--*
	g_error_prefix nvarchar2(20):='ERROR: ';

--**************************************************************************
--* Function used for QPLAN_view
--*
	function get_element_value(p_prj_id in nvarchar2,
								p_code in nvarchar2,
								p_is_mandatory in number,
								p_name in nvarchar2)
								return ipms_data.nvarchar2_4object_table_typ pipelined;


--**************************************************************************
--* Create XML representation for FPS/QuickPlan
--*
	function xml(p_id in nvarchar2) return xmltype;

--**************************************************************************
--* Procedure used to release Project to QPlan
--* Requires unlocked Project instance.
--* Throws no_data_found exception if requirements unmatched.
--* Asynchronous.
--* Sends execute/release message.
--* Locks instance.
	procedure release(p_id in nvarchar2, p_payload_before in xmltype default null, p_callback in varchar2 := null);

--**************************************************************************
--* TODO description
--*
	procedure release_finish(p_id in nvarchar2, p_payload in xmltype);


	procedure receive_timeline(p_id in nvarchar2, p_callback in varchar2 := null);
	procedure receive_timeline_finish(p_id in nvarchar2, p_payload in xmltype);

	procedure receive_placeholder_studies(p_id in nvarchar2, p_callback in varchar2 := null);

end;
/
create or replace package body qplan_pkg 
as
b_obj nvarchar2_4object_typ := nvarchar2_4object_typ(null,null,null,null);
b_code nvarchar2(200);
b_is_mandatory number(1);
b_name nvarchar2(500);
v_remove_xml nvarchar2(100):='REMOVE_THIS_XML_ELEMENT_FROM_EXPORT';

/**************************************************************************/
procedure get_value_result
as
begin
if b_is_mandatory = 1 and b_obj.var2 is null then
b_obj.var2:=qplan_pkg.g_error_prefix||b_name||' MUST be provided.';
--b_obj.var2:=qplan_pkg.g_error_prefix||' MUST be provided.';
b_obj.var3:=null;
b_obj.var4:='1';
end if;
end;

/**************************************************************************/
procedure get_element_value_exception
as
begin
b_obj.var2:=qplan_pkg.g_error_prefix||'Getting '||b_name;
b_obj.var3:=null;
b_obj.var4:='1';
end;

--**************************************************************************
--* DrugSubstanceType
--*
procedure get_DrugSubstanceType_value
as
begin
select st.name, st.code, 0 into b_obj.var2, b_obj.var3, b_obj.var4
from project prj, substance_type st
where prj.id = b_obj.var1
and prj.substance_type_code = st.code;

get_value_result;
exception
when no_data_found then
b_obj.var2:=null;
b_obj.var3:=null;
b_obj.var4:=0;
get_value_result;
when others then
get_element_value_exception;
end;

--**************************************************************************
--* LeadCandidateType
--*
procedure get_LeadCandidateType_value
as
v_area_code nvarchar2(22);
v_lct_name nvarchar2(222);
v_lct_code nvarchar2(222);
v_sub_name nvarchar2(222);
v_sub_code nvarchar2(222);
begin
select pc.name, pc.code, sub.name, sub.code, 0, prj.area_code
into v_lct_name, v_lct_code, v_sub_name, v_sub_code, b_obj.var4, v_area_code
from project prj
left join project_category pc on (prj.category_code = pc.code)
left join project_category sub on (prj.project_group_code = sub.code)
where prj.id = b_obj.var1;

if v_area_code in ('PRE-POT','POST-POT','D2-PRJ') then
--repeat the SELECT by taking another join column
--because for area_codes that ProMIS is not the owner
--exported value to QPlan must be taken from imported Subgroup code from MaGIC
--but not LC Type that is being assigned at ProMIS. For more info see: BAY_PROMIS-439
b_obj.var2:=v_lct_name;
b_obj.var3:=v_lct_code;
else
b_obj.var2:=v_sub_name;
b_obj.var3:=v_sub_code;
end if;

get_value_result;
exception
when no_data_found then
b_obj.var2:=null;
b_obj.var3:=null;
b_obj.var4:=0;
get_value_result;
when others then
get_element_value_exception;
end;

--**************************************************************************
--* LeadProject
--*
procedure get_LeadProject_value
as
begin
select decode(prj.is_lead,1,'Yes',0,'No',null),prj.is_lead,0 into b_obj.var2, b_obj.var3, b_obj.var4
from project prj
where prj.id = b_obj.var1;

get_value_result;
exception when others then get_element_value_exception;
end;

--**************************************************************************
--* ProjectPriority
--*
procedure get_ProjectPriority_value
as
begin
select p.name, p.code, 0 into b_obj.var2, b_obj.var3, b_obj.var4
from project prj, priority p
where prj.id = b_obj.var1
and prj.priority_code = p.code;

get_value_result;
exception
when no_data_found then
b_obj.var2:=null;
b_obj.var3:=null;
b_obj.var4:=0;
get_value_result;
when others then
get_element_value_exception;
end;

--**************************************************************************
--* ProjectArea -- MUST HAVE VALUE
--*
procedure get_ProjectArea_value
as
begin
select pa.name, pa.code, 0 into b_obj.var2, b_obj.var3, b_obj.var4
from project prj, project_area pa
where prj.id = b_obj.var1
and prj.area_code = pa.code;

get_value_result;
exception when others then get_element_value_exception;
end;

--**************************************************************************
--* ProjectStatus
--*
procedure get_ProjectStatus_value
as
begin
select ps.name, ps.code, 0 into b_obj.var2, b_obj.var3, b_obj.var4
from project prj, project_state ps
where prj.id = b_obj.var1
and prj.STATE_CODE = ps.code;

get_value_result;
exception
when no_data_found then
b_obj.var2:=null;
b_obj.var3:=null;
b_obj.var4:=0;
get_value_result;
when others then
get_element_value_exception;
end;

--**************************************************************************
--* TherapeuticArea
--*
procedure get_TherapeuticArea_value
as
begin
select ta.name, ta.code, 0 into b_obj.var2, b_obj.var3, b_obj.var4
from project prj, THERAPEUTIC_AREA ta
where prj.id = b_obj.var1
and prj.TA_CODE = ta.code;

get_value_result;
exception
when no_data_found then
b_obj.var2:=null;
b_obj.var3:=null;
b_obj.var4:=0;
get_value_result;
when others then
get_element_value_exception;
end;

--**************************************************************************
--* StrategicBusinessEntity
--*
procedure get_SBEntity_value
as
begin
select sbe.name, sbe.code, 0 into b_obj.var2, b_obj.var3, b_obj.var4
from project prj
inner join strategic_business_entity sbe on sbe.code = nvl(prj.sbe_code,prj.proposed_sbe_code)--NVL=CUC-380
where prj.id = b_obj.var1;


get_value_result;
exception
when no_data_found then
b_obj.var2:=null;
b_obj.var3:=null;
b_obj.var4:=0;
get_value_result;
when others then
get_element_value_exception;
end;

--**************************************************************************
--* DrugSubstance
--*
procedure get_DrugSubstance_value
as
begin
select bn.name, bn.name, 0 into b_obj.var2, b_obj.var3, b_obj.var4
from project prj, bay_number bn
where prj.id = b_obj.var1
and prj.bay_code = bn.code;

get_value_result;
exception
when no_data_found then
b_obj.var2:=null;
b_obj.var3:=null;
b_obj.var4:=0;
get_value_result;
when others then
get_element_value_exception;
end;

--**************************************************************************
--* ProgramID
--*
procedure get_ProgramID_value
as
begin
select prg.code, prg.code, 0 into b_obj.var2, b_obj.var3, b_obj.var4
from project prj
inner join program prg on prg.id=prj.program_id
where prj.id = b_obj.var1;

get_value_result;
exception
when no_data_found then
b_obj.var2:=null;
b_obj.var3:=null;
b_obj.var4:=0;
get_value_result;
when others then
get_element_value_exception;
end;

--**************************************************************************
--* ProgramName
--*
procedure get_ProgramName_value
as
begin
select pro.name, pro.name, 0 into b_obj.var2, b_obj.var3, b_obj.var4
from project prj, program pro
where prj.id = b_obj.var1
and prj.program_id = pro.id
and pro.name not like 'RESERVED-%';

get_value_result;
exception
when no_data_found then
b_obj.var2:=null;
b_obj.var3:=null;
b_obj.var4:=0;
get_value_result;
when others then
get_element_value_exception;
end;

--**************************************************************************
--* ProjectID
--*
procedure get_ProjectID_value
as
begin
select prj.code, prj.code, 0
into b_obj.var2, b_obj.var3, b_obj.var4
from project prj
where prj.id = b_obj.var1;

get_value_result;
exception when others then get_element_value_exception;
end;

--**************************************************************************
--* PlanningCode
--*
procedure get_PlanningCode_value
as
begin

with prj as (
select
id, code,
case when area_code in ('RS', 'LG', 'LO', 'D2-PRJ') then planning_code else code end as planning_code
from project
)
select prj.planning_code, prj.planning_code, 0
into b_obj.var2, b_obj.var3, b_obj.var4
from prj
where prj.id = b_obj.var1;

get_value_result;
exception when others then get_element_value_exception;
end;

--**************************************************************************
--* ProjectName
--*
procedure get_ProjectName_value
as
begin
select prj.name, prj.name, 0 into b_obj.var2, b_obj.var3, b_obj.var4
from project prj
where prj.id = b_obj.var1;

get_value_result;
exception when others then get_element_value_exception;
end;

--**************************************************************************
--* ControllingPortfolio
--*
procedure get_ControllingPortfolio_value
as
begin
select decode(prj.planning_enabled,'green','Green','red','Red',null), 0 into b_obj.var2, b_obj.var4
from project prj
where prj.id = b_obj.var1;

b_obj.var3:=b_obj.var2;

get_value_result;
exception when others then get_element_value_exception;
end;

--**************************************************************************
--* DateTermination
--*
procedure get_DateTermination_value
as
begin
select to_char(prj.termination_date,'yyyy-mm-dd'), 0 into b_obj.var2, b_obj.var4
from project prj
where prj.id = b_obj.var1
and prj.state_code='5';--5=Terminated;6=Completed

b_obj.var3:=b_obj.var2; -->element_xml_send_value=element_show_value

get_value_result;
exception
when no_data_found then
b_obj.var2:=null;
b_obj.var3:=v_remove_xml;
b_obj.var4:=0;
get_value_result;
when others then
get_element_value_exception;
end;

--**************************************************************************
--* DateCompletion
--*
procedure get_DateCompletion_value
as
begin
select null, 0 into b_obj.var2, b_obj.var4
from project prj
where prj.id = b_obj.var1
and prj.state_code='6';--5=Terminated;6=Completed


/* Completion date will always be null, so, check meybe in TIMELINE for CUR plan exists */
begin
select to_char(nvl(nvl(nvl(actual_start,actual_finish), plan_start),plan_finish),'yyyy-mm-dd') into b_obj.var2
from timeline_activity
where project_id = b_obj.var1
and timeline_type_code = 'CUR'
and milestone_code ='Compl';
exception when no_data_found then
b_obj.var2:=null;
end;

b_obj.var3:=b_obj.var2; -->element_xml_send_value=element_show_value

get_value_result;
exception
when no_data_found then
b_obj.var2:=null;
b_obj.var3:=v_remove_xml;
b_obj.var4:=0;
get_value_result;
when others then
get_element_value_exception;
end;

--**************************************************************************
--* DateCompletion
--*
procedure get_ProjectFinishedDate_value
as
v_prj_state_code varchar2(10);
begin

select
decode(prj.state_code, 5, to_char(prj.termination_date,'yyyy-mm-dd'), null),
0,
prj.state_code
into
b_obj.var2,
b_obj.var4,
v_prj_state_code
from project prj
where prj.id = b_obj.var1
and prj.area_code !='SAMD'    --- Promis 604
and prj.state_code in ('5', '6');--5=Terminated;6=Completed


/* Completion date will always be null, so, check meybe in TIMELINE for CUR plan exists */
if v_prj_state_code = '6' and b_obj.var2 is null then
begin
select to_char(nvl(nvl(nvl(actual_start,actual_finish), plan_start),plan_finish),'yyyy-mm-dd') into b_obj.var2
from timeline_activity
where project_id = b_obj.var1
and timeline_type_code = 'CUR'
and milestone_code ='Compl';
exception when no_data_found then
b_obj.var2:=null;
end;
end if;

b_obj.var3:=b_obj.var2; -->element_xml_send_value=element_show_value

get_value_result;
exception
when no_data_found then
b_obj.var2:=null;
b_obj.var3:=v_remove_xml;
b_obj.var4:=0;
get_value_result;
when others then
get_element_value_exception;
end;



--**************************************************************************
--* get_element_value
--*
function get_element_value(p_prj_id in nvarchar2,
p_code in nvarchar2,
p_is_mandatory in number,
p_name in nvarchar2)
return ipms_data.nvarchar2_4object_table_typ pipelined
as
begin
/*
The meaning for column numbers:
qobject.var2 --> element_show_value,
qobject.var3 --> element_xml_send_value,
qobject.var4 --> element_is_blocking,
*/
b_obj.var1:=p_prj_id;
b_code:=p_code;
b_is_mandatory:=p_is_mandatory;
b_name:=p_name;

if p_code='DrugSubstanceType' then
get_DrugSubstanceType_value;
elsif p_code='LeadCandidateType' then
get_LeadCandidateType_value;
elsif p_code='LeadProject' then
get_LeadProject_value;
elsif p_code='ProjectPriority' then
get_ProjectPriority_value;
elsif p_code='ProjectArea' then
get_ProjectArea_value;
elsif p_code='ProjectStatus' then
get_ProjectStatus_value;
elsif p_code='TherapeuticArea' then
get_TherapeuticArea_value;
elsif p_code='StrategicBusinessEntity' then
get_SBEntity_value;
elsif p_code='DrugSubstance' then
get_DrugSubstance_value;
elsif p_code='ProgramID' then
get_ProgramID_value;
elsif p_code='ProgramName' then
get_ProgramName_value;
elsif p_code='ProjectID' then
get_ProjectID_value;
elsif p_code='PlanningCode' then
get_PlanningCode_value;
elsif p_code='ProjectName' then
get_ProjectName_value;
elsif p_code='ControllingPortfolio' then
get_ControllingPortfolio_value;
elsif p_code='DateTermination' then
get_datetermination_value;
elsif p_code='DateCompletion' then
get_DateCompletion_value;
elsif p_code= 'ProjectFinishedDate' then
get_ProjectFinishedDate_value;
else
b_obj.var2:='<< Error, missing XML element code implementation. >>';
b_obj.var3:=null;
b_obj.var4:='1';
end if;

PIPE ROW(b_obj);
return;
end;

/**************************************************************************************************************/
function xml(p_id in nvarchar2) return xmltype as
v_payload xmltype;
begin

select
xmlelement(evalname nvl2(qplan_release_date, 'updateProject', 'createProject'),
xmlattributes(
nsuri_ipms_qplan as "xmlns",
nvl(p.update_user_id, p.create_user_id) as "cwid",
p.id AS "projectId",
p.code AS "projectCode"
),
xmlelement("masterData",
(select
xmlagg(
xmlelement("entry",
xmlelement("key", element_code),
xmlelement("value", element_xml_send_value)
))
from qplan_master_data_vw
where project_id=p.id
and nvl(element_xml_send_value, '-') != v_remove_xml
-- At the moment QPlan does not support empty values
and element_xml_send_value is not null
)
),
xmlelement("decisionMilestones",
xmlattributes(
decode(generic_timelines_pkg.is_milestones_in_sequence(p.id), 0, 'true', 'false') as "outOfSync"
),
(select
xmlagg(
xmlelement("milestone",
xmlelement("milestoneCode", decode(upper(milestone_code), upper('FiM-RC'), 'toxFimRC', upper(milestone_code))),
xmlforest(
get_char_date(plan_date) as "planDate",
get_char_date(actual_date) as "actualDate",
get_char_date(generic_date) as "genericDate"
)
))
from qplan_milestones_vw
where project_id=p.id
)
),
xmlelement("ptrValues",
(select
xmlagg(
xmlelement("ptr",
xmlelement("phase", decode(phase_code, '1', 'preclinical', '2', 'phase1', '34', 'phase2', '5', 'phase3', '6', 'submission')),
xmlforest(
default_probability as "defaultProbability",
probability as "projectProbability"
)
))
from prj_ptr_values_vw
where project_id=p.id
)
)
)
into v_payload
from project p
where p.id = p_id and p.code is not null;

return v_payload;
end;

--**************************************************************************
--* Create XML diff between original and update representations for FPS/QuickPlan
--*
function xml_diff(p_payload_before in xmltype, p_payload_after in xmltype) return xmltype as
v_payload xmltype;
begin

if p_payload_before is null or p_payload_after.existsNode('//*:updateProject') = 0 then
return p_payload_after;
end if;

v_payload := p_payload_after;

for no_diff in (

select p1.node_name
from
xmltable(
'/*/*' passing p_payload_before
columns
node_name varchar2(30) path 'local-name(.)',
node xmltype path '.'
) p1,
xmltable(
'/*/*' passing p_payload_after
columns
node_name varchar2(30) path 'local-name(.)',
node xmltype path '.'

) p2
where p1.node_name = p2.node_name
and xmldiff(xmltype(p1.node.getClobVal()), xmltype(p2.node.getClobVal())).existsNode('/*/*') = 0

) loop

select deletexml(v_payload, '/*/*:'||no_diff.node_name)
into v_payload
from dual;

end loop;

return v_payload;
end;


/**************************************************************************************************************/
function get_subject(p_id in nvarchar2) return nvarchar2 as
begin
return 'qplan:project:'||p_id;
end;

/**************************************************************************************************************/
procedure release(p_id in nvarchar2, p_payload_before in xmltype, p_callback in varchar2 := null) as
v_payload xmltype;
v_msgid nvarchar2(100);
begin


if p_payload_before is null then
v_payload := xml(p_id);
else
v_payload := xml_diff(p_payload_before, xml(p_id));
end if;

v_payload := message_pkg
.xml('<callQPlan '||message_pkg.xmlns_ipms_qplan||'/>')
.appendchildxml('/*', v_payload);


notice_pkg.debug(get_subject(p_id), project_pkg.get_summary(p_id)||' will be released to FPS/QuickPlan.');
log_pkg.log(get_subject(p_id), project_pkg.get_summary(p_id), 'Releasing to FPS/QuickPlan.');


v_msgid :=
message_pkg.send(
get_subject(p_id),
v_payload,
get_text('begin qplan_pkg.release_finish(''%1'',:1); %2 end;', varchar2_table_typ(p_id, p_callback))
);

end;

/**************************************************************************************************************/
procedure release_finish(p_id in nvarchar2, p_payload in xmltype) as
begin

if message_pkg.is_complete(p_payload) = 1
then

notice_pkg.information(get_subject(p_id), project_pkg.get_summary(p_id)||' released to FPS/QuickPlan.');

update project
set qplan_release_date=sysdate
where id=p_id and qplan_release_date is null;

elsif message_pkg.is_error(p_payload) = 1
then
notice_pkg.debug(get_subject(p_id), project_pkg.get_summary(p_id)||' failed in FPS/QuickPlan.');
end if;

end;

/**************************************************************************************************************/
procedure receive_timeline(p_id in nvarchar2, p_callback in varchar2 := null) as
v_payload xmltype;
v_msgid nvarchar2(100);
begin

-- Make XML message
select
xmlelement("callQPlan",
xmlattributes(
nsuri_ipms_qplan as "xmlns"
),
xmlelement("readTimeline",
xmlattributes(
nvl(p.update_user_id, p.create_user_id) as "cwid",
p.id AS "projectId",
p.code AS "projectCode"
)
)
)
into v_payload
from project p
where p.id = p_id and p.code is not null;

-- TODO: Send message, log, receive callback

v_msgid :=
message_pkg.send(
get_subject(p_id),
v_payload,
get_text('begin qplan_pkg.receive_timeline_finish(''%1'',:1); %2 end;', varchar2_table_typ(p_id, p_callback))
);
end;

/**************************************************************************************************************/
procedure receive_timeline_finish(p_id in nvarchar2, p_payload in xmltype) as

begin

if message_pkg.is_complete(p_payload) = 1
then
notice_pkg.information(get_subject(p_id), project_pkg.get_summary(p_id)||' received timeline from FPS/QuickPlan.');
elsif message_pkg.is_error(p_payload) = 1
then
notice_pkg.debug(get_subject(p_id), project_pkg.get_summary(p_id)||' error while reading timeline from FPS/QuickPlan.');
end if;

end;

/**************************************************************************************************************/
procedure receive_placeholder_studies(p_id in nvarchar2, p_callback in varchar2 := null) as
v_payload xmltype;
v_msgid nvarchar2(100);
begin

-- Make XML message
select
xmlelement("callQPlan",
xmlattributes(
nsuri_ipms_qplan as "xmlns"
),
xmlelement("readPlaceholderStudies",
xmlattributes(
nvl(p.update_user_id, p.create_user_id) as "cwid",
p.id AS "projectId",
p.code AS "projectCode"
)
)
)
into v_payload
from project p
where p.id = p_id and p.code is not null;

-- TODO: Send message, log, receive callback

v_msgid :=
message_pkg.send(
get_subject(p_id),
v_payload,
'begin '||p_callback||' end;'
);

dbms_output.put_line('message.id='||v_msgid);
end;


end;
/