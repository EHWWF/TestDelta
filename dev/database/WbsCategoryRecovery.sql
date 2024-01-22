create or replace package wbs_cat_recovery as
  procedure send_category(p_timeline_id in varchar2 default null);
  procedure extract_wbs_cat_baseline(p_threshold_date in date, p_timeline_id in varchar2 default null);
  procedure mark_available_categories;
  procedure refresh_relevant_timeline;
end;
/

create or replace package body wbs_cat_recovery as


  procedure send_category(p_timeline_id in varchar2 default null) as
    v_payload xmltype;
    p_full    number := 1;
    begin

      for r in (select distinct timeline_id
                from timeline_wbs_cat_recovery
                where (timeline_id = p_timeline_id or p_timeline_id is null) and is_cat_available = 0) loop


        select xmltype(
                 '<timeline id="' || tl.id || '" programId="' ||
                 decode(tl.type_code, 'SND', snd.program_id, prj.program_id) || '" projectId="' ||
                 decode(tl.type_code, 'SND', snd.id, prj.id) || '" referenceId="' || tl.reference_id || '" ' ||
                 message_pkg.xmlns_ipms || '>' ||
                 decode(p_full, 0, '', get_element('name', tl.name)) ||
                 get_element('typeCode', tl.type_code) ||
                 decode(p_full, 0, '', get_element('startDate', get_char_date(tl.start_date))) ||
                 decode(p_full, 0, '', get_element('finishDate', get_char_date(tl.finish_date))) ||
                 decode(p_full, 0, '', get_element('comments', '<![CDATA[' || tl.comments || ']]>', 0)) ||
                 '</timeline>'
            )
            into v_payload
        from timeline tl
               left join project prj on prj.id = tl.project_id
               left join program_sandbox snd on snd.snd_timeline_id = tl.id and tl.type_code = 'SND'
        where tl.id = r.timeline_id;


        select v_payload.appendChildXML('/*',
                                        xmlelement("wbsNodes",
                                                   xmlattributes(message_pkg.nsuri_ipms as "xmlns"),
                                                   xmlagg(
                                                     xmlelement("wbs",
                                                                xmlattributes(
                                                                t.wbs_id as "id",
                                                                t.study_id as "studyId",
                                                                t.timeline_id as "timelineId",
                                                                t.parent_wbs_id as "parentId",
                                                                decode(t.placeholder, 1, 'true', 'false') as
                                                                "placeholder"
                                                                ),
                                                                xmlforest(
                                                                  t.name as "name",
                                                                  w.wbs_cat_object_id as "categoryObjectId"
                                                                    )
                                                         ))
                                            ))
            into v_payload
        from timeline_wbs t
               join timeline_wbs_cat_recovery w
                 on w.timeline_id = t.timeline_id and nvl(t.code, -1) = nvl(w.wbs_code, -1) and t.name = w.wbs_name and
                    nvl(t.study_id, -1) = nvl(w.study_id, -1) and w.is_cat_available = 0
        where t.timeline_id = r.timeline_id;

        --dbms_output.put_line('Payload: ' || v_payload.getstringval());

        log_pkg.log('Send WBS category', 'Timeline ID=' || r.timeline_id || ', count=' || sql%rowcount);

        timeline_pkg.send(v_payload.extract('//timeline/@id', message_pkg.xmlns_ipms).getstringval(), v_payload,
                          'begin timeline_pkg.receive(''' || r.timeline_id || '''); end;');


        commit;

        dbms_lock.sleep(5);

      end loop;

    end;

  --------------------------


  procedure extract_wbs_cat_baseline(p_threshold_date in date, p_timeline_id in varchar2 default null) as
    begin

      if p_timeline_id is not null
      then
        delete from timeline_wbs_cat_recovery where timeline_id = p_timeline_id;
      else
        execute immediate 'truncate table timeline_wbs_cat_recovery';
      end if;

      for r in (

      select distinct timeline_id, first_value(
                                     id) over (partition by timeline_id order by create_date_p6 desc) baseline_id
      from timeline_baseline t
      where timeline_id like '%-RAW' and (timeline_id = p_timeline_id or p_timeline_id is null) and
              create_date_p6 <= p_threshold_date

      ) loop


        insert into timeline_wbs_cat_recovery
        select t.timeline_id, t.id baseline_id, xt.code, xt.name, xt.study_id, xt.wbs_cat_object_id, 0
        from timeline_baseline t, XMLTABLE(xmlnamespaces (default 'http://xmlns.bayer.com/ipms'),
                                           '/baseline/wbsNodes/wbs'
                                           passing t.details
                                           columns
                                             study_id varchar2(10) path '/wbs/@studyId',
                                             name varchar2(200) path '/wbs/name',
                                             code varchar2(200) path '/wbs/code',
                                             wbs_cat_object_id varchar2(100) path '/wbs/WBSCategoryObjectId'
            ) xt
        where t.id = r.baseline_id and xt.wbs_cat_object_id is not null;

        log_pkg.log('Extract WBS category',
                    'Timeline ID=' || r.timeline_id || ', baseline_id=' || r.baseline_id || ', count=' || sql%rowcount);

        commit;

      end loop;

    end;

  --------------------------


  procedure mark_available_categories as begin

    merge into timeline_wbs_cat_recovery dst
    using (select wbs.timeline_id, wbs.code, wbs.name, wbs.study_id
           from timeline_wbs_category wca
                  join timeline_wbs wbs on wbs.wbs_id = wca.wbs_id
           where wca.category_object_id is not null) src
    on (dst.timeline_id = src.timeline_id and nvl(dst.wbs_code, -1) = nvl(src.code, -1) and dst.wbs_name = src.name and
        nvl(dst.study_id, -1) = nvl(src.study_id, -1))
    when matched then update set is_cat_available = 1;


  end;

  ----------------------------

  procedure refresh_relevant_timeline as begin

    for r in (select distinct timeline_id
              from timeline_wbs_cat_recovery) loop
      timeline_pkg.receive(r.timeline_id);
      commit;
      dbms_lock.sleep(2);
    end loop;

  end;


end;
/