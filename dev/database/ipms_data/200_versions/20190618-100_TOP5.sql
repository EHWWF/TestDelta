alter table program_top_version drop CONSTRAINT "PROGRAM_TOP_V_VERSION_CA";
alter table program_top_version add CONSTRAINT "PROGRAM_TOP_V_VERSION_CA" CHECK (version in ('current','previous'));