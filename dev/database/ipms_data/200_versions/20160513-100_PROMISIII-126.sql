alter table function add (top_function_code nvarchar2(10) references top_function(code));

insert into top_function (code, name, is_active, valid_from,valid_to,create_date)
select
	to_number(kfu1_no) code,
	to_nchar(kfu1_name) name,
	1,
	valid_from,
	valid_to,
	sysdate
from masterdata.bdo_costcenter_function_top@combase_db
where valid_from<=sysdate
and nvl(valid_to,sysdate+1)>sysdate
and status='ACTIVE';

update top_function set abbreviation='D' where code='3';
update top_function set abbreviation='DD' where code='4';

merge into function dst
using (
	select to_number(kfu1_no) top_code, to_number(kfu2_no) main_code from masterdata.bdr_kfu_t_kfu_m@combase_db
	where valid_from<=sysdate
		and nvl(valid_to,sysdate+1)>sysdate
		and status='ACTIVE'
		and to_number(kfu1_no) in (select code from top_function)--only update the once that have parent key in TOP_Function
) src
on (to_nchar(src.main_code)=dst.code)
when matched then
update set dst.top_function_code=src.top_code;

commit;