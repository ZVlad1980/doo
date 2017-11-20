create or replace type body xxdoo_html_element_typ is
  
  member function get_source_id return number is
  begin
    return xxdoo_html_utils_pkg.get_session_sequence;
  end;
  --
  member procedure set_id is
  begin
    self.id := nvl(self.id,get_source_id);
  end;
  --
end;
/
