--create table import_excel20161011 as select * from import_excel;
--drop table import_excel;
create table import_excel 
(
 column1 nvarchar2(512) 
, column2 nvarchar2(512) 
, column3 nvarchar2(512) 
, column4 nvarchar2(512) 
, column5 nvarchar2(512) 
, column6 nvarchar2(512) 
, column7 nvarchar2(512) 
, column8 nvarchar2(512) 
, column9 nvarchar2(512) 
, column10 nvarchar2(512) 
, column11 nvarchar2(512) 
, column12 nvarchar2(512) 
, column13 nvarchar2(512) 
, column14 nvarchar2(512) 
, column15 nvarchar2(512) 
, column16 nvarchar2(512) 
, column17 nvarchar2(512) 
, column18 nvarchar2(512) 
, column19 nvarchar2(512) 
, column20 nvarchar2(512) 
, column21 nvarchar2(512) 
, column22 nvarchar2(512) 
, column23 nvarchar2(512) 
, column24 nvarchar2(512) 
, column25 nvarchar2(512) 
, column26 nvarchar2(512) 
, column27 nvarchar2(512) 
, column28 nvarchar2(512) 
, column29 nvarchar2(512) 
, create_date date default sysdate not null 
, status nvarchar2(4000) 
, ref_id nvarchar2(20)
, file_name nvarchar2(256)
, id number
);
--update import_excel set file_name='D2' where file_name is null;