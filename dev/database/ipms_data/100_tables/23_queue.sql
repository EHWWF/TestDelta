begin
	dbms_aqadm.create_queue_table(
		queue_table=>'request_qt',
		queue_payload_type=>'SYS.XMLType',
		compatible=>'10.0');

	dbms_aqadm.create_queue_table(
		queue_table=>'response_qt',
		queue_payload_type=>'SYS.XMLType',
		compatible=>'10.0');

	dbms_aqadm.create_queue(
		queue_name=>'request_aq',
		queue_table=>'request_qt');

	dbms_aqadm.create_queue(
		queue_name=>'response_aq',
		queue_table=>'response_qt');
end;
/