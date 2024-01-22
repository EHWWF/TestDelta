create or replace view timeline_wbs_category_vw as
select
	tl.id as timeline_id,
	nullif(xt.wbs_id, tl.reference_id) as wbs_id,
	xt.name as category_name
from
	timeline tl,
	xmltable(
		xmlnamespaces(default 'http://xmlns.bayer.com/ipms'),
		'/timeline/wbsCategories/wbsCategory' passing tl.details
		columns 
			wbs_id nvarchar2(20) path '@wbsId',
			name nvarchar2(100) path 'name'
	) xt
where tl.details is not null;
create table timeline_wbs_category as
select * from timeline_wbs_category_vw;
create index timeline_wbs_category_idx1 on timeline_wbs_category (timeline_id);
create index timeline_wbs_category_idx2 on timeline_wbs_category (wbs_id);