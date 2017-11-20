create or replace type body xxdoo_bk_region_typ is
  
  -- Member procedures and functions
  constructor function xxdoo_bk_region_typ return self as result is
  begin
    return;
  end;
--procedure assignment sequence numbers
  member procedure set_id is
  begin
    if self.id is null and self.name is not null then
      self.id := xxdoo_bk_regions_seq.nextval;
    end if;
    --
    if self.build_method is not null then
      self.build_method.set_id;
    end if;
    if self.html_method is not null then
      self.html_method.set_id;
    end if;
  end;
  --
  constructor function xxdoo_bk_region_typ(p_name varchar2) return self as result is
  begin
    self.name := p_name;
    return;
  end;
  --
  member procedure build(p_build_method xxdoo_bk_method_typ, p_html_method xxdoo_bk_method_typ) is
  begin
    self.build_method := p_build_method;
    self.html_method  := p_html_method;
  end;
  --
end;
/
