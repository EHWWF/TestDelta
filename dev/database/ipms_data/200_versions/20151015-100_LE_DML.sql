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