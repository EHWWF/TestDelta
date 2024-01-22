alter table comments modify text nvarchar2(500) null;
comment on column comments.text is 'For tracking history for <not provided> comments, see:PROMIS-287';