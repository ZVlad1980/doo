--{"path":"#ALL/New","meta":null,"inputs":{"contractor.name":"test","contractor.tax_reference":"1234567890","test_array":[{"test1":"\"{[]}\""},{"test2":"value2"}]},"params":{"contractor2.name":"test2","test_array2":[{"test3":"\"{[]}\""},{"test4":"value2"}]}}
with t_data as (
  select t.id, t.parent_id, t.name, t.type, t.value,
         row_number()over(partition by t.name order by t.id) rnum
  from   table(xxdoo_json_pkg.parse_json(
  --'{"path":"#ALL/New","meta":null,"inputs":{"contractor.name":"test","contractor.sites.site.site_number":"1","contractor.sites.site.tax_reference":"12345"},{"test2":"value2"}]},"params":{"contractor2.name":"test2","test_array2":[{"test3":"\"{[]}\""},{"test4":"value2"}]}}'
  '{"contractor.name":"test",'||
  '"contractor.sites.site.id":null,'||
  '"contractor.sites.site.site_number":"1",'||
  '"contractor.sites.site.phones":[66,88,77],'||
  '"contractor.sites.site.tax_reference":"12345",'||
  '"contractor.sites.site.id":null,'||
  '"contractor.sites.site.site_number":"2",'||
  '"contractor.sites.site.phones":[66,88,77],'||
  '"contractor.sites.site.tax_reference":"56789",'||
  '"contractor.category.name":"vendor"}'
  )) t
  where  1=1
  order by t.id
), 
t_parse as (
  select 0 lvl, 0 id, null parent_id, 'U' type, 0 atom, null parent, 'contractor' name, null         value, 1 rnum
  from dual
  union all
  select level lvl, t.id, t.parent_id, t.type, 
         case t.type
           when 'A' then 0
           else CONNECT_BY_ISLEAF 
         end atom,
         regexp_substr(t.name,'[^.]+',1,level) parent, 
         regexp_substr(t.name,'[^.]+',1,level+1) name,
         t.value,
         row_number()over(partition by sys_connect_by_path(regexp_substr(t.name,'[^.]+',1,level+1),'.') order by t.id) rnum
  from   t_data t
  where  1=1
  connect by prior id = id 
         and prior dbms_random.value is not null
         and level <= regexp_count(name,'[.]+')
),
t_analit as (
--
  select p.lvl, 
         p.id, 
         p.type, 
         p.atom, 
         p.name, 
         case p.atom
           when 1 then
             p.value
         end value,
         rnum,
         lag(rnum,1,99)over(order by id, lvl)rnum_prior
  from   t_parse p
)
--
select a.lvl,
       a.atom,
       a.name,
       a.value 
from   t_analit a
where  (a.rnum = 1 or (a.rnum < a.rnum_prior))
and    a.type <> 'A'
order by a.id, a.lvl
