with inputs as (
  select '{"journal.id"=>"1","journal.name"=>"F1","journal.entries.1.student.id"=>"1", "journal.entries.1.student.name"=>"Ivanov", "journal.entries.1.discipline"=>"2", "journal.entries.1.grade"=>"3","journal.entries.2.student.id"=>"2", "journal.entries.2.student.name"=>"Petrov", "journal.entries.2.discipline"=>"3", "journal.entries.2.grade"=>"4"}' json
  from   dual
),
xmlinfo as (
  select xxdoo.xxdoo_json_pkg.create_xml(replace(replace(json,'=>',':'),', ',',')) xmlinfo
  from   inputs i
)
--
select x.xmlinfo,
       xxdoo_edu_journal_typ(
         cast(null as integer),
         xx.id,
         xx.name,
         cast(
           multiset(
             select xxdoo.xxdoo_edu_entry_typ(
                      cast(null as INTEGER),
                      xx2.id,
                      xx.id,
                      xxdoo.xxdoo_edu_student_typ(cast(null as INTEGER), xx2.student_id, xx2.student_name),
                      xx2.discipline,
                      xx2.grade
                    )
             from   xmltable('/entries/_ENTRY_' passing(xx.entries)
                      columns
                        position  number path '_POSITION_',
                        id        number path 'id',
                        student_id number path 'student/id',
                        student_name varchar2(100) path 'student/name',
                        discipline   varchar2(100) path 'discipline',
                        grade        number        path 'grade'
                    ) xx2
           ) as xxdoo.xxdoo_edu_entries_typ
         )
       ) journal
from   xmlinfo x,
       xmltable('/Object/journal' passing(x.xmlinfo)
         columns
           id      number        path 'id',
           name    varchar2(100) path 'name',
           entries xmltype       path 'entries'
       ) xx
/*
select cast(null as INTEGER)instance_version,
       t.id id,
       t.journal journal,
       value(student_v) student,
       t.discipline discipline,
       t.grade grade
from   xxdoo.xxdoo_edu_entries_t t,
       xxdoo.xxdoo_edu_students_v student_v
       
<?xml version="1.0"?>
<Object>
  <journal>
    <id>1</id>
    <name>F1</name>
    <entries>
      <_ENTRY_>
        <_POSITION_>1</_POSITION_>
        <student>
          <id>1</id>
          <name>Ivanov</name>
        </student>
        <discipline>2</discipline>
        <grade>3</grade>
      </_ENTRY_>
      <_ENTRY_>
        <_POSITION_>2</_POSITION_>
        <student>
          <id>2</id>
          <name>Petrov</name>
        </student>
        <discipline>3</discipline>
        <grade>4</grade>
      </_ENTRY_>
    </entries>
  </journal>
</Object>
*/
