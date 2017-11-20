PL/SQL Developer Test script 3.0
52
-- Created on 09.10.2014 by ZHURAVOV_VB 
declare 
  -- Local variables here
  json xxdoo.xxdoo_json;
  j_element xxdoo.xxdoo_json_element;
  l_json_str clob := 
    '{"path":"#ALL/New",'||
    '"meta":null,'||
    '"inputs":'||
      '{"contractor.name":"test",'||
        '"test_array":'||
          '[{"test1":"\"{[]}\""},'||
          '{"test2":"value2"}'||
        ']'||
      '},'||
    '"params":{"contractor2.name":"test2","test_array2":[{"test3":"\"{[]}\""},{"test4":"value2"}]}}';
  --
  function get_xml(s xxdoo.xxdoo_json) return xmltype is
    l_result xmltype;
  begin
    select xmlroot(xmltype.createxml(s), version 1.0)
    into l_result
    from dual;
    --
    return l_result;
  end;
  --
  procedure show_element is
  begin
    while json.next(j_element) loop
      --
      dbms_output.put_line(rpad(' ',json.levels.count,' ')||j_element.id || '('||j_element.type ||'): '||j_element.name || ' = '||j_element.value);
      if j_element.type in ('O','A') then 
        json.inside; 
        show_element; 
        json.outside; 
      end if;
    end loop;
  end;
begin
  --dbms_session.reset_package; return;
  -- Test statements here
  xxdoo.xxdoo_utl_pkg.init_exceptions;
  json := xxdoo.xxdoo_json(l_json_str);
  dbms_output.put_line(get_xml(json).getStringVal);
  json.first;
  show_element;
exception
  when others then
    xxdoo.xxdoo_utl_pkg.fix_exception;
    xxdoo.xxdoo_utl_pkg.show_errors;
end;
1
null
0
-5
5
el.type
j_element.id
j_element.type
j_element.name
levels.count
