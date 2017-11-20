create or replace type body xxdoo_db_object_db is
  
  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin
    return upper('XXDOO.XXDOO_DB_OBJECT_DDL');
  end get_type_name;
  --
  constructor function xxdoo_db_object_db return self as result is
  begin 
    self.indent     := 0;
    self.new_line   := 'Y';
    self.spc_indent := 0;
    self.spc_nl     := 'Y';
    self.status     := 'C';
    --
    return;
  end;
  --
  constructor function xxdoo_db_object_db(p_position integer,
                                           p_type     varchar2,
                                           p_owner    varchar2,
                                           p_name     varchar2) return self as result is
  begin 
    --
    self := xxdoo_db_object_db;
    self.position := p_position;
    self.type     := p_type;
    self.owner    := p_owner;
    self.name     := p_name;
    --
    return;
  end;
                                           
  member procedure append(p_str varchar2, p_eof boolean default true) is
  begin
    self.body := self.body || 
      case self.new_line
        when 'Y' then
          rpad(' ',self.indent,' ')
      end ||
      p_str ||
      case p_eof
        when true then
          chr(10)
      end;
    --
    self.new_line := case p_eof
                       when true then
                         'Y'
                       else
                         'N'
                     end;
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception('Append string to script object '||self.name||' error.');
      raise;
  end append;
  --                                     
  member procedure appends(p_str varchar2, p_eof boolean default true) is
  begin
    self.spc := self.spc || 
      case self.spc_nl
        when 'Y' then
          rpad(' ',self.spc_indent,' ')
      end ||
      p_str ||
      case p_eof
        when true then
          chr(10)
      end;
    --
    self.spc_nl := case p_eof
                     when true then
                       'Y'
                     else
                       'N'
                   end;
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception('Append string to script object '||self.name||' error.');
      raise;
  end appends;
  --
  member procedure inc(p_value number default 2) is begin self.indent := self.indent + p_value; end inc;
  --
  member procedure dec(p_value number default 2) is 
  begin
    self.indent := self.indent - p_value; 
    if self.indent < 0 then
      self.indent := 0;
    end if;
  end dec;
  --
  member procedure incs(p_value number default 2) is begin self.spc_indent := self.spc_indent + p_value; end incs;
  --
  member procedure decs(p_value number default 2) is 
  begin
    self.spc_indent := self.spc_indent - p_value; 
    if self.spc_indent < 0 then
      self.spc_indent := 0;
    end if;
  end decs;
  --
  member function full_name return varchar2 is begin 
  return case
           when self.owner is not null then
             self.owner || '.'
         end ||self.name; 
  end full_name;
  --
  member procedure invoke is
  begin
    if self.status <> 'S' then
      dbms_output.put('Invoke '||self.type||' '||self.name||'...');
      execute immediate self.body;
      dbms_output.put_line('Ok');
      self.status := 'S';
      if self.type = 'type' then
        execute immediate 'grant execute,debug on '||self.name||' to apps with grant option';
      end if;
    end if;
  exception
    when others then
      dbms_output.put_line('Error');
      xxdoo_db_utils_pkg.fix_exception('Error script for object '||self.name||'.'||chr(10)||self.body);
      raise;
  end;
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
