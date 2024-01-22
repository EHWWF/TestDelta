create or replace force view message_error_code_vw as
select
msg.id,
msg.composite_id,
msg.subject,
msg.request_date,
msg.response_date,
message_pkg.is_accept(msg.response) as is_accept,
message_pkg.is_complete(msg.response) as is_complete,
message_pkg.is_error(msg.response) as is_error,
message_pkg.is_reject(msg.response) as is_reject
,substr(msg.response.extract('//code/text()','xmlns="http://xmlns.bayer.com/ipms"').getstringval(),1,256) error_code
,substr(msg.response.extract('//description/text()','xmlns="http://xmlns.bayer.com/ipms"').getstringval(),1,512) error_desc
from message msg;