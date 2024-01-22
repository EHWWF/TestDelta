create or replace view ltc_milestone_phase_vw as
  select
         timeline_id,
         project_id,
         timeline_type_code,
         milestone_code,
         phase_code,
         phase_name,
         phase_ordering,
         start_date,
         lead(start_date) over (partition by timeline_id order by phase_ordering)-1 finish_date,
         is_extra_phase,
         previous_milestone_cnt
  from
       (
       select
              ms.timeline_id,
              ms.project_id,
              ms.timeline_type_code,
              mp.milestone_code,
              mp.phase_code,
              ph.name                                                                                       phase_name,
              ph.ordering                                                                                   phase_ordering,
              trunc(min(decode(mp.milestone_code, ms.milestone_code, ms.milestone_date, null)), 'MONTH') as start_date,
              min(decode(mp.milestone_code, ms.milestone_code, 0, 1))                                       is_extra_phase,
              lead(min(decode(mp.milestone_code, ms.milestone_code, ms.milestone_date, null)), 1)
                  over (
                    partition by timeline_id
                    order by ph.ordering )                                                as finish_date,
              lag(min(decode(mp.milestone_code, ms.milestone_code, ms.milestone_date, null))) over (partition by ms.timeline_id order by ph.ordering) previous_start_date,
              lag(min(decode(mp.milestone_code, ms.milestone_code, 0, 1))) over (partition by timeline_id order by ph.ordering) previous_is_extra,
              sum(max(decode(mp.milestone_code,ms.milestone_code,1,0))) over (partition by timeline_id order by ph.ordering) previous_milestone_cnt
       from milestone_vw ms
              cross join ltc_milestone_phase_mapping mp
              join phase ph on ph.code = mp.phase_code and ph.is_active = 1
       where ms.timeline_type_code='RAW'
       group by ms.timeline_id, mp.milestone_code, mp.phase_code, ph.name, ph.ordering, ms.project_id,
                ms.timeline_type_code
       )
  where start_date is not null or (is_extra_phase = 1 and previous_milestone_cnt=0 and finish_date is not null and previous_start_date is  null);