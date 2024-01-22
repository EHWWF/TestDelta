create or replace view combination_vw as
select 
	pc.project_id,
	bc.code as combination_code,
	bc.name as combination_name
from
    (select 
		api.project_id,
      sc.combination_code
    from
      (
		select 
			prj.id as project_id,
			listagg(sb.substance_code, '|') within group (order by sb.substance_code) substance_key
      from project prj
      join project_substance_code sb on (prj.id=sb.project_id)
      group by prj.id
      ) api
    join
      (
		select
			sc.combination_code,
			listagg(substance_code, '|') within group (order by substance_code) substance_key
      from substance_combination sc
      group by sc.combination_code
      ) sc
    on sc.substance_key=api.substance_key
    join bay_number bc on (bc.code=sc.combination_code)
    ) pc
join bay_number bc
on bc.code=pc.combination_code;