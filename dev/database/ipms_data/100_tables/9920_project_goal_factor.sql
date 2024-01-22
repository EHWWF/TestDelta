CREATE TABLE PROJECT_GOAL_FACTOR 
(PROJECT_ID NVARCHAR2(20), 
 MILESTONE_CODE NVARCHAR2(20), 
 GOAL_FACTOR NUMBER, 
 PRIMARY KEY (PROJECT_ID)
);

COMMENT ON COLUMN PROJECT_GOAL_FACTOR.MILESTONE_CODE IS 'Accordint to the fact that (virtual code) TERMINATION has no Milestone Code in P6 but the column must store termination factor as well for termination, thus, FC ref. could not be used here.';