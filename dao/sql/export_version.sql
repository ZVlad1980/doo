begin
  if xxapps.xxapps_service_pkg.isNSFunctionExported('versionof','xxdoo_dao') then
    xxapps.xxapps_service_pkg.unExportNSFunction('versionof','xxdoo_dao');
  end if;
  xxapps.xxapps_service_pkg.exportNSFunction('XXDOO','xxdoo_dao_pkg.version','versionof','xxdoo_dao');
end;
/
