create or replace type body xxdoo_html_ap_appl_typ is
  
  -- Member procedures and functions
  constructor function xxdoo_html_ap_appl_typ return self as result is
  begin
    self.sources := xxdoo_html_ap_sources_typ();
    self.api_version := xxdoo_html_utils_pkg.version;
    self.package := xxdoo_html_ap_pkg_typ;
    return;
  end;
  --
  constructor function xxdoo_html_ap_appl_typ(p_name        varchar2) return self as result is
  begin
    select value(a)
    into   self
    from   xxdoo_html_ap_appls_t a
    where  a.name = p_name;
    --
    self.package.methods.delete;
    --
    if self.sources is not null then
      self.sources.delete;
    else
      self.sources := xxdoo_html_ap_sources_typ();
    end if;
    --
    if self.regions is not null then
      self.regions.delete;
    else
      self.regions := xxdoo_html_ap_regions_typ();
    end if;
    --
    return;
  end;
  --
  constructor function xxdoo_html_ap_appl_typ(p_name         varchar2, 
                                             p_code         varchar2,
                                             p_source       xxdoo_html_ap_source_typ) return self as result is
  begin 
    begin
      self := xxdoo_html_ap_appl_typ(p_name);
    exception
      when no_data_found then
        --
        self.api_version := xxdoo_html_utils_pkg.version;
        self.name := p_name;
        self.code := nvl(p_code,p_name);
        self.service := xxdoo_html_ap_service_typ(p_name);
        self.regions := xxdoo_html_ap_regions_typ();
        self.package :=  xxdoo_html_ap_pkg_typ(p_owner      => xxdoo_html_utils_pkg.g_owner, 
                                              p_name       => upper(self.code) || '_PKG');
        --
        self.sources := xxdoo_html_ap_sources_typ();
    end;
    if p_source is not null then
      self.sources.extend;
      self.sources(self.sources.count) := p_source;
    end if;
    return;
  end;
  --
  member procedure save is
    pragma autonomous_transaction;
  begin
    if self.name is null then 
      return;
    end if;
    --
    if self.id is null then
      self.id := xxdoo_html_seq.nextval;
      insert into xxdoo_html_ap_appls_t values self;
    else
      update xxdoo_html_ap_appls_t a set value(a) = self where a.id = self.id;
    end if;
    --
    commit;
  exception
    when others then
      rollback;
      xxdoo_html_utils_pkg.fix_exception('xxdoo_html_appl_type.save('||self.name||') error.');
      raise;
  end;
  --
  member procedure unregistration is
    pragma autonomous_transaction;
  begin
    delete from xxdoo_html_ap_appls_t a
    where  a.id = self.id;
    --
    commit;
  exception
    when others then
      rollback;
      xxdoo_html_utils_pkg.fix_exception('xxdoo_html_appl_type.unregistration('||self.name||') error.');
  end;
  --
  member function add_source(self     in out xxdoo_html_ap_appl_typ,
                             p_src_name      varchar2,
                             p_object_owner  varchar2,
                             p_object_name   varchar2,
                             p_parent_src_id number,
                             p_parent_field  varchar2) return number is
    l_src_nm number;
  begin
    for s in 1..self.sources.count loop
      if self.sources(s).object_owner = p_object_owner and self.sources(s).object_name = p_object_name then
        l_src_nm := s;
        exit;
      end if;
    end loop;
    --
    
    if l_src_nm is null then
      self.sources.extend;
      self.sources(self.sources.count) := xxdoo_html_ap_source_typ(nvl(p_src_name,p_object_name),
                                                                      p_object_owner,
                                                                      p_object_name,
                                                                      p_parent_src_id,
                                                                      p_parent_field);
      l_src_nm := self.sources.count;
    end if;
    --
    return l_src_nm;
  end;
  --
  member procedure add_region(p_region xxdoo_html_ap_region_typ) is
  begin
    self.regions.extend;
    self.regions(self.regions.count) := p_region;
  end;
  --
  member procedure save_source(p_source in out nocopy xxdoo_html_ap_source_typ) is
    l_src_nm number;
  begin
    l_src_nm := self.add_source(p_source.name,
                                p_source.object_owner,
                                p_source.object_name,
                                p_source.parent_src_id,
                                p_source.parent_field);
    for c in 1..p_source.callbacks.count loop
      self.sources(l_src_nm).callbacks.extend;
      self.sources(l_src_nm).callbacks(self.sources(l_src_nm).callbacks.count) := p_source.callbacks(c);
    end loop;
  end;
  --
  member procedure generate is
  begin 
    --
    self.package.generate;
    --
  end;
  --
  --
end;
/
