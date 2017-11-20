create or replace type body xxdoo_dsl_summary is

  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin
    return upper('xxdoo_dsl_summary');
  end;
  --
  constructor function xxdoo_dsl_summary(p_terms xxdoo_dsl_terms) return self as result is
  begin
    self.terms := p_terms;
    return;
  end;
  --
  --
  --
  member procedure generate is
    l_css varchar2(150);
  begin
    --
    self.h := xxdoo_html();
    --
    for t in 1..self.terms.count loop
      self.h := self.h.h(self.terms(t).get_html);
    end loop;
    l_css := case self.terms.count when 1 then '.single' end;
    --
    self.h := self.h.h('div.meta'||l_css,self.h.h('dl.group',self.h));
    --
  end;
  --
  --
  --
  member function get_html(self in out nocopy xxdoo_dsl_summary) return xxdoo_html is
  begin
    --
    self.generate;
    return self.h;
    --
  end;
  --
end;
/
