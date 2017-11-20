-- ----------------------------------------------------------------------------
-- Key-value pair element body
-- ----------------------------------------------------------------------------
create or replace type body xxdoo_p2r_key as
  constructor function xxdoo_p2r_key return self as result is
  begin
    key         := null;
    regexp      := null;
    required    := 'Y';
    capture_it  := 'N';
    stop_flag   := 'N';
    return;
  end;
end;
/

-- ----------------------------------------------------------------------------
-- Main parser object
-- ----------------------------------------------------------------------------
create or replace type body xxdoo_p2r_parser as
  -- --------------------------------------------------------------------------
  member procedure initialize(p_template in varchar2) is
    current integer;
    procedure trimRight(p_string in out nocopy string) is begin p_string := substr(p_string,1,length(p_string)-1); end;
  begin
    -- Initialize objects
    parts    := xxdoo_p2r_keys();
    parsed   := xxdoo_p2r_set();
    iterator := 1;
    for part in (
      select regexp_substr(p_template,'[^/]+',1,level) p
      from dual
      connect by regexp_substr(p_template,'[^/]+',1,level) is not null
    ) loop
      -- Process only non-empty values
      if part.p is null then continue; end if;
      -- Prepare new record
      parts.extend();
      current := parts.count;
      parts(current) := xxdoo_p2r_key();
      -- parce regexped
      parts(current).key    := trim(regexp_substr(part.p,'[^()]+',1,1));
      parts(current).regexp := trim(regexp_substr(part.p,'[^()]+',1,2));
      if parts(current).regexp is not null then
        parts(current).key := parts(current).key || trim(regexp_substr(part.p,'[^()]+',1,3));
      end if;  
      -- Check if cpaturable
      if parts(current).key like ':%' then
        parts(current).capture_it := 'Y';
        parts(current).key := substr(parts(current).key,2); 
      end if;
      -- Check special characters
      case substr(parts(current).key,-1)
        when '*' then trimRight(parts(current).key); parts(current).stop_flag := 'Y';          
        when '?' then trimRight(parts(current).key); parts(current).required  := 'N';
        else null;
      end case; 
    end loop;
  end;
  -- --------------------------------------------------------------------------
  constructor function xxdoo_p2r_parser(p_template in varchar2) return self as result is
  begin
    self.initialize(p_template);
    return;
  end;
  -- --------------------------------------------------------------------------
  constructor function xxdoo_p2r_parser(p_template in varchar2,p_path in varchar2) return self as result is
  begin
    self.initialize(p_template);
    self.parse(p_path);
    return;
  end;
  -- --------------------------------------------------------------------------
  member function parse(self in out nocopy xxdoo_p2r_parser,p_path in varchar2) return xxdoo_p2r_set is
  begin
    self.parse(p_path);
    return parsed;
  end;
  -- --------------------------------------------------------------------------
  member procedure parse(p_path in varchar2) is
    l_check_index  integer := 1;
    l_stop_parsing boolean := false;
  begin
    parsed := xxdoo_p2r_set();
    for part in (
      select regexp_substr(p_path,'[^/]+',1,level) p
      from dual
      connect by regexp_substr(p_path,'[^/]+',1,level) is not null
    ) loop
      <<looper>>
      exit when l_check_index > parts.count;
      -- If stop parsing  - stop parsing
      if l_stop_parsing then
        parsed(parsed.count).value := parsed(parsed.count).value || '/' || part.p;
        continue; 
      end if;
      if parts(l_check_index).stop_flag = 'Y' then
        l_stop_parsing := true;
        parsed.extend();
        parsed(parsed.count) := xxdoo_p2r_element(parts(l_check_index).key,part.p);
        continue;
      end if;
      -- If defined value (not captured) and value not equal current part - do not match query
      if parts(l_check_index).capture_it = 'N' and part.p != parts(l_check_index).key then
        parsed := xxdoo_p2r_set();
        return;
      end if;      
      -- If required or matched current expresion or exporession is not defined - process it
      if parts(l_check_index).regexp is null
         or regexp_replace(part.p,parts(l_check_index).regexp,'') is null then
        parsed.extend();
        parsed(parsed.count) := xxdoo_p2r_element(parts(l_check_index).key,part.p);
        l_check_index := l_check_index + 1;
        continue;
      end if;   
      -- If not match and required - break all
      if parts(l_check_index).required = 'Y' then
        parsed := xxdoo_p2r_set();
        return;
      end if;
      l_check_index := l_check_index + 1;
      goto looper;
    end loop;
  end;
  -- --------------------------------------------------------------------------
  member function valueOf(p_key in varchar2) return varchar2 is
  begin
    for i in 1..parsed.count loop
      if parsed(i).key = p_key then return parsed(i).value; end if;
    end loop;
    return null;
  end;
  -- --------------------------------------------------------------------------
  member procedure first is
  begin
    self.iterator := 1; 
  end;
  -- --------------------------------------------------------------------------
  member function next(self in out nocopy xxdoo_p2r_parser,p_key out varchar2,p_value out varchar2) return boolean is
  begin
    if iterator > parsed.count then 
      p_key   := null;
      p_value := null;
      return false; 
    end if; 
    self.next(p_key,p_value);
    return true;
  end;
  -- --------------------------------------------------------------------------
  member procedure next(p_key out varchar2,p_value out varchar2) is
  begin
    if iterator <= parsed.count then
      p_key   := parsed(iterator).key;
      p_value := parsed(iterator).value;
      iterator := iterator+1; 
    else
      p_key   := null;
      p_value := null;
    end if;
  end;
  -- --------------------------------------------------------------------------
