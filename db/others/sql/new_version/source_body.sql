-- DROP TYPE BODY XXDOO_CNTR_ADDRESS_TYP
select *
from   all_objects ao
where  ao.OBJECT_NAME like upper('xxdoo_cntr%')
and    ao.OBJECT_TYPE = 'TYPE BODY'
/
select *
from   all_type_methods m
where  m.TYPE_NAME = 'XXDOO_CNTR_ADDRESS_TYP'
/
select *
from   all_type_attrs t
where  t.TYPE_NAME = 'XXDOO_CNTR_ADDRESS_TYP'
/
select *
from
all_procedures
where  object_name = 'XXDOO_CNTR_ADDRESS_TYP'
/
select *
from   all_arguments aa
where  aa.package_name = 'XXDOO_CNTR_SITE_TYP'
/
select *
from   all_source s
where  s.name = 'XXDOO_CNTR_SITE_TYP'
and    s.TYPE = 'TYPE BODY'
order by line
/
with source as (
        select s.line, s.text
        from   all_source s
        where  1=1
        and    s.TYPE = 'TYPE BODY'
        and    s.name = upper('XXDOO_CNTR_SITE_TYP')
        and    s.owner = upper('XXDOO')
      )
      select listagg(s.text) within group (order by s.line) text
      from   source s
      where  s.line > (select max(ss.line) from source ss where ss.text like '%XXDOO_DB_END%') + 1;
