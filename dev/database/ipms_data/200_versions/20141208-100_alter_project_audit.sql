alter table project_audit add (temp clob);
update project_audit set temp=change_comment;
alter table project_audit drop column change_comment;
alter table project_audit rename column temp to change_comment;