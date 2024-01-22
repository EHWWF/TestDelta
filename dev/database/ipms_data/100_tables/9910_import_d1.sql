create table import_d1
(
import_id nvarchar2(20) not null,
project_id number not null primary key,
project_name nvarchar2(100),
project_phase_no number,
project_phase nvarchar2(250),
trg_code nvarchar2(60),
trg nvarchar2(250),
er nvarchar2(250),
target_gene_code nvarchar2(250),
d2_compound nvarchar2(80),
start_hts_date date,
general_project_frame nvarchar2(250),
status nvarchar2(10),
modifier nvarchar2(32),
modify_date date,
isnew nvarchar2(1),
status_code nvarchar2(10) default 'NEW' not null,
status_description nvarchar2(500),
create_date date default sysdate not null,
update_date date
);