/*
drop type ;
drop type ;
drop type reqursive_type;
drop type real_type;
drop type list_abstract_type;
drop type abstract_type;

*/
create or replace type abstract_type as object (
  dummy varchar2(1)
)
not instantiable
not final
/
create type list_abstract_type is table of abstract_type
/
create or replace type real_type as object(
  elements list_abstract_type;
)
/
create or replace type reqursive_type under abstract_type (
  name varchar2(10),
  vars list_abstract_type
)
not final
/
