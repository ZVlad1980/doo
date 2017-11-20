create or replace package xxdoo_utils_pkg is

  -- Author  : ZHURAVOV_VB
  -- Created : 01.08.2014 11:29:39
  -- Purpose : 
  
  -- Public type declarations
  function char_to_number(p_value varchar2, p_format varchar2) return number;
  function char_to_date(p_value varchar2, p_format varchar2) return date;
  function char_to_integer(p_value varchar2, p_format varchar2) return integer;
end xxdoo_utils_pkg;
/
