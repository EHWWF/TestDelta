alter table goal add (is_manual_status number(1) default 0 constraint goal_is_manual_status_cnn not null constraint goal_is_manual_status_chk check (is_manual_status in (1,0)));