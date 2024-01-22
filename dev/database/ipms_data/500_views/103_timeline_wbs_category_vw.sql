create or replace view timeline_wbs_category_vw as
select
	tl.id as timeline_id,
	nullif(xt.wbs_id, tl.reference_id) as wbs_id,
	xt.name as category_name,
	xt.object_id as category_object_id
from
	timeline tl,
	xmltable(
		xmlnamespaces(default 'http://xmlns.bayer.com/ipms'),
		'/timeline/wbsCategories/wbsCategory' passing tl.details
		columns 
			wbs_id nvarchar2(20) path '@wbsId',
			name nvarchar2(100) path 'name',
			object_id nvarchar2(100) path 'objectId'
	) xt
where tl.details is not null;