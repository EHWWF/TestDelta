alter table latest_estimates_process add constraint prefill_lep_chk check(
  (cy_det_prefill_code='LE' and cy_det_prefill_lep_id is not null  or nvl(cy_det_prefill_code,-1) !='LE')
  and
  (ny_det_prefill_code='LE' and ny_det_prefill_lep_id is not null and is_next_year=1 or nvl(ny_det_prefill_code,-1) !='LE' or is_next_year=0)
);