merge into xxdoo_edu_genders_t g
using (
        select 'Male' code from dual union all
        select 'Female' code from dual
      ) u
on    (g.code = u.code)
when not matched then
  insert(code) values(u.code)
/
--grant select on per_all_people_f to xxdoo
merge into XXDOO_EDU_STUDENTS_T s
using (
        select pap.first_name name, pap.last_name, pap.date_of_birth birth_day, 
               (select id
                from   xxdoo_edu_genders_t g
                where  g.code = case pap.sex when 'F' then 'Female' else 'Male' end)  sex 
        from   apps.per_all_people_f pap
        where  rownum < 50
        and    pap.date_of_birth between to_date(19750101,'yyyymmdd') and to_date(19950101,'yyyymmdd')
      ) u
on    (s.name = u.name and s.last_name = u.last_name and s.birth_day = u.birth_day)
when not matched then
  insert(name,last_name,birth_day,sex) values(u.name,u.last_name,u.birth_day,u.sex)
/
merge into xxdoo.xxdoo_edu_disciplines_t s
using (
        select cast('English' as varchar2(100))  name, cast('Business English' as varchar2(240)) full_name from dual union all
        select cast('Design' as varchar2(100))  name, cast('Video game design' as varchar2(240)) full_name from dual union all
        select cast('Philosophy' as varchar2(100))  name, cast('Philosophy of language' as varchar2(240)) full_name from dual union all
        select cast('Anthropology' as varchar2(100))  name, cast('Forensic anthropology' as varchar2(240)) full_name from dual union all
        select cast('Geography' as varchar2(100))  name, cast('Cultural geography' as varchar2(240)) full_name from dual union all
        select cast('Engineering' as varchar2(100))  name, cast('Biochemical engineering' as varchar2(240)) full_name from dual 
      ) u
on    (s.name = u.name)
when not matched then
  insert(name,full_name) values(u.name,u.full_name)
/
commit
/
select s.rowid, s.*
from   XXDOO_EDU_STUDENTS_T s