end;
/



-- ----------------------------------------------------------------------------
-- Parsers query
-- ----------------------------------------------------------------------------
create or replace type body xxdoo_p2r_query as 
  -- --------------------------------------------------------------------------
  constructor function xxdoo_p2r_query return self as result is
  begin
    parsers := xxdoo_p2r_parsers();
    return;
  end;
  -- --------------------------------------------------------------------------
  constructor function xxdoo_p2r_query(p_templates in varchar2) return self as result is
  begin
    parsers := xxdoo_p2r_parsers();
    for part in (
      select regexp_substr(p_templates,'[^,'||chr(10)||']+',1,level) p
      from dual
      connect by regexp_substr(p_templates,'[^,'||chr(10)||']+',1,level) is not null
    ) loop
      if trim(part.p) is not null then 
        parsers.extend();
        parsers(parsers.count) := new xxdoo_p2r_parser_key(
                                        trim(regexp_substr(part.p,'[^=]+',1,1)),
                                        new xxdoo_p2r_parser(trim(regexp_substr(part.p,'[^=]+',1,2)))
                                      );
      end if;                                      
    end loop;
    return;
  end;
  -- --------------------------------------------------------------------------
  member procedure addTemplate(p_template in varchar2,p_name in varchar2) is
  begin
    parsers.extend();
    parsers(parsers.count) := new xxdoo_p2r_parser_key(
                                    p_name,
                                    new xxdoo_p2r_parser(p_template)
                                  );
  end;
  -- --------------------------------------------------------------------------
  member function query(self in out nocopy xxdoo_p2r_query,p_path in varchar2) return xxdoo_p2r_parser  is
    l_name varchar2(1024);
  begin
    return self.query(p_path,l_name);
  end;
  -- --------------------------------------------------------------------------
  member function query(self in out nocopy xxdoo_p2r_query,p_path in varchar2,p_name out varchar2) return xxdoo_p2r_parser  is
  begin
    for i in 1..parsers.count loop
      if parsers(i).parser.parse(p_path).count > 0 then
        p_name := parsers(i).name;
        return parsers(i).parser; 
      end if; 
    end loop;
    return null;
  end;
  -- --------------------------------------------------------------------------
end;
/  
