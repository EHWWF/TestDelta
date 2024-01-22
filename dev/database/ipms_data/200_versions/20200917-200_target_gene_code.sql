prompt 
prompt ----> ERROR, FEHLER:  
prompt ----> following update script must be rather run manually
prompt
--set serveroutput on size 1000000
--declare
--begin
--    for tt in (
--				select trg.id, trg.code, src.target_gene_code
--				from project trg 
--				join project src on (src.id = trg.PREDECESSOR_PROJECT_ID)
--				where trg.target_gene_code is null
--				and src.target_gene_code is not null
--				order by trg.id
--			) 
--		loop
--        begin
--						--update project set target_gene_code = tt.target_gene_code where id=tt.id and target_gene_code is null;
--						--commit;
--            dbms_output.put_line(tt.id||' >>> '||tt.code||' >>> ='||tt.target_gene_code);
--        exception when others then
--						dbms_output.put_line(tt.id||' >>> '||tt.code||' >>> ='||sqlerrm);
--        end;
--    end loop;
--end;