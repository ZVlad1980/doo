create or replace type body xxdoo_html_el_func_arg_typ is
  
  -- Member procedures and functions
  constructor function xxdoo_html_el_func_arg_typ return self as result is
  begin
    return;
  end;
  --
  constructor function xxdoo_html_el_func_arg_typ(p_value varchar2) return self as result is
  begin
    self.value := p_value;
    return;
  end;
  --
  constructor function xxdoo_html_el_func_arg_typ(p_function xxdoo_html_element_typ) return self as result is
  begin
    self.function := p_function;
    self.type     := 'FUNCTION';
    return;
  end;
  --
  member procedure prepare(self in out nocopy xxdoo_html_el_func_arg_typ, p_ctx in out nocopy xxdoo_html_el_context_typ) is
    l_dummy xxdoo_html_el_context_typ := p_ctx;
  begin
    if nvl(self.type,'NULL') = 'FUNCTION' then
      l_dummy := self.function.prepare(p_ctx);
    else
      self.path        := self.value;
      self.member_info := xxdoo_html_utils_pkg.get_member_info(p_ctx.source, self.path);
      self.value       := p_ctx.ctx_name || '.' || self.value;
    end if;
    --
  end;
  --
  member function as_string return varchar2 is
  begin
    if nvl(self.type,'NULL') = 'FUNCTION' then
      return self.function.as_string;
    else
      return self.value;
    end if;
    return null;
  end;
  --
end;
/
