alter table latest_estimate add estimate_det_old_curr_year number(20,10);
alter table latest_estimate add estimate_det_old_next_year number(20,10);
alter table latest_estimate add is_prefilled_old number(1,0) default 0 constraint le_is_prefilled_old_cnn not null constraint le_is_prefilled_old_ca check(is_prefilled_old in (0,1));
comment on column latest_estimate.estimate_det_old_curr_year is 'LE value <deterministic current year> taken from old process based on user selection while starting LE. The field was added based on reqeirement: PROMIS-466';
comment on column latest_estimate.estimate_det_old_next_year is 'LE value <deterministic next year> taken from old process based on user selection while starting LE. The field was added based on reqeirement: PROMIS-466';
comment on column latest_estimate.is_prefilled_old is 'The flag indicating if the prefill of old values was done for this concrete record. The field was added based on reqeirement: PROMIS-466';