  CREATE OR REPLACE FORCE VIEW BUSINESS_ACTIVITY_CATEGORY_VW AS 
  with categories as ( 
     select 'Program,Project Master data,Project TPP,Project Goals,Project Timeline,LE Process,LTC planning,Planning Assumptions Request,References,Sandbox Plan,FPS' as list from dual  
  ) 
    select 
      regexp_substr(categories.list, '[^,]+', 1, level) as name, 
      rownum as id 
    from categories   
    connect by instr(categories.list, ',', 1, level -1 ) > 0;