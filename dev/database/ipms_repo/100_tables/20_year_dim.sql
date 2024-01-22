create table year_dim as
select level+2000 as year
from dual
connect by level <= 100;