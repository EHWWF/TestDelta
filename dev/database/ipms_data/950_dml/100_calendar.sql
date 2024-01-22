truncate table calendar_month;
insert into calendar_month
with
	params as (
		select
			trunc(min(mn), 'yy') - interval '5' year as start_date,
			trunc(max(mx), 'yy') + interval '5' year - 1/24/60/60 as finish_date
		from (
			select min(start_date) mn, max(finish_date) mx from costs
			union
			select min(start_date), max(finish_date) from costs_fps
			union
			select min(start_date), max(finish_date) from timeline
			union
			select min(start_date), max(finish_date) from timeline_wbs
			union
			select sysdate - interval '15' year, sysdate + interval '15' year from dual
		)
	)
select
	extract(year from start_date)*100+extract(month from start_date) as id,
	start_date,
	add_months(start_date, 1)-1/24/60/60 as finish_date,
	extract(year from start_date) as yyyy,
	extract(month from start_date) as mm
from (	
	select add_months(start_date, rownum-1) as start_date
	from params
	connect by rownum-1 <= months_between(finish_date, start_date)
);
commit;
truncate table calendar_year;
insert into calendar_year
select 
	yyyy as id,
	min(trunc(start_date, 'yyyy')) as start_date,
	add_months(min(trunc(start_date, 'yyyy')), 12)-1/24/60/60 as finish_date,
	yyyy
from calendar_month
group by yyyy
order by 1;
commit;