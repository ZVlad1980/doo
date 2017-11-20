create or replace type body xxdoo_html_ap_source_typ is
  
  -- Member procedures and functions
  constructor function xxdoo_html_ap_source_typ return self as result is
  begin
    self.callbacks      := xxdoo_html_ap_callbacks_typ();
    return;
  end;
  --
  constructor function xxdoo_html_ap_source_typ(p_name           varchar2, 
                                               p_object_owner   varchar2,
                                               p_object_name    varchar2,
                                               p_parent_src_id  number   default null,
                                               p_parent_field   varchar2 default null) return self as result is
  begin
    self.id            := xxdoo_html_seq.nextval;
    self.name          := p_name;
    self.object_owner  := upper(p_object_owner);
    self.object_name   := upper(p_object_name);
    self.object_type   := xxdoo_html_utils_pkg.get_object_type(self.object_owner,self.object_name);
    self.parent_src_id := p_parent_src_id;
    self.parent_field  := upper(p_parent_field);
    self.callbacks     := xxdoo_html_ap_callbacks_typ();
    self.exists_getter := xxdoo_html_utils_pkg.exists_procedure_type(p_source => self, p_method_name => 'getter');
    self.exists_id     := xxdoo_html_utils_pkg.exists_procedure_type(p_source => self, p_method_name => 'id');
    return;
  end;
  --
  member function add_callback(self in out nocopy xxdoo_html_ap_source_typ,
                               p_callback_name varchar2) return number is
    l_callback xxdoo_html_ap_callback_typ;
    cursor l_callbacks_cur(p_callback_name varchar2) is
      select value(h)
      from   table(self.callbacks) h
      where  h.name = p_callback_name;
  begin
    if xxdoo_html_utils_pkg.exists_procedure_type(p_source => self, p_method_name => p_callback_name) = 'N' then
      return null;
    end if;
    --
    open l_callbacks_cur(p_callback_name);
    fetch l_callbacks_cur
      into l_callback;
    --
    if l_callbacks_cur%notfound then
      l_callback := xxdoo_html_ap_callback_typ(p_name => p_callback_name);
      self.callbacks.extend;
      self.callbacks(self.callbacks.count) := l_callback;
    end if;
    --
    close l_callbacks_cur;
    --
    return l_callback.id;
  end;
  --
  member procedure get_block_callbacks(p_method in out nocopy xxdoo_html_ap_pkg_mthd_typ,
                                       p_var_name varchar2,
                                       p_data_var_name varchar2) is
  begin
    for h in 1..self.callbacks.count loop
      p_method.add_line('if '||p_var_name||' = '''||self.callbacks(h).id||''' then');
      p_method.indent_inc;
      p_method.add_line(p_data_var_name||'.'||self.callbacks(h).name||';');
      p_method.indent_dec;
      p_method.add_line('end if;');
    end loop;
  end;
  --
end;
/
