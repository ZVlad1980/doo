create or replace type body xxdoo_db_dao_table is
  
  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin
    return upper('XXDOO.XXDOO_DB_DAO_TABLE');
  end get_type_name;
  --
  -- конструктор 
  --
  constructor function xxdoo_db_dao_table(p_table_name  varchar2, 
                                          p_table_alias varchar2, 
                                          p_dao_path    varchar2)
    return self as result is
  begin
    self.table_name  := p_table_name ;
    self.table_alias := p_table_alias;
    self.dao_path    := p_dao_path   ;
    --
    return;
  end;
  
end;
/
