alter table import add (job_id nvarchar2(20) );
create index import_job_id_i on import (job_id);
comment on column import.job_id is 'Every Import should have unique Job ID. Based on this ID e-mail content (for failed import) is created.';