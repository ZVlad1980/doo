begin
  if xxapps.xxapps_service_pkg.isNSFunctionExported('versionof','xxdoo_db') then
    xxapps.xxapps_service_pkg.unExportNSFunction('versionof','xxdoo_db');
  end if;
  xxapps.xxapps_service_pkg.exportNSFunction('XXDOO','xxdoo_db_engine_pkg.version','versionof','xxdoo_db');
end;
/
