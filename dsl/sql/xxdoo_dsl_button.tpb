create or replace type body xxdoo_dsl_button is
  
  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin
    return upper('xxdoo_dsl_button');
  end;
  --
  constructor function xxdoo_dsl_button(p_label       varchar2,
                                        p_callback    varchar2 default null,
                                        p_when        varchar2 default null,
                                        p_html        xxdoo_html default null,
                                        p_css         varchar2 default null,
                                        p_confirmed   varchar2 default null,
                                        p_link        varchar2 default null) return self as result is
  begin
    self.label     := p_label    ;
    self.callback  := p_callback ;
    self.condition := p_when     ;
    self.html      := p_html     ;
    self.css       := p_css      ;
    self.confirmed := p_confirmed;
    self.link      := p_link     ;
    --
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
    l_css := case when self.css is not null then '.'||self.css end;
    if self.link is null then
      self.h := self.h.h('a.button'||l_css,self.h.attrs(href => '#', data_action => self.callback, data_sync => 'Y'), self.label);
    else
      self.h := self.h.h('a.button'||l_css,self.h.attrs(href => self.link), self.label);
    end if;
    if self.condition is not null then
      self.h := self.h.when#(self.condition, self.h);
    end if;
    --
  end;
  --
  --
  --
  member function get_html(self in out nocopy xxdoo_dsl_button) return xxdoo_html is
  begin
    --
    self.generate;
    return self.h;
    --
  end;
  --
end;
/
