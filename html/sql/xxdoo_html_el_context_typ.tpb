create or replace type body xxdoo_html_el_context_typ is
  
  -- Member procedures and functions
  constructor function xxdoo_html_el_context_typ(p_name varchar2, p_source xxdoo_html_ap_source_typ) return self as result is
  begin
    self.ctx_name := nvl(p_name,p_source.name);
    self.source   := p_source;
    self.id       := xxdoo_html_utils_pkg.get_session_sequence;
    self.methods  := xxdoo_html_ap_pkg_mthds_typ();
    --
    return;
  end;
  --
end;
/
