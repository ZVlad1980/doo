begin
  if xxapps.xxapps_service_pkg.isNSFunctionExported('versionof','xxdoo_json') then
    xxapps.xxapps_service_pkg.unExportNSFunction('versionof','xxdoo_json');
  end if;
  xxapps.xxapps_service_pkg.exportNSFunction('XXDOO','xxdoo_json_pkg.version','versionof','xxdoo_json');
end;
/
