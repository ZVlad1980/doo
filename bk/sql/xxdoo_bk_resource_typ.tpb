create or replace type body xxdoo_bk_resource_typ is
  
  -- Member procedures and functions
  constructor function xxdoo_bk_resource_typ return self as result is
  begin
    return;
  end;
--procedure assignment sequence numbers
  member procedure set_id is
  begin
    if self.id is null then
      self.id := xxdoo_bk_resources_seq.Nextval;
    end if;
  end;
  --
  constructor function xxdoo_bk_resource_typ(p_name varchar2) return self as result is
  begin
    self.name := p_name;
    return;
  end;
  --
end;
/
