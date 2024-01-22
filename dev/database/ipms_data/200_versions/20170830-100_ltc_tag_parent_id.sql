alter table ltc_tag add parent_id number;
alter table ltc_tag add constraint ltc_tag_parent_id_fk foreign key (parent_id) references ltc_tag(id);
create index ltc_tag_parent_id_fki on ltc_tag(parent_id);
comment on column ltc_tag.parent_id is 'Reference to previuos (source) Tag id.';