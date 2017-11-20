create or replace type body xxdoo_html_ap_callback_typ is
  
  -- Member procedures and functions
  constructor function xxdoo_html_ap_callback_typ return self as result is
  begin
    return;
  end;
  --
  constructor function xxdoo_html_ap_callback_typ(p_name varchar2) return self as result is
  begin
    self.id := xxdoo_html_seq.nextval;
    self.name := p_name;
    return;
  end;
  
end;
/
