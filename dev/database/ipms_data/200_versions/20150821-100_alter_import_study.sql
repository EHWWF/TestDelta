alter table import_study 
	add(is_placeholder number(1) check(is_placeholder in (0,1)));
