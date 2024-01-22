drop materialized view timeline;
create materialized view timeline as
select
	cast(project_id as varchar2(20)) project_id,
	cast(plan_type as varchar2(10)) plan_type,
	cast(plan_id as varchar2(20)) plan_id,
	cast(root_timeline_id as varchar2(20)) root_timeline_id,
	cast(plan_object_id as varchar2(20)) plan_object_id,
	cast(program_id as varchar2(10)) program_id,
	cast(sandbox_id as varchar2(20)) sandbox_id,
	cast(plan_name as varchar2(100)) plan_name,
	cast(baseline_type_id as varchar2(20)) baseline_type_id,
	cast(baseline_type_name as varchar2(200)) baseline_type_name,
	ltci_id,
	ltc_process_id,
	create_date_p6,
	cast(comments as varchar2(500)) comments
from (
	select
		nvl(psbx.src_project_id, t.project_id) as project_id,
		t.type_code as plan_type,
		t.id as plan_id,
		t.id as root_timeline_id,
		t.reference_id as plan_object_id,
		nvl(p.program_id,psbx.program_id) program_id,
		psbx.sandbox_id,
		t.name as plan_name,
		t.baseline_type_id,
		bt.name as baseline_type_name,
		t.ltci_id,
		t.ltc_process_id,
		t.create_date_p6,
		t.comments
	from ipms_data.timeline t
	left join (
		select 
			sbx.id as sandbox_id,
			sbx.program_id,
			sbx.snd_timeline_id as timeline_id, 
			sbx.timeline_id as src_timeline_id, 
			sbx_src_tl.project_id as src_project_id 
		from ipms_data.program_sandbox sbx
		inner join ipms_data.timeline sbx_src_tl on sbx_src_tl.id=sbx.timeline_id
	) psbx on psbx.timeline_id=t.id and t.type_code='SND'
	left join ipms_data.project p on (t.project_id=p.id)
	left join ipms_data.baseline_type bt on (t.baseline_type_id=bt.id)
		union all
	select 
		t.project_id,
		to_nchar('BSL') as plan_type,
		replace(replace(replace(tb.timeline_id,'-RAW'),'-CUR'),'-APR')||'-'||tb.id||'-BSL' plan_id,
		tb.timeline_id as root_timeline_id,
		tb.id plan_object_id,
		p.program_id,
		null as sandbox_id,
		to_nchar('Created: '||to_char(tb.create_date_p6,'dd-mm-yyyy hh24:mi:ss')) as plan_name,
		tb.baseline_type_id,
		bt.name as baseline_type_name,
		tb.ltci_id,
		tb.ltc_process_id,
		tb.create_date_p6,
		tb.description as comments
	from ipms_data.timeline_baseline tb
	join ipms_data.timeline t on (t.id=tb.timeline_id)
	join ipms_data.project p on (t.project_id=p.id)
	left join ipms_data.baseline_type bt on (tb.baseline_type_id=bt.id)
);
grant select on timeline to mycsd;