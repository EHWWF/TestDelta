drop materialized view export_device_phase_vw;
create materialized view export_device_phase_vw as
select code,name,is_active from device_phase;
grant select on export_device_phase_vw to mxcbi;
grant select on export_device_phase_vw to mycsd;