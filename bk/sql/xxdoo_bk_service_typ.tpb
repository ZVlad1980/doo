create or replace type body xxdoo.xxdoo_bk_service_typ is
  --
  constructor function xxdoo_bk_service_typ(p_service_name varchar2, 
                                            p_namespace varchar2 default null) return self as result is
  begin
    self.name := p_service_name;
    self.namespace := p_namespace;
    return;
  end;
  --
  member procedure set_id is
  begin
    --
    if self.id is null and self.name is not null then
      self.id := xxdoo_bk_services_seq.nextval;
    end if;
    --
    if self.method is not null then
      self.method.set_id;
    end if;
    --
  end set_id;
  --
  member procedure set_method(p_method xxdoo_bk_method_typ) is
    l_id number;
  begin
    if self.method is not null then
      l_id := self.method.id;
    end if;
    self.method := p_method;
    self.method.id := l_id;
  end;
  --
  member procedure export is
  begin
   if xxdoo_bk_service_pkg.isNSRAWExported(self.namespace, self.name) then
     xxdoo_bk_service_pkg.unexportNSRAW(self.namespace, self.name);
   end if;
   xxdoo_bk_service_pkg.exportNSRAW(self.method.owner, 
                                    self.method.package || '.' || self.method.name, 
                                    self.namespace,
                                    self.name);
   --
   self.url := get_url;
   --
  end;
  --
  member function get_url return varchar2 is
  begin
    if self.name is null or self.namespace is null then
      xxdoo_utl_pkg.fix_exception('Get service url error: name ('||self.name||') or namespace ('||self.namespace||') is empty.');
      raise xxdoo_bk_core_pkg.g_exc_error;
    end if;
    return xxdoo_bk_service_pkg.getNSRawURL(
      self.namespace,
      self.name
    );
  end;
  --
end;
/
