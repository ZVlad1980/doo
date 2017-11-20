create or replace package xxdoo_db_utils_pkg is

  -- Author  : ZHURAVOV_VB
  -- Created : 16.07.2014 10:18:26
  -- Purpose : Utilities
  
  -- Public type declarations
  --
  procedure plog(p_msg in varchar2,
                 p_eof in boolean default true);
  --
  procedure fix_exception(p_description in varchar2 default null);
  --
  function get_first_exception_desc return varchar2;
  --
  procedure show_errors;
  --
  procedure init_exceptions;
  --
  function is_object_exists(p_owner varchar2, p_name varchar2, p_object_type varchar2 default null) return boolean;
  --
  function parse_column_list(p_columns varchar2) return xxdoo_db_columns;
  --
  function object_name(p_dev_code varchar2, p_name varchar2, p_type varchar2) return varchar2;
  --
  function columns_as_string(p_col_list xxdoo_db_columns) return varchar2;
  --
  procedure seq_init;
  --
  function seq_nextval return integer;
  --
  procedure change_type_init;
  --
  function get_type_xml(p_type varchar2, p_length number, p_scale number) return varchar2;
  --
  function get_fn_format_xml(p_type varchar2) return varchar2;
  --
  --function get_entity_info(p_scheme_id number, p_entity_name varchar2) return g_entity_typ;
  --
  --function get_entity_info(p_entity_id number) return g_entity_typ;
  --
  --function get_entity_info(p_owner varchar2, p_object_name varchar2) return xxdoo_db_entities_info_v%rowtype;
  --
end xxdoo_db_utils_pkg;
/
