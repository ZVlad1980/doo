create or replace view xxdoo_bk_json_parse_v as
with json as (
  select t.id,
         t.parent_id,
         t.name,
         t.type,
         t.value --,
  from   table(xxdoo_json_pkg.parse_json(xxdoo_bk_core_pkg.get_json)) t
), 
parse_level1 as ( 
  select t.id,
         level lvl, 
         t.parent_id,
         regexp_substr(t.name,'[^.]+',1,level) name,
         case 
           when level > 1 then 
             regexp_substr(t.name,'[^.]+',1,level - 1) || '#' ||
             (level - 1)
         end parent,
         case 
           when t.type <> 'A' and CONNECT_BY_ISLEAF = 1 then 
             t.value
         end value,
         rownum pid
  from   json t
  where  1=1
  connect by prior id = id 
         and prior dbms_random.value is not null
         and level < regexp_count(name,'\.') + 2
), 
parse_level2 as (
  select p.*,
         p.name || '#' || p.lvl code,
         min(pid) over(partition by p.name,p.lvl) min_pid
  from   parse_level1 p
)
--
select *
from   parse_level2 pl
where  pl.pid = pl.min_pid or value is not null
/
