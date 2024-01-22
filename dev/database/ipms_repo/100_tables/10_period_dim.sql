create table period_dim as
select rownum id, year, month
from
(
	select level+2000 year
	from dual
	connect by level <= 50
) year,
(
	select level month
	from dual
	connect by level <= 12
) month;