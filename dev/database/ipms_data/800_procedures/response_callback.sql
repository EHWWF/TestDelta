create or replace
procedure response_callback(
	context in raw,
	reginfo in sys.aq$_reg_info,
	descr in sys.aq$_descriptor,
	payload in raw,
	payloadl in number) as

	dequeue_options dbms_aq.dequeue_options_t;
	message_properties dbms_aq.message_properties_t;
	message_handle raw(16);
	message xmltype;
begin
	/* read message from response queue */
	dbms_aq.dequeue(
		queue_name => descr.queue_name,
		dequeue_options => dequeue_options,
		message_properties => message_properties,
		payload => message,
		msgid => message_handle);

	/* forward message handling */
	message_pkg.receive(message);

exception
	when others then
		notice_pkg.catch('callback', 'Response callback failed!');
end;
/