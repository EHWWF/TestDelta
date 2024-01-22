alter table milestone add (ordering number);

REM taking ordering used in ADF MilestoneView.xml and load it to milestone table as a default

begin
merge into milestone dst using (
select milestone_code, type_code, rownum *10 ordering from (
  select
    distinct
    ml.code                 milestone_code,
    ml.type_code,
    reg.code,
    decode(ml.type_code, 'REG', decode(substr(ml.code, length(reg.code) + 2), 'APR', '2', 'SUB', '1', 'LAU', '3', null),
           decode(ml.type_code, 'DEC', decode(ml.code, 'PoC', 'D5', ml.code),
                  ml.code)) ordering_condition
  from
    milestone ml
    left join region reg on ml.code like reg.code || '-%'
  order by
    ml.type_code,
    reg.code,
    decode(ml.type_code, 'REG', decode(substr(ml.code, length(reg.code) + 2), 'APR', '2', 'SUB', '1', 'LAU', '3', null),
           decode(ml.type_code, 'DEC', decode(ml.code, 'PoC', 'D5', ml.code), ml.code))
)
                               ) src
on (dst.code = src.milestone_code and dst.type_code = src.type_code)
when matched then update set dst.ordering = src.ordering;
end;
/
commit;

REM tune default ordering against requirement in BAY_PROMIS-513

declare
  v_ml_1_ord number;
  v_ml_2_ord number;
begin

select ordering into v_ml_1_ord from milestone where code='M6B';
select ordering into v_ml_2_ord from milestone where code='M6P';
update milestone set ordering=v_ml_2_ord where code='M6B';
update milestone set ordering=v_ml_1_ord where code='M6P';

select ordering into v_ml_1_ord from milestone where code='M7C';
select ordering into v_ml_2_ord from milestone where code='M7P';
update milestone set ordering=v_ml_2_ord where code='M7C';
update milestone set ordering=v_ml_1_ord where code='M7P';
commit;

end;
/