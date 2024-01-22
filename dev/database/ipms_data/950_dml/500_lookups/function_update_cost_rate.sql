prompt ---->
prompt ---->
prompt 
prompt ---->START    function
prompt 
prompt ---->for more info see jira: BAY_PROMIS-167
prompt ---->
SET SCAN OFF;
update function set cost_rate=0.125 where code='111' and nvl(cost_rate,-1)<>0.125;
update function set cost_rate=0.2 where code='15' and nvl(cost_rate,-1)<>0.2;
update function set cost_rate=0.15 where code='44' and nvl(cost_rate,-1)<>0.15;
commit;
prompt ---->END    function
prompt ---->
prompt ---->