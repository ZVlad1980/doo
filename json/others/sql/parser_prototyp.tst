PL/SQL Developer Test script 3.0
77
-- Created on 09.10.2014 by ZHURAVOV_VB 
declare 
  -- Local variables here
  j varchar2(4000) := --'path:{t1:"{\"\"}"}';
  '"path":"#ALL/New","meta":null,'||
  '"inputs":{"contractor.name":"test","test_array":[{"test1":"\"{[]}\""},{"test2":"value2"}]},'||
  '"params":{"contractor2.name":"test","test_array2":[{"test3":"\"{[]}\""},{"test4":"value4"}]}';
  l_value varchar2(4000);
  l_key varchar2(200);
  l_type varchar2(1);
  --
  procedure parse_expr(p_json in out nocopy varchar2, p_key in out nocopy varchar2, p_value in out nocopy varchar2) is
    l_pos number;
    l_json_len number;
    --
    procedure find_div(p_char char, p_pos in out nocopy number) is
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
        find_div(substr(p_json,l_div_pos,1),l_div_pos);
        l_div_pos := l_div_pos+1;
        p_pos := l_div_pos;
      end loop;
      --
    end;
  begin
    p_key    := regexp_substr(p_json,'[^:]+',1,1);
    p_json := substr(p_json,length(p_key)+2,length(p_json));
    p_value := null;
    l_json_len := length(p_json);
    l_pos := 0;
    --
    find_div(',',l_pos);
    if l_pos > 0 then
      p_value := substr(p_json, 1, l_pos-1);
      p_json := substr(p_json, l_pos + 1);
    else
      p_value := p_json;
      p_json := null;
    end if;
    --
  end;
begin
  -- Test statements here
  --return;
  j := replace(j,'\"',chr(0));
  while j is not null loop
    parse_expr(j, l_key, l_value);
    l_type := case substr(l_value,1,1)
                when '"' then
                  'V'
                when '{' then
                  'O'
                when '[' then
                  'A'
                when 'n' then
                  'V'
                else
                  'U'
              end;
    --
    dbms_output.put_line(l_type || ': ' ||l_key || ' = ' || replace(l_value,chr(0),'\"'));
  end loop;
end;
0
2
p_json
l_div_pos
