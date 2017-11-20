create or replace type body xxdoo_html_el_value_typ is
  
  -- Member procedures and functions
  constructor function xxdoo_html_el_value_typ return self as result is
  begin
    return;
  end;
  --
  constructor function xxdoo_html_el_value_typ(p_value varchar2,
                                              p_type  varchar2 default 'A') return self as result is
  begin
    if substr(p_value,1,1) = chr(0) then
      self.function := xxdoo_html_el_func_typ(p_func_xml => xmltype(replace(p_value,chr(0))));
    else
      self.value := p_value;
    end if;
    self.type  := p_type;
    --
    return;
  end;
  --
  member procedure add_value(p_value varchar2) is
  begin
    self.value := replace(p_value,'"') || ' ' || replace(self.value,'"');
  end; 
  --
  member function as_string return varchar2 is
    l_result varchar2(200);
  begin
    if self.function is not null then
      l_result := '''||' || self.function.as_string || '||''';
    else
      l_result := self.value;
    end if;
    if self.type = 'A' then
      l_result := '"'||replace(l_result,'"')||'"';
    end if;
    return l_result; 
  end;
  --
  member procedure prepare(self in out nocopy xxdoo_html_el_value_typ, p_ctx in out nocopy xxdoo_html_el_context_typ) is
  begin
    if self.function is not null then
      p_ctx := self.function.prepare(p_ctx);
    end if;
  end;
  --
end;
/
