begin

  for r_all in (
  select
    id,
    project_id,
    details
  from project_audit
  where record_type = 'IPMS'
        and (existsNode(details, '/PROJECT/DECISIONS/MILESTONE') = 1
             or
             existsNode(details, '/PROJECT/DEVELOPMENT/MILESTONE') = 1)
  ) loop

    begin

      -- Decision milestones
      for r_dec_mil in (
      select XMLELEMENT("DECISIONS", xmlagg(
          xmlelement("MILESTONE", xmlattributes (mls.code as "CODE", xt.name as "NAME", xt.plan as "PLAN", xt.achieved
                     as "ACHIEVED")))) decisions
      from
        xmltable ('/PROJECT/DECISIONS/MILESTONE'
        passing r_all.details
        columns
            name varchar2(100) path '@NAME',
            plan varchar2(100) path '@PLAN',
            achieved varchar2(100) path '@ACHIEVED'
        ) xt left join milestone mls on mls.name =
                                        decode(xt.name, 'Start Phase I', 'Phase I Decision', 'Start Phase IIb',
                                               'Phase IIb Decision', 'Start Phase III', 'Phase III Decision', xt.name)
      ) loop

        update project_audit
        set details = updatexml(details, '/PROJECT/DECISIONS', r_dec_mil.decisions)
        where id = r_all.id;

      end loop;

      -- Development milestones
      for r_dev_mil in (
      select XMLELEMENT("DEVELOPMENT", xmlagg(
          xmlelement("MILESTONE", xmlattributes (mls.code as "CODE", xt.name as "NAME", xt.plan as "PLAN", xt.achieved
                     as "ACHIEVED")))) dev
      from
        xmltable ('/PROJECT/DEVELOPMENT/MILESTONE'
        passing r_all.details
        columns
            name varchar2(100) path '@NAME',
            plan varchar2(100) path '@PLAN',
            achieved varchar2(100) path '@ACHIEVED'
        ) xt left join milestone mls on mls.name = xt.name
      ) loop

        update project_audit
        set details = updatexml(details, '/PROJECT/DEVELOPMENT', r_dev_mil.dev)
        where id = r_all.id;

      end loop;

      commit;
      exception when others then
      log_pkg.catch('project_audit update', 'Failed update of project_audit record');

    end;
  end loop;

end;
/









