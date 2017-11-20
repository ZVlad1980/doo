create or replace package xxdoo_dsl_utils_pkg is

  -- Author  : ZHURAVOV_VB
  -- Created : 02.05.2015 14:00:27
  -- Purpose : 
  
  g_fld_text    constant varchar2(40) := 'text';
  g_fld_number  constant varchar2(40) := 'number';
  g_fld_date    constant varchar2(40) := 'date';
  g_fld_suggest constant varchar2(40) := 'suggest';
  --
  g_el_content    constant varchar2(20) := 'content';
  g_el_field      constant varchar2(20) := 'field';
  g_el_fieldset   constant varchar2(20) := 'fieldset';
  g_el_collection constant varchar2(20) := 'collection';
  g_el_form       constant varchar2(20) := 'form';
  --

end xxdoo_dsl_utils_pkg;
/
