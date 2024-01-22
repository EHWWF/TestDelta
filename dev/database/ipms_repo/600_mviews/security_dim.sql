drop materialized view security_dim;

create materialized view security_dim as
select
	ur.program_id,
	ur.user_id as cwid,
	ur.role_code
from ipms_data.user_role ur;

grant select on security_dim to mycsd;