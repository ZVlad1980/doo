create or replace type body xxdoo_dsl_frm_core is
  
  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin
    return upper('xxdoo_dsl_frm_core');
  end;
  --
  constructor function xxdoo_dsl_frm_core return self as result is
  begin
    return;
  end;
  --
  overriding member procedure generate is 
  begin
    self.h := xxdoo_html();
  end;
  --
  overriding member function get_html(self in out nocopy xxdoo_dsl_frm_core) return xxdoo_html is
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
  /*
  member procedure merge(p_parent_id number, p_elements xxdoo_dsl_frm_list) is
    type l_list_typ is table of number index by pls_integer;
    --
    l_new_position number;
    l_old_id       number;
    l_ref_elements l_list_typ;
    --
  begin
    --
    l_new_position := self.elements.count + 1;
    for e in 1..p_elements.count loop
      continue when p_elements(e).element_type <> xxdoo_dsl_utils_pkg.g_el_fieldset;
      l_old_id := p_elements(e).id;
      self.element(p_elements(e));
      self.elements(self.elements.count).pid := nvl(self.elements(self.elements.count).pid, p_parent_id);
      l_ref_elements(l_old_id) := self.elements(self.elements.count).id;
    end loop;
    --
    for e in l_new_position..self.elements.count loop
      if self.elements(e).pid is not null then
        if l_ref_elements.exists(self.elements(e).pid) then
          self.elements(e).pid := l_ref_elements(self.elements(e).pid);
        end if;
      end if;
    end loop;
  end;
  --*/
  member procedure element(p_element xxdoo_dsl_frm) is
    p number;
  begin
    self.elements.extend;
    p := self.elements.count;
    self.elements(p)     := p_element;
    --self.elements(p).id  := xxdoo_utl_pkg.sequence_next;
    self.elements(p).aid := p;
    --
    self.elements(p).element_type := self.elements(p).get_element_type;
    --
  exception
    when others then
      xxdoo_utl_pkg.fix_exception('Append element '||p_element.name||' failed.');
      raise;
  end;
  --
end;
/
