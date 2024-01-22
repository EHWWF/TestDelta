drop materialized view project_news_dim;

create materialized view project_news_dim as
select
	news.id,
	news.project_id,
	news.text,
	news.event_date,
	news.category_code,
	category.name as category
from ipms_data.news news
left join ipms_data.news_category category on category.code = news.category_code;

grant select on project_news_dim to mycsd;