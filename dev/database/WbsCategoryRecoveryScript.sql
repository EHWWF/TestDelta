-- Check critical deployment date
select * from sys_deployment where unique_name like '%20180418-100_wbs_category.sql'


-- Prepare data structure as a stanging to transfer wbs categories from baseline to timeline

drop table timeline_wbs_cat_recovery;
create table timeline_wbs_cat_recovery (timeline_id varchar2(200), baseline_id varchar2(100),  wbs_code varchar2(200), wbs_name varchar2(1000), study_id varchar2(100), wbs_cat_object_id varchar2(100), is_cat_available number(1) default 0);
-- Make backup of baselines. As certain (latest untill critical deployment which erased wbs categories) baselines will be refreshed to receive wbs categories included.
drop table timeline_baseline_bck;
create table timeline_baseline_bck as select * from timeline_baseline;
select * from timeline_baseline_bck;

------------------------

-- Load data from baseline to staging table
---- Clean relevant baseline details
update timeline_baseline set details = null where id in
(select distinct first_value(id) over (partition by timeline_id order by create_date_p6 desc) baseline_id from timeline_baseline t where timeline_id like '%-RAW'
and create_date_p6 <= to_date('2018-06-07', 'YYYY-MM-DD') /*and timeline_id='87-136-RAW'*/); commit;

---- Check how many baselines were marked for refresh
select count(*) from timeline_baseline where details is null;

-- Check whether there are any locked relevant timelines
select count(*) from tieline where id in (select timeline_id from timeline_baseline where details is null);

---- Receive new baseline details (WBS category included)
begin baseline_pkg.get_missing_baselines(); commit; end;

--Check whether all relevant baselines refreshed
select count(*) from timeline_baseline where details is null;

-- Extract wbs categories from baeline and put into temp table
begin wbs_cat_recovery.extract_wbs_cat_baseline(p_threshold_date =>to_date('2018-05-15', 'YYYY-MM-DD'), p_timeline_id=>null); commit; end;

-- Refresh all relevant timelines to have most recent data
begin wbs_cat_recovery.refresh_relevant_timeline; commit; end;

-- Check all relevant timelines to be refreshed
select distinct timeline_id from timeline_wbs_cat_recovery wcr join timeline tml on tml.id = wcr.timeline_id where tml.is_syncing=1

-- Mark wbs which already have categories set
begin wbs_cat_recovery.mark_available_categories; commit; end;

-- Check available wbs categories in recovery table
select * from timeline_wbs_cat_recovery;

--Unlock all relevant timelines
update timeline set is_syncing=0 where id in (select distinct timeline_id from timeline_wbs_cat_recovery wcr ); commit;

--extract_wbs_cat_baseline;
begin wbs_cat_recovery.send_category(null); end;

-- Check timelines still syncing
select distinct timeline_id from timeline_wbs_cat_recovery wcr join timeline tml on tml.id = wcr.timeline_id where tml.is_syncing=1




