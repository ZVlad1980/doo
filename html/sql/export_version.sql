begin
  if xxapps.xxapps_service_pkg.isNSFunctionExported('versionof','xxdoo_html') then
    xxapps.xxapps_service_pkg.unExportNSFunction('versionof','xxdoo_html');
  end if;  --
  xxapps.xxapps_service_pkg.exportNSFunction('XXDOO','xxdoo_html_utils_pkg.version','versionof','xxdoo_html');
end;
/
