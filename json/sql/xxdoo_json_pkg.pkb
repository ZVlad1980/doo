create or replace package body xxdoo_json_pkg is
  -----------------------------------------------------------------------------------------------------------
  -- Разработка XXDOO_JSON
  --   Публикация: 
  --
  --   
  --
  -- MODIFICATION HISTORY
  -- Person         Date         Comments
  -- ---------      ------       ------------------------------------------
  -- Журавов В.Б.   09.10.2014   Создание
  -----------------------------------------------------------------------------------------------------------
  --
  g_version varchar2(15) := '1.0.2';
  --
  type g_json_stack_element is record (
    type char,
    name varchar2(1024),
    id   number,
    array_num number,
    json varchar2(32767)
  );
  type g_json_stack_typ is table of g_json_stack_element;
  g_json_stack g_json_stack_typ;
  --
  function version return varchar2 is begin return g_version; end;
  --
  procedure push(p_object_id number,p_object_type varchar2, p_object_name varchar2, p_json varchar2) is
    begin
      g_json_stack.extend;
      g_json_stack(g_json_stack.count).type := p_object_type;
      g_json_stack(g_json_stack.count).name := p_object_name;
      g_json_stack(g_json_stack.count).json := p_json;
      g_json_stack(g_json_stack.count).id := p_object_id;
      g_json_stack(g_json_stack.count).array_num := 0;
    end;
    --
    function pop return varchar2 is
      l_result varchar2(32767);
    begin
      while l_result is null and g_json_stack.count > 0 loop
        l_result := g_json_stack(g_json_stack.count).json;
        g_json_stack.trim;
      end loop;
      return l_result;
    end;
    --
    function get_parent_type return char is
    begin
      if g_json_stack.count > 0 then
        return g_json_stack(g_json_stack.count).type;
      end if;
      return null;
    end;
    function get_parent_id return char is
    begin
      if g_json_stack.count > 0 then
        return g_json_stack(g_json_stack.count).id;
      end if;
      return null;
    end;
    --
    function get_array_num return varchar2 is
    begin
      if g_json_stack.count > 0 then
        g_json_stack(g_json_stack.count).array_num := g_json_stack(g_json_stack.count).array_num + 1;
        return g_json_stack(g_json_stack.count).name ||'.column_value';--|| (g_json_stack(g_json_stack.count).array_num);
      end if;
      return null;
    end;
  --
  --
  function get_json_type(p_char char) return char is
  begin
    return case p_char
             when '"' then
               'V'
             when '{' then
               'O'
             when '[' then
               'A'
             else
               'V'
           end;
  end;
  --
  --
  --
  procedure parse_json(p_json  in out nocopy varchar2, 
                       p_name  in out nocopy varchar2, 
                       p_value in out nocopy varchar2, 
                       p_type  in out nocopy varchar2,
                       p_parent_type  char) is
    l_pos number;
    --
    procedure set_pos(p_char char, p_pos in out nocopy number) is
      l_div_pos number := p_pos + 1;
      l_find_char char;
    begin
      l_find_char := case p_char 
              when '"' then '"'
              when '[' then ']'
              when '{' then '}'
              else ','
            end;
      p_pos := p_pos + 1;
      loop 
        p_pos := instr(p_json, l_find_char, p_pos);
        exit when l_find_char = '"' or p_pos = 0;
        --
        l_div_pos := regexp_instr(p_json, '"|{|\[', l_div_pos);
        exit when l_div_pos > p_pos or l_div_pos = 0;
        set_pos(substr(p_json,l_div_pos,1),l_div_pos);
        l_div_pos := l_div_pos+1;
        p_pos := l_div_pos;
      end loop;
      --
    end set_pos;
    --
  begin
    --
    if nvl(p_parent_type,'U') = 'A' then
      p_name := get_array_num;
    else
      p_name  := regexp_substr(p_json,'[^:]+',1,1);
      p_json := substr(p_json,length(p_name)+2,length(p_json));
      p_name  := substr(p_name,2,length(p_name)-2);
    end if;
    --
    p_value := null;
    l_pos := 0;
    --
    set_pos(',',l_pos);
    if l_pos > 0 then
      p_value := substr(p_json, 1, l_pos-1);
      p_json := substr(p_json, l_pos + 1);
    else
      p_value := p_json;
      p_json := null;
    end if;
    --
    p_type := get_json_type(substr(p_value,1,1));
    --
  end parse_json;
  --
  --
  --
  function parse_json(p_json clob) return xxdoo_json_elements pipelined is
    l_json varchar2(32767);
    l_quote_char varchar2(10) := '\"';
    l_object xxdoo_json_element;
    l_seq number;
    --
    function seq_next_val return number is
    begin
      l_seq := l_seq + 1;
      return l_seq;
    end;
    --
  begin
    l_json := replace(substr(p_json,2,length(p_json)-2),l_quote_char,chr(0));
    l_object := xxdoo_json_element();
    l_seq := 0;
    g_json_stack := g_json_stack_typ();
    --
    loop
      if l_json is null then
        l_json := pop;
        if l_json is null then
          exit;
        end if;
      end if;
      --
      parse_json(l_json, l_object.name, l_object.value, l_object.type, get_parent_type);
      l_object.parent_id := get_parent_id;
      l_object.id := seq_next_val;
      --
      l_object.value := case l_object.value
                          when 'null' then 
                            null
                          else
                            l_object.value
                        end; 
      if l_object.type in ('O','A') then
        --разбираем вложенный объект/массив
        push(l_object.id, l_object.type, l_object.name, l_json);
        l_json := substr(l_object.value,2,length(l_object.value)-2);
        l_object.value := null;
      else
        l_object.value := replace(replace(l_object.value,'"',null),chr(0),'"');
      end if;
      --
      pipe row (l_object);
    end loop;
    --
  end parse_json;
  --*/
end xxdoo_json_pkg;
/
