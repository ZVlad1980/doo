create or replace type body xxdoo_dsl_term is

  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin
    return upper('xxdoo_dsl_term');
  end;
  --
  constructor function xxdoo_dsl_term return self as result is
  begin
    return;
  end;
  --
  constructor function xxdoo_dsl_term(p_term  varchar2,
                                      p_value xxdoo_html,
                                      p_when  varchar2 default null,
                                      p_css   varchar2 default null) return self as result is
  begin
    initialize(
      p_term    => p_term,
      p_value_h => p_value,
      p_value_s => null,
      p_when    => p_when,
      p_css     => p_css
    );
    --
    return;
  end;
  --
  constructor function xxdoo_dsl_term(p_term  varchar2,
                                      p_value varchar2,
                                      p_when  varchar2 default null,
                                      p_css   varchar2 default null) return self as result is
  begin
    initialize(
      p_term    => p_term,
      p_value_h => null,
      p_value_s => p_value,
      p_when    => p_when,
      p_css     => p_css
    );
    --
    return;
  end;
  --
  member procedure initialize(
    p_term    varchar2,
    p_value_h xxdoo_html,
    p_value_s varchar2,
    p_when    varchar2,
    p_css     varchar2) is
  begin
    self.term       := p_term;
    self.describe_h := p_value_h;
    self.describe_s := p_value_s;
    self.condition  := p_when;
    self.css        := p_css;
    --
  end initialize;
  --
  --
  --
  member procedure generate is
    l_css varchar2(151);
  begin
    --
    self.h := xxdoo_html();
    l_css := case when self.css is not null then '.'||self.css end;
    self.h := self.h.h('dt'|| l_css,self.term).h('dd.subject',self.describe_s);
    if self.condition is not null then
      self.h := self.h.when#(self.condition,self.h);
    else
      self.h := self.h.when#(self.describe_s,self.h);
    end if;
    --
  end;
  --
  --
  --
  member function get_html(self in out nocopy xxdoo_dsl_term) return xxdoo_html is
  begin
    --
    self.generate;
    return self.h;
    --
  end;
  --
end;
/
