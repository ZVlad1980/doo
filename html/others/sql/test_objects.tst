PL/SQL Developer Test script 3.0
21
declare
  l_ctx  xxweb.xxweb_api_el_context_typ := xxweb.xxweb_api_el_context_typ(
                                             p_name => 'ctx',
                                             p_source => xxweb.xxweb_api_source_typ('name','xxweb','xxweb_api_el_func_typ')
                                           );
  l_info xxweb.xxweb_member_info_typ;
  l_xml xmltype;
  l_output varchar2(32000);
begin
  l_info := xxweb.xxweb_api_utils_pkg.get_member_info(l_ctx, 'arguments');
  --
  select xmltype.createxml(l_info)
  into   l_xml
  from   dual;
  --
  if l_xml is not null then
    dbms_output.put_line(l_xml.getStringVal);
  else
    dbms_output.put_line('Not found');
  end if;
end;
0
2
l_dummy
l_type_name
