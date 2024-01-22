alter table ltc_estimate rename column lt_y1_cost_previous to fct_y1_cost;
alter table ltc_estimate rename column lt_y2_cost_previous to fct_y2_cost;
alter table ltc_estimate rename column lt_y3_cost_previous to fct_y3_cost;
comment on column ltc_estimate.fct_y1_cost is 'Forecast from profit for year 1';
comment on column ltc_estimate.fct_y2_cost is 'Forecast from profit for year 2';
comment on column ltc_estimate.fct_y3_cost is 'Forecast from profit for year 3';