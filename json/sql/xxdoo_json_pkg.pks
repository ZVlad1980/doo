create or replace package xxdoo_json_pkg is

  -- Author  : ZHURAVOV_VB
  -- Created : 09.10.2014 18:11:56
  -- Purpose : 
  --
  function version return varchar2;
  -- Public type declarations
  --function parse_json(p_json clob, p_json_type char default 'U') return xxdoo_json_objects pipelined;
  function parse_json(p_json clob) return xxdoo_json_elements pipelined;

end xxdoo_json_pkg;
/
