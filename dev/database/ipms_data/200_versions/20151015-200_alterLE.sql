alter table latest_estimates_tag drop column previous_let_id;
alter table latest_estimate add (study_is_placeholder number(1,0));
alter table latest_estimate add (study_is_probing number(1,0));
alter table latest_estimate add (study_is_obligation number(1,0));
alter table latest_estimate add (study_is_gpdc_approved number(1,0));