create or replace package xxdoo_bk_ee_gateway_pkg is

  -- Author  : ZHURAVOV_VB
  -- Created : 03.04.2015 12:10:40
  -- Purpose : 
  --
  function "request"("book_name" varchar2, "path" varchar2, "inputs" clob, "meta" clob) return xxapps.xxapps_service_raw_block;
  --
  procedure create_db_object(p_ddl varchar2);
  --
  function "request"("book_name" varchar2, "request_body" clob, "request_params" in sys.odciVarchar2List) return xxapps.xxapps_service_raw_block;
  --
end xxdoo_bk_ee_gateway_pkg;
/
