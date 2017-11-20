create or replace package body xxdoo_html_utils_pkg is
  -----------------------------------------------------------------------------------------------------------
  -- Разработка xxdoo_html. Создание WEB приложений
  --                       Публикация: 
  --
  --   Набор утилит
  --
  -- MODIFICATION HISTORY
  -- Person         Date         Comments
  -- ---------      ------       ------------------------------------------
  -- Журавов В.Б.   06.06.2014   
  -----------------------------------------------------------------------------------------------------------
  type g_exception_type is record(
    init            varchar2(1),
    description     varchar2(2000),
    call_stack      varchar2(2000),
    error_stack     varchar2(2000),
    error_backtrace varchar2(2000));
  --
  g_exception g_exception_type;
  --
  g_sequence number;
  --
  g_version varchar2(20) := '3.1.3';
  --
  function version return varchar2 is
  begin
    return g_version;
  end;    

  ---------------------------------------------------------------------
  function get_session_sequence return number is
  begin
    g_sequence := nvl(g_sequence,0) + 1;
    return g_sequence;
  end get_session_sequence;
  ------------------------------------------------------------------
  ------------------------------------------------------------------
  -- Процедура фиксации ошибки
  --   Предназначена для фиксации первой ошибки в рамках сессии.
  --   [p_description] - описание ошибки (например, параметры и т.д.)
  --  Вызывается из обработчиков ошибок. Записывает в глобальную переменную g_exception.
  --   Входящие:
  --     p_description - описание ошибки (комментарий и т.д.)
  --     p_type        - тип фиксации:
  --                       FULL (NULL) - фиксировать данные ошибки: стек и т.д.
  --                       DESC        - фиксировать только описание.
  ------------------------------------------------------------------
  procedure fix_exception(p_description in varchar2 default null) is
  begin
    --
    xxdoo_utl_pkg.fix_exception(p_description);
    --
  end fix_exception;
  --
  function get_exception_str(p_type in varchar2 default 'FULL') return varchar2 is
  begin
    return xxdoo_utl_pkg.get_first_exception_desc;
  end get_exception_str;
  --
  function get_object_type(p_object_owner  varchar2,
                           p_object_name   varchar2) return varchar2 is
    l_object_type xxdoo_html_objs_v.object_type%type;
  begin
    select o.type_code 
    into   l_object_type
    from   xxdoo_html_objs_v o
    where  rownum = 1
    and    o.object_name = upper(p_object_name)
    and    o.object_owner = upper(p_object_owner);
    --
    return l_object_type;
  exception
    when others then
      fix_exception('get_object_type(p_object_owner = '||p_object_owner||' p_object_name = '||p_object_name||'. ');
      raise;
  end;
  --
  --------------------------------------------------------------------------------------------------------------------
  --------------------------------------------------------------------------------------------------------------------
  -- Функция разбора тега (выделяет классы и ид в attrs) возвращает имя тега
  --------------------------------------------------------------------------------------------------------------------
  function parse_tag(p_tag   in varchar2,
                     p_attrs in out nocopy xxdoo_html_el_tag_attrs_typ) return varchar2 is
    l_tag varchar2(200) := p_tag;
    --
    cursor l_class_cur(p_str varchar2) is
      select level lvl,
             regexp_substr(p_str,'[^(#\.)]+',1,level) value
      from   dual
      connect by regexp_substr(p_str,'[^(#\.)]+',1,level)  is not null
      order by level desc; --идем в обратном порядке, т.к. значения добавляются в начало
  begin
    if p_attrs is null then
      p_attrs := xxdoo_html_el_tag_attrs_typ();
    end if;
    --
    for c in l_class_cur(p_tag) loop
      if c.lvl = 1 then
        l_tag := c.value;
      elsif c.lvl = 2 and instr(l_tag,'#') > 0 then
        p_attrs.attr('id',c.value);
      else
        p_attrs.attr('class',c.value);
      end if;
    end loop;
    --
    return l_tag;
    --
  end parse_tag;
  --
  function get_function_xml(p_fn_name varchar2,
                            p_fn_args g_fn_args) return xmltype is
    l_result xmltype;
    l_arg    xmltype;
    --
    function get_xml_arg(p_arg varchar2) return xmltype is
      l_result xmltype;
    begin
      select case
               when substr(p_arg,1,1) = chr(0) then
                 xmlelement("A",xmltype(replace(p_arg,chr(0))))
               else
                 xmlelement("A",replace(p_arg,chr(0)))
             end
      into   l_result
      from   dual;
      --l_args := substr(l_args || '<' || p_tag || replace(p_arg,chr(0)) || '</' || p_tag ,1,32000);
      return l_result;
    end get_xml_arg;
  begin
    for i in 1..p_fn_args.count loop
      l_arg := get_xml_arg(p_fn_args(i));
      select xmlconcat(l_result,
                       l_arg)
      into   l_result
      from   dual;
    end loop;
    --
    select xmlelement("F",xmlelement("N",p_fn_name),xmlforest(l_result as "AS"))
    into   l_result
    from   dual;
    --
    return l_result;
  exception
    when others then
      fix_exception('get_function_xml error.');
      raise;
  end get_function_xml;
  --
  function get_function_str(p_fn_name varchar2,
                            p_fn_args g_fn_args) return varchar2 is
  begin
    return chr(0) || get_function_xml(p_fn_name,p_fn_args).getStringVal;
  end;
  --
  --Функция возвращает описание члена объекта (поле, метод и т.д.)
  --
  function get_member_info(p_src  xxdoo_html_ap_source_typ, 
                           p_path varchar2) return xxdoo_html_el_member_info_typ is
    --
    l_member xxdoo_html_el_member_info_typ := xxdoo_html_el_member_info_typ(p_src.object_owner,
                                                                          p_src.object_name);
    cursor l_members_cur(p_owner       varchar2, 
                         p_name        varchar2, 
                         p_member_name varchar2) is
      select xxdoo_html_el_member_info_typ(m.member_name, 
                                           m.data_type, 
                                           m.data_type_owner, 
                                           m.data_type_code, 
                                           m.lenght) obj
      from   xxdoo_html_obj_members_v m--xxdoo_html_obj_types_v c
      where  1 = 1
      and    m.member_name = p_member_name
      and    m.object_name = p_name
      and    m.object_owner = p_owner;
    --
    cursor l_fields_cur(p_path varchar2) is
      select regexp_substr(p_path,'[^/.]+',1,level) column_name
      from   dual
      connect by regexp_substr(p_path,'[^/.]+',1,level) is not null;
  begin
    --
    for f in l_fields_cur(p_path) loop
      open l_members_cur(l_member.data_type_owner,
                         l_member.data_type,
                         upper(f.column_name));
      fetch l_members_cur
        into l_member;
      --
      if l_members_cur%notfound = true then
        raise no_data_found;
      end if;
      --
      close l_members_cur;
    end loop;
    --
    return l_member;
  exception
    when no_data_found then
      close l_members_cur;
      return null;
    when others then
      close l_members_cur;
      fix_exception('get_member_type_info error.');
      raise;
  end get_member_info; 
  --
  function get_collection_info(p_member_info xxdoo_html_el_member_info_typ) return xxdoo_html_el_member_info_typ is
    l_member xxdoo_html_el_member_info_typ;
  begin
    select xxdoo_html_el_member_info_typ(ct.ELEM_TYPE_OWNER,ct.ELEM_TYPE_NAME)
    into   l_member
    from   all_coll_types ct
    where  1=1
    and    ct.type_name = p_member_info.data_type
    and    ct.owner = p_member_info.data_type_owner;
    --
    return l_member;
  end;
  --
  function get_status_obj(p_type  varchar2,
                          p_owner varchar2,
                          p_name  varchar2) return varchar2 is
  begin
    return xxdoo_utl_pkg.get_status_obj(p_type,p_owner,p_name);
  end;
  --
  procedure compile_obj(p_type    varchar2,
                        p_owner   varchar2, 
                        p_name    varchar2,
                        p_content clob) is
  begin
    execute immediate p_content;
    if get_status_obj(p_type,p_owner,p_name) <> 'VALID' then
      xxdoo_html_utils_pkg.fix_exception('Error compile '||p_type||' '||p_owner || '.' || p_name);
      raise apps.fnd_api.g_exc_error;
    end if;
  end;
  --
  function exists_member(p_source      xxdoo_html_ap_source_typ,
                         p_member_name varchar2,
                         p_member_type varchar2) return varchar2 is
    l_member xxdoo_html_el_member_info_typ;
    l_result varchar2(1) := 'N';
  begin
    l_member := get_member_info(p_source,upper(p_member_name));
    --
    if l_member is not null then 
      if l_member.data_type_code = upper(p_member_type) then
        l_result := 'Y';
      end if;
    end if;
    --
    return l_result;
  end;
  --
  function exists_function_type(p_source      xxdoo_html_ap_source_typ,
                                p_method_name varchar2) return varchar2 is
  begin
    return exists_member(p_source,p_method_name,'FUNCTION');
  end;
  --
  function exists_procedure_type(p_source      xxdoo_html_ap_source_typ,
                                p_method_name varchar2) return varchar2 is
  begin
    return exists_member(p_source,p_method_name,'PROCEDURE');
  end;
  --
  procedure log(p_msg varchar2) is
    pragma autonomous_transaction; 
    --create table xxdoo_html_log_t(msg varchar2(3000),creation_date date)
  begin
    insert into xxdoo_html_log_t(msg, creation_date)values(p_msg,sysdate);
    commit;
  exception
    when others then
     rollback;
  end;
  --
begin
  begin
    select pov.profile_option_value || g_path_oracle_client
    into   g_path_oracle_client
    from   apps.fnd_profile_options       po,
           apps.fnd_profile_option_values pov
    where  1=1
    and    pov.level_id = 10001
    and    pov.profile_option_id = po.profile_option_id
    and    pov.application_id = po.application_id
    and    po.profile_option_name = 'APPS_JSP_AGENT';
  exception
    when others then
      null;
  end;
end xxdoo_html_utils_pkg;
/
