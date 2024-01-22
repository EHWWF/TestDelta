alter table latest_estimates_process drop (CY_PROB_PREFILL_CODE,NY_PROB_PREFILL_CODE,CY_PROB_PREFILL_LEP_ID,NY_PROB_PREFILL_LEP_ID,IS_FORECAST_PROB,IS_PREFILL_PROB);
alter table latest_estimates_process drop (is_last);

alter table latest_estimates_tag add(previous_let_id nvarchar2(45) references latest_estimates_tag(id));

merge into latest_estimates_tag let
using(
select id,
	 LAG(id, 1, null) OVER (ORDER BY id) AS prev_id
from latest_estimates_tag 
) src
on (src.id=let.id)
when matched then 
update set previous_let_id=src.prev_id;
commit;