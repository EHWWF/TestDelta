begin
        for rr in (select view_name from user_views where lower(view_name) in ('ltc_imported_costs_mm_vw', 'ltc_report_rmng_mm_vw')) 
        loop
                execute immediate 'drop view '||rr.view_name;
        end loop;
end;
/