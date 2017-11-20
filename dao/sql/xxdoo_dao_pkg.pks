create or replace package xxdoo_dao_pkg is

  -- Author  : ZHURAVOV_VB
  -- Created : 10.10.2014 18:41:54
  -- Purpose : 
  --
  function version return varchar2;
  --
  procedure seq_init;
  --
  function seq_nextval return integer;
  --
end xxdoo_dao_pkg;
/
