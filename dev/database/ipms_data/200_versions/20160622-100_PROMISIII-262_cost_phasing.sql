alter table costs_fps add (decision_start nvarchar2(12));
comment on column costs_fps.decision_start is 'The value of decision_start ProMIS gets from e.g. sophia_import.fps_cost_forecast.decision_start';
