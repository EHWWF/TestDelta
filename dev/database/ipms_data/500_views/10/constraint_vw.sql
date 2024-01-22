create or replace view constraint_vw as
select
	b.table_name,
	b.constraint_name,
	b.constraint_type,
	listagg(column_name, ',') within group(order by a.position) as columns,
	count(*) cnt
from sys.user_cons_columns a
join sys.user_constraints b on a.constraint_name = b.constraint_name
group by b.table_name, b.constraint_name, b.constraint_type;
