create or replace package xxdoo_bk_service_pkg is

  -- Author  : ZHURAVOV_VB
  -- Created : 03.04.2015 12:06:09
  -- Purpose : 
  --
  function isNSRAWExported(p_namespace varchar2, p_service_name varchar2) return boolean;
  --
  procedure unexportNSRAW(p_namespace varchar2, p_service_name varchar2);
  --
  procedure exportNSRAW(p_owner         varchar2,
                        p_function_name varchar2, 
                        p_namespace     varchar2, 
                        p_service_name  varchar2);
  --
  function getNSRawURL(p_namespace varchar2, p_service_name varchar2) return varchar2;
  --
end xxdoo_bk_service_pkg;
/
