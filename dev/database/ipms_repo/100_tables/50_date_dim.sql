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