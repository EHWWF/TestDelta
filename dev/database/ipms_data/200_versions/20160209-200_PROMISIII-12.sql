alter table project add(D2_PLANNED_DATE date, D2_ACHIEVED_DATE date);
rename phase_transition_d3 to phase_transition;
alter table project add(PTR_FOR_D2_CODE nvarchar2(15) references phase_transition);