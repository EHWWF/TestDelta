alter table ltc_instance add (timeline_id nvarchar2(20) references timeline(id) on delete cascade);
update ltc_instance ltci
set timeline_id = (
	select tl.id
	from timeline tl 
	where 
		ltci.project_id = tl.project_id and tl.type_code='RAW' 
		or 
		ltci.project_id is null and tl.id = (select snd_timeline_id from program_sandbox where id=ltci.sandbox_id)
);
commit;
alter table ltc_instance add (src_project_id nvarchar2(20) references project(id) on delete cascade);
update ltc_instance ltci
set src_project_id = (
	select id 
	from project prj
	where 
		ltci.project_id = prj.id
		or
		ltci.project_id is null and prj.id=(
			select sbx_src_tl.project_id
			from program_sandbox sbx
			inner join timeline sbx_src_tl on sbx_src_tl.id=sbx.timeline_id
			where sbx.id=ltci.sandbox_id
		)
);
commit;