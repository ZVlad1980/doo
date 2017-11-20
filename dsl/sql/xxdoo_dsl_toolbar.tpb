create or replace type body xxdoo_dsl_toolbar is

  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin
    return upper('xxdoo_dsl_toolbar');
  end;
  --
  constructor function xxdoo_dsl_toolbar return self as result is
  begin
    return;
  end;
  --
  constructor function xxdoo_dsl_toolbar(p_buttons xxdoo_dsl_buttons) return self as result is
  begin
    self.buttons := p_buttons;
    return;
  end;
  --
  --
  --
  member procedure generate is
  begin
    --
    self.h := xxdoo_html();
    for b in 1..self.buttons.count loop
      self.h := self.h.h(self.buttons(b).get_html);
    end loop;
    --
    self.h := self.h.h('div.buttons',self.h);
    --
  end;
  --
  --
  --
  member function get_html(self in out nocopy xxdoo_dsl_toolbar) return xxdoo_html is
  begin
    --
    self.generate;
    return self.h;
    --
  end;
  --
end;
/
