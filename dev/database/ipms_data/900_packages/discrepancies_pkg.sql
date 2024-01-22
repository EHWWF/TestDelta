create or replace package discrepancies_pkg as

	procedure refresh_dis_study_mview;

end;
/
create or replace package body discrepancies_pkg as

	/*************************************************************************/
	procedure refresh_dis_study_mview as
		v_rowcount number;
		v_count_view number;
		v_count_tab number;
	begin

		merge into dis_study_mview dest
		using (
			select
				project_id,--max(decode (seq, 1, project_id)) project_id,
				study_id,--max(decode (seq, 1, study_id)) study_id,
				study_element_id,--max(decode (seq, 1, study_element_id)) study_element_id,
				max(decode (seq, 1, plan_start_date)) plan_start_date,
				max(decode (seq, 1, plan_finish_date)) plan_finish_date,
				max(decode (seq, 1, act_start_date)) act_start_date,
				max(decode (seq, 1, act_finish_date)) act_finish_date,
				sum(decode (seq, 1, srccnt, dstcnt)) iud
			from (
				select
					project_id,study_id,study_element_id,plan_start_date,plan_finish_date,act_start_date,act_finish_date,
					srccnt, dstcnt,row_number() over (partition by project_id,study_id,study_element_id order by dstcnt nulls last) seq
				from (
					select
						project_id,study_id,study_element_id,plan_start_date,plan_finish_date,act_start_date,act_finish_date
						,count (src) srccnt, count (dst) dstcnt
					from (
						select
							project_id,study_id,study_element_id,plan_start_date,plan_finish_date,act_start_date,act_finish_date,
							1 src, to_number (null) dst
						from (
						select
							to_nchar(cmb.project_id) as project_id,
							to_nchar(cmb.study_id) as study_id,
							to_nchar(tl.study_element_id) as study_element_id,--the source type has changed from Number to Varchar but this: to_nchar can stay as it is: PROMISIII-414
							tl.plan_start_date,
							tl.plan_finish_date,
							tl.act_start_date,
							tl.act_finish_date
						from combase_study_vw cmb
						left join timeline@sophia_db tl on (cmb.project_id=to_char(tl.project_id) and cmb.study_id=to_char(tl.study_id))
						)

						union all

						select
							project_id,study_id,study_element_id,plan_start_date,plan_finish_date,act_start_date,act_finish_date,
							to_number(null) src, 2 dst
						from dis_study_mview
					)
					group by project_id,study_id,study_element_id,plan_start_date,plan_finish_date,act_start_date,act_finish_date
					having count (src) <> count (dst)
				)
			)
			group by project_id,study_id,study_element_id
		) diff
		on (nvl(dest.project_id,'#') = nvl(diff.project_id,'#') and nvl(dest.study_id,'#') = nvl(diff.study_id,'#')  and nvl(dest.study_element_id,'#') = nvl(diff.study_element_id,'#') )
		when matched
		then
			 update set
				  --dest.project_id = diff.project_id
				 --,dest.study_id = diff.study_id
				 --,dest.study_element_id = diff.study_element_id
				 dest.plan_start_date = diff.plan_start_date
				 ,dest.plan_finish_date = diff.plan_finish_date
				 ,dest.act_start_date = diff.act_start_date
				 ,dest.act_finish_date = diff.act_finish_date
				 ,update_date=sysdate
			 delete
					where (diff.iud = 0)
		when not matched
		then
			 insert (project_id,study_id,study_element_id,plan_start_date,plan_finish_date,act_start_date,act_finish_date,create_date)
			 values (diff.project_id,diff.study_id,diff.study_element_id,diff.plan_start_date,diff.plan_finish_date,diff.act_start_date,diff.act_finish_date,sysdate);

		v_rowcount:=sql%rowcount;

		select count(1) into v_count_tab from dis_study_mview;

		select count(1) into v_count_view
		from combase_study_vw cmb
		left join timeline@sophia_db tl on (cmb.project_id=to_char(tl.project_id) and cmb.study_id=to_char(tl.study_id));

		log_pkg.log('discrepancies_pkg.refresh_dis_study_mview', 'v_count_view='||v_count_view||';v_count_tab='||v_count_tab||';v_rowcount='||v_rowcount,'Updated.');


	exception when others then
		log_pkg.log('discrepancies_pkg.refresh_dis_study_mview', 'v_rowcount='||v_rowcount, sqlerrm);

	end;

end;
/