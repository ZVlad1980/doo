create or replace type body xxdoo_dsl_frm_form is
  
  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin
    return upper('xxdoo_dsl_frm_form');
  end;
  --
  constructor function xxdoo_dsl_frm_form return self as result is
  begin
    self.elements := xxdoo_dsl_frm_list();
    return;
  end;
  --
  overriding member procedure generate is 
  begin
    self.h := xxdoo_html();
  end;
  --
  overriding member function get_html(self in out nocopy xxdoo_dsl_frm_form) return xxdoo_html is
  begin
    self.generate;
    return self.h;
  end;
  --
  overriding member function get_element_type return varchar2 is
  begin
    return xxdoo_dsl_utils_pkg.g_el_form;
  end;
  --
  member function form(p_entry varchar2, p_legend varchar2, p_form xxdoo_dsl_frm_form) return xxdoo_dsl_frm_form is
    o xxdoo_dsl_frm_form := self;
  begin
    o.name := p_entry;
    o.entry_name := p_entry;
    o.legend := p_legend;
    o.elements := p_form.elements;
    --
    return o;
  end;
  --
  member function form(p_entry varchar2, p_form xxdoo_dsl_frm_form) return xxdoo_dsl_frm_form is
  begin
    return self.form(p_entry => p_entry, p_legend => null, p_form => p_form);
  end;
  --
  member function collection(p_entry varchar2, p_object xxdoo_dsl_frm_form) return xxdoo_dsl_frm_form is
    o xxdoo_dsl_frm_form := self;
  begin
    --
    o.element(xxdoo_dsl_frm_collection(p_entry => p_entry, p_elements => p_object.elements));
    --
    return o;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end;
  --
  member function fieldset(p_name varchar2, p_cols number, p_object xxdoo_dsl_frm_form) return xxdoo_dsl_frm_form is
    o xxdoo_dsl_frm_form := self;
  begin
    o.element(xxdoo_dsl_frm_fieldset(p_name => p_name, p_cols => p_cols, p_elements => p_object.elements));
    return o;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end;
  --
  member function fieldset(p_cols number, p_object xxdoo_dsl_frm_form) return xxdoo_dsl_frm_form is
  begin
    return self.fieldset(p_name => null, p_cols => p_cols, p_object => p_object);
  end;
  --
  member function field(p_name varchar2, p_object xxdoo_dsl_frm_form) return xxdoo_dsl_frm_form is
    o xxdoo_dsl_frm_form := self;
  begin
    o.element(xxdoo_dsl_frm_field(p_name => p_name, p_elements => p_object.elements));
    return o;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end;
  --
  member function field(p_name varchar2) return xxdoo_dsl_frm_form is
  begin
    return self.field(p_name => p_name, p_object => xxdoo_dsl_frm_form());
  end;
  --
  member function field(p_object xxdoo_dsl_frm_form) return xxdoo_dsl_frm_form is
  begin
    return self.field(p_name => null, p_object => p_object);
  end;
  --
  member function suggest(p_name varchar2) return xxdoo_dsl_frm_form is
    o xxdoo_dsl_frm_form := self;
  begin
    o.element(xxdoo_dsl_frm_suggest(p_name));
    return o;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end;
  --
  member function text(p_name varchar2, hidden boolean default false) return xxdoo_dsl_frm_form is
    o xxdoo_dsl_frm_form := self;
  begin
    o.element(xxdoo_dsl_frm_content(p_name, xxdoo_dsl_utils_pkg.g_fld_text, hidden));
    return o;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end;
  --
  member function number#(p_name varchar2, hidden boolean default false) return xxdoo_dsl_frm_form is
    o xxdoo_dsl_frm_form := self;
  begin
    o.element(xxdoo_dsl_frm_content(p_name, xxdoo_dsl_utils_pkg.g_fld_number, hidden));
    return o;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end;
  --
  member function date#(p_name varchar2, hidden boolean default false) return xxdoo_dsl_frm_form is
    o xxdoo_dsl_frm_form := self;
  begin
    o.element(xxdoo_dsl_frm_content(p_name, xxdoo_dsl_utils_pkg.g_fld_date, hidden));
    return o;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end;
  --
end;
/
