create table year_dim as
select level+2000 as year
from dual
connect by level <= 100;

create table quarter_dim as
select
	level as quarter_id,
	'Q'||level as quarter_desc
from dual
connect by level <= 4;

create table month_dim as
select rownum as period_id, mm.* from (
	select
		yy.year,
		qr.quarter_id,
		mm.month_id as month_of_year,
		mm.month_desc
	from year_dim yy
	cross join quarter_dim qr
	join (
		select
			level as month_id,
			trunc((level - 1) / 3) + 1 as quarter_id,
			initcap(to_char(to_date(level||'-01','MM-dd'), 'MONTH')) as month_desc
		from dual
		connect by level <= 12
	) mm on mm.quarter_id = qr.quarter_id
	order by year,month_of_year
) mm;

create table date_dim as
select
	mm.period_id,
	dd.day_of_month,
	to_date(mm.year||'-'||mm.month_of_year||'-'||dd.day_of_month, 'yyyy-mm-dd') as date_desc
from month_dim mm
join (
	select level as day_of_month
	from dual
	connect by level <= 31
) dd on dd.day_of_month <= cast(to_char(last_day(to_date(mm.year||'-'||mm.month_of_year||'-01', 'yyyy-mm-dd')), 'dd') as int)
order by mm.year, mm.month_of_year ,dd.day_of_month;

create or replace view period_dim as select * from month_dim;