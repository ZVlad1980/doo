create or replace type body xxdoo_db_select is
  
  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin
    return upper('XXDOO.XXDOO_DB_SELECT');
  end get_type_name;
  --
  -- 
  --
  constructor function xxdoo_db_select(p_indent number default 0) return self as result is
  begin
    self.st := xxdoo_db_text(p_indent);
    self.ft := xxdoo_db_text(p_indent);
    self.wt := xxdoo_db_text(p_indent);
    self.ob := xxdoo_db_text(p_indent);
    self.gb := xxdoo_db_text(p_indent);
    --
    return;
  end;
  --new line for select and from
  member procedure new_line(p_obj in out nocopy xxdoo_db_text, p_command varchar2) is
  begin
    if p_obj.lines.count = 0 then
      p_obj.append(rpad(p_command,7,' '),false);
      p_obj.inc(7);
    else
      p_obj.append(',');
    end if;
  end;
  --
  member procedure s(p_str varchar2) is
  begin
    if self.st.lines.count = 0 then
      self.st.append(rpad('select',7,' '),false);
      self.st.inc(7);
    else
      self.st.append(',');
    end if;
    --
    self.st.append(p_str,false);
  end;
  --
  member procedure s(p_select in out nocopy xxdoo_db_select, p_alias varchar2) is
    l_str varchar2(32767);
  begin
    if self.st.lines.count = 0 then
      self.st.append(rpad('select',7,' '),false);
      self.st.inc(7);
    else
      self.st.append(',');
    end if;
    --
    self.st.append('(',false);
    self.st.inc(1);
    p_select.first;
    while p_select.next(l_str) loop
      self.st.append(l_str);
    end loop;
    self.st.dec(1);
    self.st.append(') '||p_alias,false);
    
  end;
  --
  member procedure s(p_text in out nocopy xxdoo_db_text, p_alias varchar2) is
    l_str varchar2(32767);
    l_is_first boolean := true;
  begin
    if self.st.lines.count = 0 then
      self.st.append(rpad('select',7,' '),false);
      self.st.inc(7);
    else
      self.st.append(',');
    end if;
    --
    --self.st.append('(',false);
    --self.st.inc(1);
    p_text.first;
    while p_text.next(l_str) loop
      if not l_is_first then
        self.st.append(null);
      end if;
      self.st.append(l_str,false);
      l_is_first := false;
    end loop;
    --self.st.dec(1);
    self.st.append(' '||p_alias,false);
    
  end;
  --
  member procedure f(p_str varchar2) is
  begin
    if self.ft.lines.count = 0 then
      self.ft.append(rpad('from',7,' '),false);
      self.ft.inc(7);
    else
      self.ft.append(',');
    end if;
    --
    self.ft.append(p_str,false);
  end;
  --
  member procedure f(p_select  in out nocopy xxdoo_db_select, p_alias varchar2) is
    l_str varchar2(32767);
  begin
    if self.ft.lines.count = 0 then
      self.ft.append(rpad('from',7,' '),false);
      self.ft.inc(7);
    else
      self.ft.append(',');
    end if;
    --
    self.ft.append('(',false);
    self.ft.inc(1);
    p_select.first;
    while p_select.next(l_str) loop
      self.ft.append(l_str);
    end loop;
    self.ft.dec(1);
    self.ft.append(') '||p_alias,false);
    
  end;
  --
  --
  --
  member procedure f(p_text in out nocopy xxdoo_db_text, p_alias varchar2) is
    l_str varchar2(32767);
    l_is_first boolean := true;
  begin
    if self.ft.lines.count = 0 then
      self.ft.append(rpad('from',7,' '),false);
      self.ft.inc(7);
    else
      self.ft.append(',');
    end if;
    --
    --self.st.append('(',false);
    --self.st.inc(1);
    p_text.first;
    while p_text.next(l_str) loop
      if not l_is_first then
        self.ft.append(null);
      end if;
      self.ft.append(l_str,false);
      l_is_first := false;
    end loop;
    --self.st.dec(1);
    self.ft.append(' '||p_alias,false);
    --
  end;
  --
  member procedure w(p_cond varchar2, p_value varchar2) is
  begin
    if self.wt.lines.count = 0 then
      self.wt.append('where  1=1',false);
    end if;
    --
    self.wt.append(null);
    if upper(p_cond) = 'AND' then
      self.wt.append('and    ',false);
    else
      xxdoo_db_utils_pkg.fix_exception('SELECT: add line to where: unknown condition '||p_cond);
      raise apps.fnd_api.g_exc_error;
    end if;
    --
    self.wt.append(p_value,false);
  end;
  --
  member procedure w(p_value varchar2) is
  begin
    w('and',p_value);
  end;
  --
  member procedure o(p_value varchar2) is
  begin
    if self.ob.lines.count = 0 then
      self.ob.append(' order by ',false);
      self.ob.inc(9);
    else
      self.ob.append(',');
    end if;
    --
    self.ob.append(p_value,false);
    --
  end;
  --
  member procedure g(p_value varchar2) is
  begin
    if self.gb.lines.count = 0 then
      self.gb.append('group by ',false);
      self.gb.inc(9);
    else
      self.gb.append(',');
    end if;
    --
    self.gb.append(p_value,false);
    --
  end;
  --
  --
  member function build return varchar2 is
  begin
    return self.st.get_text || chr(10) || self.ft.get_text || chr(10) || self.wt.get_text || self.gb.get_text || self.ob.get_text;
  end;
  --
  member procedure first is
  begin
    self.current_line := 0;
    self.current_block := 'select';
  end;
  --
  member function next(self in out nocopy xxdoo_db_select, p_str in out nocopy varchar2) return boolean is
    l_result boolean := true;
  begin
    self.current_line := self.current_line + 1;
    p_str := null;
    --
    if self.current_block = 'select' then
      if self.st.lines.exists(self.current_line) then
        p_str := p_str || self.st.lines(self.current_line).text;
      else
        self.current_line  := 1;
        self.current_block := 'from';
      end if;
    end if;
    --
    if self.current_block = 'from' then
      if self.ft.lines.exists(self.current_line) then
        p_str := p_str || self.ft.lines(self.current_line).text;
      else
        self.current_line  := 1;
        self.current_block := 'where';
      end if;
    end if;
    --
    if self.current_block = 'where' then
      if self.wt.lines.exists(self.current_line) then
        p_str := p_str || self.wt.lines(self.current_line).text;
      else
        self.current_line  := 1;
        self.current_block := 'group';
        l_result := false;
      end if;
    end if;
    --
    if self.current_block = 'group' then
      if self.gb.lines.exists(self.current_line) then
        p_str := p_str || self.gb.lines(self.current_line).text;
      else
        self.current_line  := 1;
        self.current_block := 'order';
        l_result := false;
      end if;
    end if;
    --
    if self.current_block = 'order' then
      if self.ob.lines.exists(self.current_line) then
        p_str := p_str || self.ob.lines(self.current_line).text;
      else
        self.current_line  := 0;
        self.current_block := 'select';
        l_result := false;
      end if;
    end if;
    --
    p_str := replace(p_str,chr(10),'');
    --
    return l_result;
    --
  end;
  --
end;
/
