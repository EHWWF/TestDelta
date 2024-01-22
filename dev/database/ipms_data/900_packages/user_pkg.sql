create or replace package user_pkg as
	/** Default transaction user. */
	system constant nvarchar2(20) := 'IPMS';

	/**
	 * Returns current transaction user.
	 */
	function get_current_user return nvarchar2;

	/**
	 * Sets current transaction user.
	 * Requires non-null user.
	 * Throws application error if requirements unmatched.
	 */
	procedure set_current_user(p_id in nvarchar2);

	/**
	 * Resets current transaction user.
	 */
	procedure clear_current_user;

end;
/
create or replace package body user_pkg as
	current_user nvarchar2(20) := system;

	/*************************************************************************/
	function get_current_user return nvarchar2 as
	begin
		return upper(current_user);
	end;

	/*************************************************************************/
	procedure set_current_user(p_id in nvarchar2) as
	begin
		if p_id is null then
			raise_application_error(-20000, 'Invalid user.');
		end if;

		current_user := p_id;
	end;

	/*************************************************************************/
	procedure clear_current_user as
	begin
		current_user := system;
	end;

end;
/