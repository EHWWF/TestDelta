alter table ltc_tag add forecast_year number;
alter table ltc_tag add forecast_month number;
alter table ltc_tag add forecast_number number;
alter table ltc_tag add forecast_version number;
create index ltc_tag_forecast_year_idx on ltc_tag(forecast_year);
create index ltc_tag_forecast_month_idx on ltc_tag(forecast_month);
create index ltc_tag_forecast_number_idx on ltc_tag(forecast_number);
create index ltc_tag_forecast_version_idx on ltc_tag(forecast_version);
comment on column ltc_tag.forecast_year is 'Soft reference to ProFIT data taken from e.g.: forecast_year.cost_forecast@sophia_db.';
comment on column ltc_tag.forecast_month is 'Soft reference to ProFIT data taken from e.g.: forecast_month.cost_forecast@sophia_db.';
comment on column ltc_tag.forecast_number is 'Soft reference to ProFIT data taken from e.g.: forecast_number.cost_forecast@sophia_db.';
comment on column ltc_tag.forecast_version is 'Soft reference to ProFIT data taken from e.g.: forecast_version.cost_forecast@sophia_db.';
merge into ltc_tag trg using --this update make sense only at DEVatBayer
(
select forecast_year,forecast_month,forecast_number,forecast_version from (
select cc.*, rownum as rank
 from (
select forecast_year,forecast_month,forecast_number,forecast_version, count(1) ccc 
from costs where is_last_forecast=1 
group by forecast_year,forecast_month,forecast_number,forecast_version
order by forecast_year desc,forecast_month desc,forecast_number desc,forecast_version desc
) cc ) where rank=1
) src
on (1=1)--trg.forecast_year is null and trg.forecast_month is null and trg.forecast_number is null and trg.forecast_version is null)
when matched then update set
	trg.forecast_year=nvl(trg.forecast_year,src.forecast_year),
	trg.forecast_month=nvl(trg.forecast_month,src.forecast_month),
	trg.forecast_number=nvl(trg.forecast_number,src.forecast_number),
	trg.forecast_version=nvl(trg.forecast_version,src.forecast_version)
;
commit;