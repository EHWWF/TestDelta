create table therapeutic_research_group (
	code nvarchar2(256) constraint trg_pk primary key,
	name nvarchar2(256) constraint trg_name_cnn not null,
	create_date date constraint trg_create_date_cnn not null,
	update_date date constraint trg_update_date_cnn not null
);
comment on table therapeutic_research_group is 'Therapeutic Research Group. Lookup that is being imported along with D1 projects from sophia.';
alter table import_d1 modify trg_code nvarchar2(256);
merge into therapeutic_research_group dest
		using (
			select
				trg_code,
				max(decode(seq, 1, trg)) trg,
				sum(decode (seq, 1, srccnt, dstcnt)) iud
			from (
				select
					trg_code,
					trg,
					srccnt,
					dstcnt,
					row_number () over (partition by trg_code order by dstcnt nulls last) seq
				from (
					select
						trg_code,
						trg,
						count (src) srccnt,
						count (dst) dstcnt
					from (
						select
							code as trg_code,
							name as trg,
							to_number(null) src,2 dst
						from therapeutic_research_group
							union all
						select
							trg_code,
							trg,
							1 src,to_number(null) dst
						from import_d1 
						where trg_code is not null 
						group by trg_code,trg
					)
					group by
							trg_code,
							trg
					having count (src) <> count (dst)
				)
			)
			group by trg_code
		) diff
		ON (dest.code = diff.trg_code)
		WHEN MATCHED
		THEN
			 UPDATE SET
				dest.name = diff.trg
				,dest.update_date = sysdate
			 --DELETE WHERE (diff.iud = 0)
		WHEN NOT MATCHED
		then
			 insert (code,name,create_date,update_date)
			 values (diff.trg_code,diff.trg,sysdate,sysdate);
commit;
alter table project modify trg nvarchar2(256);