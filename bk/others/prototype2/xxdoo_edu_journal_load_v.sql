create or replace view xxdoo_edu_journal_load_v --of xxdoo_edu_journal_typ with object oid(id) 
as
with inputs as (
  select p.lvl, p.name,p.code,p.parent,p.value
  from   xxdoo_bk_json_parse_v p
)
select cast(null as INTEGER)instance_version,
       cast(min(to_number(decode(p2.name,'id',p2.value))) as integer) id,
       cast(min(decode(p2.name,'name',p2.value)) as varchar2(100)) name,
       cast(
         multiset(
           select xxdoo.xxdoo_edu_entry_typ(
                    min(decode(pp3.name,'instance_version',pp3.value,null)),
                    min(decode(pp3.name,'id',pp3.value,null)),
                    min(decode(pp3.name,'journal',pp3.value,null)),
                    xxdoo_edu_student_typ(min(decode(pp3.name,'student',pp3.value,null))) student,
                    ,
                    min(decode(pp3.name,'discipline',pp3.value,null)),
                    min(decode(pp3.name,'grade',pp3.value,null))
                  )
           from   inputs pp,
                  inputs pp2,
                  inputs pp3
           where  1=1
           and    pp3.parent = pp2.code
           and    pp2.parent = pp.code
           and    pp.name = 'entries'
           and    pp.parent = p.code
           group by pp2.name
         ) as xxdoo.xxdoo_edu_entries_typ) entries--*/
from   inputs p,
       inputs p2
where  p.name = 'journal'
and    p2.parent(+) = p.code
and    p.lvl = 1
group by p.name,p.code
/
