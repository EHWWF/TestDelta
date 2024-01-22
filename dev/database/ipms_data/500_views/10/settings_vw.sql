create or replace view settings_vw as
select
	'FM99999999999999999999D9999999999' as number_fmt,
	'YYYY-MM-DD"T"HH24:MI:SS' as date_fmt,
	19 as date_len,
	'NLS_NUMERIC_CHARACTERS=''. ''' as nlsparam
from dual;
