alter table project add details_modality varchar2(500);
comment on column project.details_modality is 'Modality. The field was added based on reqeirement: PROMIS-462';