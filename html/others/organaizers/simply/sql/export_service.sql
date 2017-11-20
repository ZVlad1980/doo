declare
  g_owner         varchar2(1024) := 'XXSL';
  g_package_name  varchar2(1024) := 'XXSL_ORG_SIMPLY_PKG';
  g_namespace     varchar2(1024) := 'oracle.organizers';
  procedure reExport(p_service_name in varchar2,p_procedure_name in varchar2) is
  begin
    if xxapps.xxapps_service_pkg.isNSFunctionExported(g_namespace,p_service_name) then
      xxapps.xxapps_service_pkg.unexportNSFunction(g_namespace,p_service_name);
    end if;
    xxapps.xxapps_service_pkg.exportNSFunction(g_owner,g_package_name || '.' || p_procedure_name,g_namespace,p_service_name);
  end;
  procedure reExportRAW(p_service_name in varchar2,p_procedure_name in varchar2) is
  begin
    if xxapps.xxapps_service_pkg.isNSRAWExported(g_namespace,p_service_name) then
      xxapps.xxapps_service_pkg.unexportNSRAW(g_namespace,p_service_name);
    end if;
    xxapps.xxapps_service_pkg.exportNSRAW(g_owner,g_package_name || '.' || p_procedure_name,g_namespace,p_service_name);
  end;
begin
  reExportRAW('simply', 'SIMPLY');
end;
/

