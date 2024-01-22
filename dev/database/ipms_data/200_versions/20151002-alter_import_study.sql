alter table import_study
	add (is_gpdc_approved number(1,0) default 0 not null)
	add (is_obligation number(1,0) default 0 not null)
	add (is_probing number(1,0) default 0 not null);