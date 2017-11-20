create or replace type body xxdoo_html_el_tag_typ is
  
  -- Member procedures and functions
  constructor function xxdoo_html_el_tag_typ return self as result is
  begin
    self.set_id;
    return;
  end;
  --
  constructor function xxdoo_html_el_tag_typ(p_array_id  number,
                                            p_tag       varchar2,
                                            p_attrs     xxdoo_html_el_tag_attrs_typ,
                                            p_content   varchar2) return self as result is
    l_attrs   xxdoo_html_el_tag_attrs_typ := p_attrs;
  begin
    --
    self.set_id;
    self.array_id   := p_array_id;
    self.tag        := xxdoo_html_utils_pkg.parse_tag(p_tag,l_attrs);
    self.attributes := l_attrs;
    self.content    := xxdoo_html_el_cont_typ(p_content);
    --
    return;
  end;
  --
  constructor function xxdoo_html_el_tag_typ(p_object xxdoo_html_el_tag_typ) return self as result is
  begin
    self    := p_object;
    self.set_id;
    --
    return;
  end;
  --
  overriding member function as_string return varchar2 is
  begin
    return '<' || self.tag || self.attributes.as_string || '>' || self.content.as_string;
  end;
  --
  overriding member function as_string_end return varchar2 is
    l_result varchar2(2000);
  begin
    /*if self.tag = 'body' then
      l_result := l_result || '<script src="'||xxdoo_html_utils_pkg.g_path_oracle_client||'"></script>';
    end if;*/
    return l_result || '</' || self.tag || '>';
  end;
  --
  overriding member function prepare(self in out nocopy xxdoo_html_el_tag_typ, p_ctx xxdoo_html_el_context_typ) return xxdoo_html_el_context_typ is
    l_ctx xxdoo_html_el_context_typ := p_ctx;
  begin
    self.attributes.prepare(l_ctx);
    l_ctx := self.content.prepare(l_ctx);
    return l_ctx;
  end;
  --
  overriding member function get_attribute_value(p_name varchar2) return varchar2 is 
  begin
    return self.attributes.get_attribute_value(p_name);
  end;
  --
end;
/
