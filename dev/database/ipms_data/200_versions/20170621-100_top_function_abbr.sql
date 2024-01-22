update top_function set abbreviation='NRD' where code='10' and nvl(abbreviation,'x')<>'NRD';
update top_function set abbreviation='ID' where code='11' and nvl(abbreviation,'x')<>'ID';
update top_function set abbreviation='F' where code='12' and nvl(abbreviation,'x')<>'F';
update top_function set abbreviation='ONC' where code='13' and nvl(abbreviation,'x')<>'ONC';
update top_function set abbreviation='RD' where code='6' and nvl(abbreviation,'x')<>'RD';
commit;