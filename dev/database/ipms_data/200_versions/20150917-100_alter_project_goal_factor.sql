alter table project_goal_factor 
  add constraint prj_goal_factor_prj_mlcode_uq UNIQUE (project_id, milestone_code);