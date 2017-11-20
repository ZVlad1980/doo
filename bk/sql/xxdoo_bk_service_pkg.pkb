create or replace package body xxdoo_bk_service_pkg is
  --
  --
  --
  function isNSRAWExported(p_namespace varchar2, p_service_name varchar2) return boolean 
  is
    l_result varchar2(1);
  begin
    execute immediate 'begin :1 := case when xxapps.xxapps_service_pkg.isNSRAWExported(:p_namespace, :p_service_name) then ''Y'' else ''N'' end; end;'
      using out l_result, in p_namespace, p_service_name;
    return case l_result when 'Y' then true else false end;
  end;
  --
  --
  --
  procedure unexportNSRAW(p_namespace varchar2, p_service_name varchar2) is
  begin
    execute immediate 'begin xxapps.xxapps_service_pkg.unexportNSRAW(:p_namespace, :p_service_name); end;'
      using p_namespace, p_service_name;
  end;
  --
  --
  --
  procedure exportNSRAW(p_owner         varchar2,
                        p_function_name varchar2, 
                        p_namespace     varchar2, 
                        p_service_name  varchar2) is
  begin
    execute immediate 'begin xxapps.xxapps_service_pkg.exportNSRAW(:p_owner, :p_function_name, :p_namespace, :p_service_name); end;'
      using p_owner, p_function_name, p_namespace, p_service_name;
  end;
  --
  --
  --
  function getNSRawURL(p_namespace varchar2, p_service_name varchar2) return varchar2
  is
    l_result varchar2(1024);
  begin
    execute immediate 'begin :l_result := xxapps.xxapps_service_pkg.getNSRawURL(:p_namespace, :p_service_name); end;'
      using out l_result, in p_namespace, p_service_name;
    return l_result;
  end;
  --
end xxdoo_bk_service_pkg;
/
