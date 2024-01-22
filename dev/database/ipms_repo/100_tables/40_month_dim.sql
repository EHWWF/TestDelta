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
