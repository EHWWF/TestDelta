update top_function set abbreviation='MAPV' where code='9' and nvl(abbreviation,'x')<>'MAPV';
commit;
comment on column top_function.abbreviation is 'If -abbreviation is not null- then top function is visible at LTC, please be careful while providing data here.';