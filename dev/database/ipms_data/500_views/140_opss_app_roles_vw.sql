create or replace view opss_app_roles_vw as
select 
	detailapprole, 
	substr(MasterAppRole,1,instr(MasterAppRole,'+uniquemember=cn=',1)-1) MasterAppRole
from (
	select 
		replace(dn.rdn,'cn=') detailapprole, 
		replace(att.attrval,'orcljaznjavaclass=oracle.security.jps.service.policystore.ApplicationRole+cn=') masterapprole
	from jps_attrs@bpm_opss_db att
	join jps_dn@bpm_opss_db dn on (dn.entryid=att.jps_dn_entryid)
	where att.attrname='orclassignedRoles' 
	and dn.parentdn='cn=opssroot,cn=jpscontext,cn=opsssecuritystore,cn=ipms,cn=roles,'
) order by detailapprole, MasterAppRole;