create or replace type body xxdoo_db_tab_join is
  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin
    return upper('XXDOO.XXDOO_DB_TAB_JOIN');
  end get_type_name;
  --
  constructor function xxdoo_db_tab_join(p_table_name         varchar2, 
                                         p_column_name        varchar2, 
                                         p_r_table_name       varchar2, 
                                         p_condition_template varchar2,
                                         p_rel_type           char) return self as result is
  begin
    self.table_name         := p_table_name        ;
    self.column_name        := p_column_name       ;
    self.r_table_name       := p_r_table_name      ;
    self.condition_template := p_condition_template;
    self.r_type             := p_rel_type;
    --
    return;
  end;
  -- Member procedures and functions
  member procedure set_id is
  begin
    if self.id is null then
      self.id := xxdoo_db_seq.nextval();
    end if;
    --
    return;
  end;
  --
end;
/
