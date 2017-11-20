create or replace type body xxdoo_db_text is
  
  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin
    return upper('XXDOO.XXDOO_DB_TEXT');
  end get_type_name;
  --
  -- 
  --
  constructor function xxdoo_db_text(p_indent number default 0) return self as result is
  begin
    self.lines := xxdoo_db_text_lines();
    self.indent := p_indent;
    self.nl     := 'Y';
    --
    return;
  end;
  --
  member procedure append(p_str varchar2, p_eof boolean default true) is
    --
    procedure a(p_str varchar2) is
    begin
      self.lines(self.lines.count).text := self.lines(self.lines.count).text || p_str;
    end;
    --
  begin
    if self.nl = 'Y' then
      self.lines.extend;
      self.lines(self.lines.count) := xxdoo_db_text_line(self.lines.count,rpad(' ',self.indent,' '));
    end if;
    --
    a(p_str);
    --
    if p_eof then
      a(chr(10));
      self.nl := 'Y';
    else
      self.nl := 'N';
    end if;
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;--('Append string to script object '||self.name||' error.');
      raise;
  end append;
  --
  member procedure inc(p_value number default 2) is begin self.indent := self.indent + p_value; end;
  --
  member procedure dec(p_value number default 2) is 
  begin 
    self.indent := self.indent - p_value;
    if self.indent < 0 then
      self.indent := 0;
    end if;
  end;
  --
  member function get_text return varchar2 is 
    l_result varchar2(32767);
  begin 
    for l in 1..self.lines.count loop
      l_result := l_result || 
                    case
                      when l = self.lines.count then
                        replace(self.lines(l).text,chr(10),null)
                      else
                        self.lines(l).text
                    end;
    end loop;
    --
    return l_result; 
  end;
  --
  member function get_clob return clob  is 
    l_result clob;
  begin 
    dbms_lob.createtemporary(l_result,true);
    for l in 1..self.lines.count loop
      dbms_lob.append(
        l_result,
        case
          when l = self.lines.count then
            replace(self.lines(l).text,chr(10),null)
          else
            self.lines(l).text
        end
      );
    end loop;
    --
    return l_result; 
    -- 
  end;
  --
  member procedure first  is 
  begin 
    self.iterator := 0; 
  end;
  --
  member function next(self in out nocopy xxdoo_db_text, p_str in out nocopy varchar2) return boolean is
    l_result boolean := true;
  begin
    self.iterator := self.iterator + 1;
    if self.iterator > self.lines.count then
      l_result := false;
    else
      p_str := replace(self.lines(self.iterator).text,chr(10),null);
    end if;
    return l_result;
  end;
  --
end;
/
