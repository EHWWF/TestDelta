create or replace view combase_project_vw as
  select
	to_nchar(nvl(btcp.pjx_no, x8.project_id)) as project_id,
	x8.bay_code,
	x8.sbe_code,
	x8.gbu_code,
	x8.ipowner_code,
	x8.subgroup_code,
	x8.successor_id,
	x8.modify_date,
	x8.project_name,
	x8.accounting_status_code,
	x8.program_code,
	x8.program_name,
	x8.planning_enabled_code,
	btcp.bt_no collaboration_code,
	x8.project_group_code
from (
select
	to_nchar(nvl(btpe.pjx_no, x7.project_id)) as project_id,
	x7.bay_code,
	x7.sbe_code,
	x7.gbu_code,
	x7.ipowner_code,
	x7.subgroup_code,
	x7.successor_id,
	x7.modify_date,
	x7.project_name,
	x7.accounting_status_code,
	x7.program_code,
	x7.program_name,
	btpe.bt_no planning_enabled_code,
	x7.project_group_code
from (
select
	to_nchar(nvl(xcl.pjx_no, x6.project_id)) as project_id,
	x6.bay_code,
	x6.sbe_code,
	x6.gbu_code,
	x6.ipowner_code,
	x6.subgroup_code,
	x6.successor_id,
	x6.modify_date,
	x6.project_name,
	x6.accounting_status_code,
	nvl(xcl.xcl_code,xcl.xcl_no) program_code, --better to have old program ID than null
	xcl.program_name,
	x6.project_group_code
from (
select
	to_nchar(nvl(btas.pjx_no, x5.project_id)) as project_id,
	x5.bay_code,
	x5.sbe_code,
	x5.gbu_code,
	x5.ipowner_code,
	x5.subgroup_code,
	x5.successor_id,
	x5.modify_date,
	x5.project_name,
	btas.bt_no accounting_status_code,
	x5.project_group_code
from (
select
	to_nchar(nvl(pjx.pjx_no, x4.project_id)) as project_id,
	x4.bay_code,
	x4.sbe_code,
	x4.gbu_code,
	x4.ipowner_code,
	x4.subgroup_code,
	x4.successor_id,
	x4.modify_date,
	pjx.pjx_name project_name,
	x4.project_group_code
from (
select
	to_nchar(nvl(pjn.pjx_no, x3.project_id)) as project_id,
	bay_code,
	sbe_code,
	gbu_code,
	ipowner_code,
	subgroup_code,
	pjn.pjn_no as successor_id,
	greatest(nvl(pjn.modify_date,sysdate-36500),nvl(x3.modify_date,sysdate-36500)) as modify_date,
	project_group_code
from (
			select
				to_nchar(nvl(xgs.pjx_no, x2.project_id)) as project_id,
				bay_code,
				sbe_code,
				gbu_code,
				ipowner_code,
				xgs.xgs_code as subgroup_code,
				greatest(nvl(xgs.modify_date,sysdate-36500),nvl(x2.modify_date,sysdate-36500)) as modify_date,
				xgs.xgs_code as project_group_code
			from (
					select
						to_nchar(nvl(xip.pjx_no, x1.project_id)) as project_id,
						bay_code,
						sbe_code,
						gbu_code,
						xip.xip_no as ipowner_code,
						greatest(nvl(xip.modify_date,sysdate-36500),nvl(x1.modify_date,sysdate-36500)) as modify_date
							from (
									select
										to_nchar(nvl(bay.pjx_no, xbe.pjx_no)) as project_id,
										bay.bay_no as bay_code,
										xbe.code as sbe_code,
										xbe.gbu_code as gbu_code,
										greatest(nvl(bay.modify_date,sysdate-36500),nvl(xbe.modify_date,sysdate-36500)) as modify_date
									from (
											select bay.*
											from bdr_pjx_bay@combase_db bay
											where bay.status='ACTIVE'
											) bay
											full outer join (
												select
													xbe.*,
													sbe.code,
													sbe.gbu_code
												from bdr_pjx_xbe@combase_db xbe
												join combase_sbe_vw sbe on sbe.xbe_no=xbe.xbe_no and sbe.is_active=1
												where xbe.status='ACTIVE'
											) xbe on bay.pjx_no=xbe.pjx_no
									) x1
					full outer join (select xip.*
											from bdr_pjx_xip@combase_db xip
											where xip.status='ACTIVE'
											) xip on x1.project_id=xip.pjx_no
					) x2
				full outer join (
						select
							to_nchar(nvl(xgs.xgs_no, sg.xgs_no)) as xgs_no,
							xgs.pjx_no,
							xgs.status,
							sg.xgs_code,
							sg.xgs_name,
							greatest(nvl(xgs.modify_date,sysdate-36500),nvl(sg.modify_date,sysdate-36500)) as modify_date
						from (
								select xgs.*
								from bdr_pjx_xgs@combase_db xgs
								where xgs.status='ACTIVE'
								) xgs
						full outer join (
								select sg.*
								from bdo_subgroup@combase_db sg
								where sg.status='ACTIVE'
								) sg on xgs.xgs_no=sg.xgs_no
			) xgs on x2.project_id=xgs.pjx_no
		) x3
full outer join
(
	select
		pjn.*
	from bdr_pjx_pjn@combase_db pjn
	where pjn.status='ACTIVE'
) pjn on x3.project_id=pjn.pjx_no
) x4
join bdo_project@combase_db pjx on pjx.pjx_no=x4.project_id and pjx.status = 'ACTIVE') x5
full outer join
(
	select btas.*
	from bdr_pjx_bt_as@combase_db btas
	where btas.status='ACTIVE'
) btas on x5.project_id=btas.pjx_no
) x6
full outer join
(
	select
		xcl.*,
		pg.xcl_code,
		substr(pg.xcl_name,1,100) program_name
	from bdr_pjx_xcl@combase_db xcl
	join bdo_program@combase_db pg on (xcl.xcl_no=pg.xcl_no and pg.status='ACTIVE')
	where xcl.status='ACTIVE'
) xcl on x6.project_id=xcl.pjx_no
) x7
full outer join
(
	select btpe.*
	from bdr_pjx_bt_pe@combase_db btpe
	where btpe.status='ACTIVE'
) btpe on x7.project_id=btpe.pjx_no
) x8
full outer join
(
	select
		btcp.*
	from bdr_pjx_bt_cp@combase_db btcp
	where btcp.status='ACTIVE'
) btcp on x8.project_id=btcp.pjx_no;

drop table combase_project_tmp;

create global temporary table combase_project_tmp
on commit delete rows
as (select * from combase_project_vw where 1=0);

create index combase_project_tmp_idx1 on combase_project_tmp(project_id);