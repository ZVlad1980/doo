begin
  if xxapps.xxapps_service_pkg.isNSFunctionExported('versionof','xxdoo_dsl') then
    xxapps.xxapps_service_pkg.unExportNSFunction('versionof','xxdoo_dsl');
  end if;  --
  xxapps.xxapps_service_pkg.exportNSFunction('xxdoo','xxdoo_dsl_version','versionof','xxdoo_dsl');
end;
/
