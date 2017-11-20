create or replace package xxsl_org_simply_pkg is

  -- Author  : ZHURAVOV_VB
  -- Created : 30.05.2014 17:56:12
  -- Purpose : 
  
  -- Public type declarations
  function simply("callback" varchar2, "params" clob) return xxapps.xxapps_service_raw_block;
  --
end xxsl_org_simply_pkg;
/
