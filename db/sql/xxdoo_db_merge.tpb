create or replace type body xxdoo_db_merge is
  
  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin
    return upper('XXDOO.XXDOO_DB_MERGE');
  end get_type_name;
  --
  constructor function xxdoo_db_merge(p_indent number default 0) return self as result is
  begin
    --
    self.mt  := xxdoo_db_text(p_indent);
    self.us  := xxdoo_db_select(p_indent);
    self.ut  := xxdoo_db_text(p_indent);
    self.ot  := xxdoo_db_text(p_indent);
    self.upt := xxdoo_db_text(p_indent);
    self.ict := xxdoo_db_text(p_indent);
    self.ivt := xxdoo_db_text(p_indent);
    self.using_alias := 'u';
    --
    return;
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception();
  end;
  --
  member procedure m(p_table_name varchar2, p_table_alias varchar2) is
  begin
    self.table_name  := p_table_name;
    self.table_alias := p_table_alias;
    self.mt.append('merge into '||p_table_name||' '||p_table_alias);
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception();
  end;
  --
  member procedure i(p_column_name varchar2) is
  begin
    if self.ict.lines.count = 0 then
      self.ict.append('when not matched then');
      self.ict.inc(2);
      self.ict.append('insert(',false);
      self.ict.inc(7);
      self.ivt.inc(2);
      self.ivt.append('values(',false);
      self.ivt.inc(7);
    else
      self.ict.append(',');
      self.ivt.append(',');
    end if;
    --
    self.ict.append(self.table_alias||'.'||p_column_name,false);
    self.ivt.append(self.using_alias||'.'||p_column_name,false);
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception();
  end;
  --
  member procedure u(p_column_name varchar2) is
  begin
    if self.upt.lines.count = 0 then
      self.upt.append('when matched then');
      self.upt.inc(2);
      self.upt.append('update set');
      self.upt.inc(2);
    else
      self.upt.append(',');
    end if;
    --
    self.upt.append(self.table_alias||'.'||p_column_name||' = '||self.using_alias||'.'||p_column_name,false);
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception();
  end;
  --
  member procedure o(p_column_name varchar2) is
  begin
    if self.ot.lines.count = 0 then
      self.ot.append('on    (',false);
      self.ot.inc(5);
    else
      self.ot.append(' and ');
    end if;
    self.ot.append(self.table_alias||'.'||p_column_name||' = '||self.using_alias||'.'||p_column_name,false);
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception();
  end;
  --
  member procedure build is
    l_str varchar2(1024);
  begin
    --USING
    self.ut.append('using (',false);
    self.ut.inc(7);
    self.us.first;
    while self.us.next(l_str) loop
      self.ut.append(l_str);
    end loop;
    self.ut.dec(1);
    self.ut.append(') '||self.using_alias);
    --ON
    self.ot.append(')');    
    --INSERT
    self.ict.dec(5);
    self.ict.append(')');
    self.ivt.dec(5);
    self.ivt.append(')');
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception();
  end;
  --
  member function get_text(self in out nocopy xxdoo_db_merge) return varchar2 is
    l_result varchar2(32767);
  begin
    self.build;
    return self.mt.get_text || chr(10) || self.ut.get_text || chr(10) || self.ot.get_text || chr(10) || 
             self.upt.get_text || chr(10) ||self.ict.get_text || chr(10) || self.ivt.get_text;
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception();
  end;
  --
end;
/
