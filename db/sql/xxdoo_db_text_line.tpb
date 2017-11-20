create or replace type body xxdoo_db_text_line is
  
  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin
    return upper('XXDOO.XXDOO_DB_TEXT_LINE');
  end get_type_name;
  --
  -- 
  --
  constructor function xxdoo_db_text_line return self as result is
  begin
    --
    return;
  end;
  --
  -- 
  --
  constructor function xxdoo_db_text_line(p_position integer,
                                          p_text     varchar2) return self as result is
  begin
    --
    self.position := p_position;
    self.text     := p_text;
    --
    return;
  end;
  
end;
/
