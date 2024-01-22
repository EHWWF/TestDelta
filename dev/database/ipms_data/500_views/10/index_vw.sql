create or replace view index_vw as
select
	table_name,
	index_name,
	listagg(column_name, ',') within group(order by column_position) as columns,
	count(*) cnt
from sys.user_ind_columns
group by table_name,index_name;
