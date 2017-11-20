create or replace type body xxdoo_html_ap_service_typ is
  
  -- Member procedures and functions
  constructor function xxdoo_html_ap_service_typ return self as result is
  begin
    return;
  end;
  --
  constructor function xxdoo_html_ap_service_typ(p_name   varchar2,
                                                p_params xxdoo_html_ap_pkg_m_pars_typ default null) return self as result is
  begin
    self.name       := lower(p_name);
    self.params     := nvl(p_params,xxdoo_html_utils_pkg.g_fn_service_pars);
    return;
  end;
  --
  member procedure registration(p_pkg_owner varchar2,
                                p_pkg_name varchar2,
                                p_method_name varchar2) is
    l_namespace varchar2(1024) := xxdoo_html_utils_pkg.g_namespace;
    
    procedure reExportRAW(p_service_name in varchar2,p_procedure_name in varchar2) is
      begin
        if xxapps.xxapps_service_pkg.isNSRAWExported(l_namespace,p_service_name) then
          xxapps.xxapps_service_pkg.unexportNSRAW(l_namespace,p_service_name);
        end if;
        xxapps.xxapps_service_pkg.exportNSRAW(p_pkg_owner,p_pkg_name || '.' || p_procedure_name,l_namespace,p_service_name);
      end;
  begin
    reExportRAW(self.name,p_method_name);
    self.url := xxapps.xxapps_service_pkg.getNSRawURL(l_namespace,self.name);
    return;
  end;
  --
  member function get_url return varchar2 is
  begin
    return self.url;
  end;
end;
/
