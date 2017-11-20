begin
  if xxapps.xxapps_service_pkg.isNSFunctionExported('versionof','xxdoo_bk') then
    xxapps.xxapps_service_pkg.unExportNSFunction('versionof','xxdoo_bk');
  end if;  --
  xxapps.xxapps_service_pkg.exportNSFunction('xxdoo','xxdoo_bk_version','versionof','xxdoo_bk');
end;
/
