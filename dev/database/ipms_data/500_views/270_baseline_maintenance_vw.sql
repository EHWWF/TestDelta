create or replace view baseline_maintentance_vw as
with
	msg as (
		select
			msg.*,
			extractValue(msg.response.extract('/*/*'), 'local-name()') as response_tag
		from message msg
		where subject like 'delete:baselines:%'
	)
select 
	substr(subject, 18, length(subject)-18-4+1) as project_id,
	substr(subject, 18) as timeline_id,
	substr(subject, -3) as timeline_type_code,
	decode(response_tag, 'error', 'FAIL', 'complete', 'DONE', 'SEND') as status_code,
	xt.name as baseline_name,
	cast(xt.create_date as date) as baseline_create_date,
	msg.request_date as create_date,
	msg.response_date as update_date
from msg
left join xmltable(
		xmlnamespaces(default 'http://xmlns.bayer.com/ipms'),
		'//baselines/baseline' passing msg.response
		columns 
			name			nvarchar2(100)	path 'name',
			create_date		timestamp 		path 'createDate'
	) xt on 1=1
order by project_id, baseline_create_date;

create view baseline_maintentance as select * from baseline_maintentance_vw;--TODO: must be deleted after deleting the usage