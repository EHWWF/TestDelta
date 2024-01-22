create table business_activity (
code nvarchar2(50), 
name nvarchar2(400), 
category_id nvarchar2(20),
constraint business_activity_pk primary key (code),
constraint business_activity_lower_code check (code=lower(code))
);