alter table program_top_version add version_nr number default 0 constraint prg_top_ver_nr_cnn not null;
comment on column program_top_version.version_nr is 'AutogenerateduUnique version number for selected program. The field was added based on reqeirement: PROMIS-465';
create unique index prg_top_ver_nr_ui on program_top_version(program_id,version_nr);
create unique index prg_top_val_ver_scode_ui on program_top_value(program_version_id,subcategory_code);