create or replace type body xxdoo_dsl_tbl_row is
  
  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin 
    return upper('xxdoo_dsl_tbl_row');
  end;
  --
  --
  --
  constructor function xxdoo_dsl_tbl_row(p_collection xxdoo_html_source_typ, p_css varchar2 default null) return self as result is
  begin
    self.h := xxdoo_html(p_src_owner  => p_collection.owner, p_src_object => p_collection.name);
    self.h := self.h.h('tr'||case when p_css is not null then '.'||p_css end);
    self.collection := p_collection;
    return;
  end;
  --
  --
  --
  constructor function xxdoo_dsl_tbl_row(p_source varchar2, p_css varchar2 default null) return self as result is
  begin
    self.h := xxdoo_html;
    self.h := self.h.h('tr'||case when p_css is not null then '.'||p_css end);
    self.source := p_source;
    return;
  end;
  --
end;
/
