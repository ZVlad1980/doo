create or replace package body xxdoo_utils_pkg is
  --
  /*type g_field_typ is record(
    name varchar2(30),
    value varchar2(200)
  );
  type g_fields_typ is table of g_field_typ index by binary_integer;
  --
  type g_table_typ is record (
    parent_table_name varchar2(60),
    alias             varchar2(60),
    pk_field          varchar2(60),
    fk_field          varchar2(60),
    fields            g_fields_typ
  );
  type g_tables_typ is table of g_table_typ index by varchar2(60);
  type g_select_typ is record (
    select_from varchar2(2000),
    select_where varchar2(4000),
    tables       g_tables_typ
  );
  type g_selects_typ is table of g_select_typ index by binary_integer;
  --
  --g_selects g_selects_typ;
  --*/
  function char_to_number(p_value varchar2, p_format varchar2) return number is
  begin
    return to_number(p_value);
  exception
    when others then
      return null;
  end;
  --
  function char_to_integer(p_value varchar2, p_format varchar2) return integer is
    --l_result integer;
  begin
   -- l_result := to_number(p_value);
    return to_number(p_value);
  exception
    when others then
      return null;
  end;
  
  --
  function char_to_date(p_value varchar2, p_format varchar2) return date is
  begin
    return to_date(p_value,'yyyy-mm-dd');
  exception
    when others then
      return null;
  end;
  --
  --
  /*
  function parser_conditions(p_scheme_id number, p_conditions varchar2) return varchar2 is
  --
  --
  function get_select_on_conditions(p_scheme_name number, p_conditions varchar2) return varchar2 is
    l_result varchar2(32000);
    l_main_alias varchar2(1) := 'm';
    l_main_pk_field varchar2(1);
    l_selects g_selects_typ;
    procedure add_select(p_from varchar2, p_where varchar2) is
    begin
      l_result := l_result ||
             case 
               when l_result is not null then 
                 chr(10)||'union'||chr(10)
             end ||
             'select '||l_main_alias||'.'|| l_main_pk_field || chr(10) ||
             'from ' ||p_from||chr(10)||'where '||nvl(p_where,'1=1');
    end;
  begin
    
    --
    l_selects := parser_conditions(p_scheme_id, p_conditions);
    --
    create_selects(l_selects,p_conditions);
    --
    for i in 1..g_selects.count loop
      add_select(g_selects(i).select_from,
                 g_selects(i).select_where);
    end loop;
    --
    return l_result;
  end;--*/
end xxdoo_utils_pkg;
/
