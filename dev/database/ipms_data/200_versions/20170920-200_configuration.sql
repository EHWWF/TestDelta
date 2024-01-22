merge into configuration cfg
using (
		select forecast_year,forecast_month,forecast_number,forecast_version from (
		select cc.*, rownum as rank
		 from (
		select forecast_year,forecast_month,forecast_number,forecast_version, count(1) ccc 
		from costs where is_last_forecast=1 
		group by forecast_year,forecast_month,forecast_number,forecast_version
		order by forecast_year desc,forecast_month desc,forecast_number desc,forecast_version desc
		) cc ) where rank=1
	) fct on (cfg.code in ('LAST-FCT-MONTH','LAST-FCT-YEAR','LAST-FCT-NUM','LAST-FCT-VER'))
when matched then
update set
	cfg.value=nvl(cfg.value,decode
		(
		cfg.code,
		'LAST-FCT-MONTH',fct.forecast_month,
		'LAST-FCT-YEAR',fct.forecast_year,
		'LAST-FCT-NUM',fct.forecast_number,
		'LAST-FCT-VER',fct.forecast_version,
		cfg.value
		))
;