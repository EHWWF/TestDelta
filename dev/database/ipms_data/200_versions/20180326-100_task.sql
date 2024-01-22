create table task (
  id number constraint tsk_pk primary key,
  task_number nvarchar2(50) constraint tsk_task_number_cnn not null,
  title nvarchar2(2000),
  comments nvarchar2(2000),
  priority nvarchar2(50),
  state nvarchar2(50) constraint tsk_state_cnn not null,
  outcome nvarchar2(50),
  definition_name nvarchar2(200) constraint tsk_def_name_cnn not null,
  task_created_date date constraint tsk_task_created_date_cnn not null,
  expiration_date date,
  create_date date constraint tsk_create_date_cnn not null,
  update_date date,
  assumption_request_id nvarchar2(20) constraint tsk_plan_assumpt_req_id_fk references plan_assumption_request(id),
  process_id nvarchar2(50),
  program_id nvarchar2(10) constraint tsk_program_id_fk references program(id),
  project_id nvarchar2(20) constraint tsk_project_id_fk references project(id)
);

comment on table task is 'Table for saving workitems (tasks), created by BPM engine';

create sequence task_id_seq maxvalue 9999999999999999999 minvalue 1 cycle;

create index task_idx1 on task(process_id);
create index task_idx2 on task(project_id);
create index task_idx3 on task(program_id);
create index task_idx4 on task(definition_name);
create index task_idx5 on task(assumption_request_id);