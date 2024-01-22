drop materialized view program_dim;

create materialized view program_dim as
select
	pg.id,
	pg.code,
	pg.name,
	pg.substance,
	pg.description
from ipms_data.program pg;

grant select on program_dim to mycsd;