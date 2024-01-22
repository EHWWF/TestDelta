create table quarter_dim as
select
	level as quarter_id,
	'Q'||level as quarter_desc
from dual
connect by level <= 4;
