alter table ltc_estimate add(fct_prob_y1_cost number);
alter table ltc_estimate add(fct_prob_y2_cost number);
alter table ltc_estimate add(fct_prob_y3_cost number);
comment on column ltc_estimate.fct_prob_y1_cost is 'Forecast probabilistic costs for study level estimates required later for probabilistic calculation while submitting data to reporting. Data is being frozen along with deterministic in order to keep consistent data.';