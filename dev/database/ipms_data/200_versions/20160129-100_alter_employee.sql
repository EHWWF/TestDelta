alter table employee add (name as (replace(replace(surname,',')||', '||replace(forename,','),'  ',' ')) );