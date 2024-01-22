declare
begin
  for r in (select constraint_name, search_condition from user_constraints where table_name='COSTS_PROBABILITY' and constraint_type='C') loop
    if  substr(r.search_condition,1,100) = 'probability > 0 and probability <= 100' then
      execute immediate 'alter table Costs_Probability drop constraint '||r.constraint_name;
    end if;
  end loop;
end;
/

alter table Costs_Probability add check (probability >= 0 and probability <= 100);