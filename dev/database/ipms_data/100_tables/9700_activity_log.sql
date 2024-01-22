create table guid (id nvarchar2(100) primary key, user_id nvarchar2(20), ba_code nvarchar2(100), create_date date default sysdate);

create table guid_transaction (guid nvarchar2(100) references guid(id), transaction_id nvarchar2(100));
