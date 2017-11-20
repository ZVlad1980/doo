create or replace type body xxdoo_dsl_header is
  
  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin
    return upper('xxdoo_dsl_header');
  end;
  --
  constructor function xxdoo_dsl_header return self as result is
  begin
    return;
  end;
  --
  constructor function xxdoo_dsl_header(
    p_heading varchar2 default null,
    p_message xxdoo_html default null,
    p_toolbar xxdoo_dsl_toolbar default xxdoo_dsl_toolbar()) return self as result is
  begin
    initialize(
      p_heading   => p_heading,
      p_message_h => p_message,
      p_message_s => null,
      p_toolbar   => p_toolbar
    );
    --
    return;
  end;
  --
  constructor function xxdoo_dsl_header(
    p_heading varchar2 default null,
    p_message varchar2 default null,
    p_toolbar xxdoo_dsl_toolbar default xxdoo_dsl_toolbar()) return self as result is
  begin
    initialize(
      p_heading   => p_heading,
      p_message_h => null,
      p_message_s => p_message,
      p_toolbar   => p_toolbar
    );
    --
    return;
  end;
  --
  member procedure initialize(
    p_heading   varchar2,
    p_message_h xxdoo_html,
    p_message_s varchar2,
    p_toolbar   xxdoo_dsl_toolbar) is
  begin
    self.heading   := p_heading;
    self.message_h := p_message_h;
    self.message_s := p_message_s;
    self.toolbar   := p_toolbar;
  end;
  --
  --
  --
  member procedure generate is
    l_is_heading boolean := false;
    l_heading    xxdoo_html;
  begin
    --
    self.h    := xxdoo_html();
    l_heading := xxdoo_html();
    --
    if self.heading is not null or self.message_s is not null then
      l_heading := l_heading.h('h2', self.heading || self.message_s);
      l_is_heading := true;
    end if;
    --
    --!!! to do toolbar!!!
    --
    self.h := self.h.h('header.title.group', 
                self.h.attrs(class => case when not l_is_heading then 'without-heading' end),
                self.h.h(l_heading).h(self.toolbar.get_html)
              );
    --
  end;
  --
  --
  --
  member function get_html(self in out nocopy xxdoo_dsl_header) return xxdoo_html is
  begin
    --
    self.generate;
    return self.h;
    --
  end;
  --
end;
/
