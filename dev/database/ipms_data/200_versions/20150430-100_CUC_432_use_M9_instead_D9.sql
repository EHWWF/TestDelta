update phase_milestone set milestone_code = 'M9' where milestone_code = 'D9' and category='GT';
update generic_timeline set milestone_code = 'M9' where milestone_code = 'D9';
commit;