alter table target_product_profile add constraint tpp_projectid_version_uidx unique (project_id,version);