alter table qplan_element_type
add constraint qplan_element_type_fk1 foreign key
(
  milestone_code 
)
references milestone
(
  code 
)
enable;