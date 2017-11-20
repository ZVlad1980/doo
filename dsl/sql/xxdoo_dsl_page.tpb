create or replace type body xxdoo_dsl_page is

  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin
    return upper('xxdoo_dsl_page');
  end;
  --
  constructor function xxdoo_dsl_page return self as result is
  begin
    return;
  end;
  --
  member procedure page(p_name    varchar2,
                        p_header  xxdoo_dsl_header default null,
                        p_summary xxdoo_dsl_summary default null,
                        p_content xxdoo_html default null)  is
  begin
    self.name    := p_name;
    self.header  := p_header;
    self.summary := p_summary;
    self.content := p_content;
    self.tag     := 'div.sheet';
    --
    generate;
    --
    return;
  end;
  --
  member procedure generate is
    --
  begin
    --
    self.h := xxdoo_html();
    --
    self.h := self.h.h(self.tag, self.h.h(self.summary.get_html).h(self.header.get_html).h(self.content));
    --
  end;
  --
end;
/
