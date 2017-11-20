create or replace package xxdoo_db_engine_pkg is

  -- Author  : ZHURAVOV_VB
  -- Created : 16.07.2014 18:11:07
  -- Purpose : 
  --
  function version return varchar2;
  --
  /*procedure put(p_scheme xxdoo_db_scheme_typ);
  --
  procedure generate_objects(p_scheme in out nocopy xxdoo_db_scheme_typ,
                             p_only_ddl  boolean default false);
  --
  procedure drop_objects(p_scheme in out nocopy xxdoo_db_scheme_typ);
  --
  function get_comment_prg_unit return varchar2;
  --
  procedure generate_scripts(p_scheme xxdoo_db_scheme_typ, p_directory varchar2 default null);
  --*/
  procedure add_default_methods(p_table in out nocopy xxdoo_db_table);
  --
end xxdoo_db_engine_pkg;
/
