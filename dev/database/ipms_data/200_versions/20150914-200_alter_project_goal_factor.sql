ALTER TABLE PROJECT_GOAL_FACTOR modify goal_factor number not null;

ALTER TABLE PROJECT_GOAL_FACTOR 
 ADD CONSTRAINT prj_goal_factor_not_1 CHECK (goal_factor <> 1);