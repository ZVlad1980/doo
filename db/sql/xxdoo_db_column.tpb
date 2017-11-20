create or replace type body xxdoo_db_column is
  
  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin
    return upper('XXDOO.XXDOO_DB_COLUMN');
  end get_type_name;
  --
  constructor function xxdoo_db_column return self as result is
  begin
    return;
  end xxdoo_db_column;
  --
  constructor function xxdoo_db_column(p_name varchar2) return self as result is
  begin
    self.name := p_name;
    return;
  end xxdoo_db_column;
  --
  constructor function xxdoo_db_column(p_name varchar2, p_position integer) return self as result is
  begin
    self.name := p_name;
    self.position := p_position;
    return;
  end xxdoo_db_column;
  --
  --
  --
  member procedure set_id is
  begin
    if self.id is null then
      self.id := xxdoo_db_seq.nextval();
    end if;
  end;
  --
end;
/
