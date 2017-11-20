create or replace package body xxdoo_db_utils_pkg is
  -----------------------------------------------------------------------------------------------------------
  -- Разработка xxdoo_DB. Создание объектов БД по описанию
  --   Публикация: 
  --
  --   Набор утилит, используемых в раках разработки
  --
  -- MODIFICATION HISTORY
  -- Person         Date         Comments
  -- ---------      ------       ------------------------------------------
  -- Журавов В.Б.   16.07.2014   Создание
  --                30.07.2014   Добавил функцию get_entity_info
  -----------------------------------------------------------------------------------------------------------
  --
  g_conc_request_id number := apps.fnd_global.conc_request_id;
  --
  g_sequence integer;
  --
  type g_change_type_typ is record(
    change_type varchar2(100),
    fn_formating varchar2(100)
  );
  type g_change_types_typ is table of g_change_type_typ index by varchar2(100);
  g_change_types g_change_types_typ;
  --
  -----------------------------------------------------------------------------------------------------------
  -- Вывод сообщений
  -----------------------------------------------------------------------------------------------------------
  procedure plog(p_msg in varchar2,
                 p_eof in boolean default true) is
  begin
    xxdoo_utl_pkg.plog(p_msg, p_eof);
  end plog;
  --
  --
  --
  procedure init_exceptions is
  begin
     xxdoo_utl_pkg.init_exceptions;
  end;
  --
  function get_first_exception_desc return varchar2 is
  begin
    return xxdoo_utl_pkg.get_first_exception_desc;
  end;
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
    xxdoo_utl_pkg.fix_exception(p_description);
    --
  end fix_exception;
  --
  --
  --
  procedure show_errors is
  begin
    xxdoo_utl_pkg.show_errors;
  end;
  --
  function is_object_exists(p_owner varchar2, p_name varchar2, p_object_type varchar2 default null) return boolean is
    cursor l_object_cur is
      select count(*)
      from   all_objects t
      where  1=1
      and    t.object_type = nvl(upper(p_object_type),t.object_type)
      and    t.owner = upper(p_owner)
      and    t.object_name = upper(p_name);
    --
    l_dummy  number;
  begin
    open l_object_cur;
    fetch l_object_cur into l_dummy;
    close l_object_cur;
    --
    return case 
             when l_dummy = 0 then
               false
             else
               true
           end;
  exception
    when others then
      fix_exception('is_object_exists(p_owner = '||p_owner||', p_name = '||p_name||')');
      raise;
  end;
  --
  --
  --
  function parse_column_list(p_columns varchar2) return xxdoo_db_columns is
    cursor l_parse_cur is
      select xxdoo_db_column(regexp_substr(p_columns,'[^,]+',1,level), level) column_value
      from   dual
      connect by regexp_substr(p_columns,'[^,]+',1,level) is not null;
    l_result xxdoo_db_columns;
  begin
    open l_parse_cur;
    fetch l_parse_cur bulk collect into l_result;
    close l_parse_cur;
    --
    return l_result;
  exception
    when others then
      fix_exception('parse_column_list(p_columns = '||p_columns||')');
      raise;
  end parse_column_list;
  --
  --
  --
  function object_name(p_dev_code varchar2, p_name varchar2, p_type varchar2) return varchar2 is
    l_ext varchar2(4);
  begin
  if p_type= 'SEQUENCE' then  
    null;
  end if;
    l_ext := case upper(p_type)
               when 'TABLE' then
                 't'
               when 'VIEW' then
                 'v'
               when 'TRIGGER' then
                 'tr'
               when 'INDEX' then
                 'n'
               when 'UNIQUE INDEX' then
                 'u'
               when 'SEQUENCE' then
                 'seq'
               when 'TYPE' then
                 'typ'
             end;
    if l_ext is null then
      fix_exception('object_name unknown object type: '||p_type);
      raise apps.fnd_api.g_exc_error;
    end if;
    --
    return p_dev_code||'_'||p_name||'_'||l_ext;
    --
  exception
    when others then
      fix_exception('object_name(p_dev_code ='||p_dev_code||', p_type = '||p_type||')');
      raise;
  end;
  --
  --
  --
  function columns_as_string(p_col_list xxdoo_db_columns) return varchar2 is
    l_result varchar2(400);
  begin
    for c in 1..p_col_list.count loop
      l_result := l_result || 
                    case
                        when l_result is not null then
                          ','
                    end || 
                    p_col_list(c).name;
    end loop;
    --
    return l_result;
  end columns_as_string;
  --
  --
  --
  procedure seq_init is
  begin
    g_sequence := 0;
  end;
  --
  --
  --
  function seq_nextval return integer is
  begin
    g_sequence := g_sequence + 1;
    return g_sequence;
  end;
  --
  --
  --
  procedure change_type_init is
    procedure add_change_type(p_type varchar2, p_change_type varchar2, p_fn_formating varchar2) is
    begin  
      g_change_types(p_type).change_type  := p_change_type;
      g_change_types(p_type).fn_formating := p_fn_formating;
    end;
  begin
    g_change_types.delete;
    add_change_type('NUMBER','VARCHAR2(100)','xxdoo_utils_pkg.char_to_number');
    --add_change_type('INTEGER','VARCHAR2(100)','xxdoo_utils_pkg.char_to_integer');
    add_change_type('DATE','VARCHAR2(30)','xxdoo_utils_pkg.char_to_date');
  end;
  --
  --
  --
  function get_type_xml(p_type varchar2, p_length number, p_scale number) return varchar2 is
  begin
    return case
             when g_change_types.exists(p_type) = true then
               g_change_types(p_type).change_type
             else
               p_type ||
                 case
                   when p_length is not null then
                     '(' || p_length ||
                     case
                       when p_scale is not null then
                         ', '||p_scale||')'
                     end || ')'
                 end
           end;
  end get_type_xml;
  --
  --
  --
  function get_fn_format_xml(p_type varchar2) return varchar2 is
  begin
    return case
             when g_change_types.exists(p_type) = true then
               g_change_types(p_type).fn_formating
             else
               null
           end;
  end get_fn_format_xml;
  --
  -- Функция возвращает описание сущности
  --
  /*function get_entity_info(p_scheme_id number, p_entity_name varchar2) return g_entity_typ is
    l_result g_entity_typ;
    --
    cursor l_entity_cur is
      select e.id, 
             s.id scheme_id,
             s.owner, 
             e.name, 
             oo.name object_name, 
             oc.name collect_name, 
             ot.name table_name, 
             ov.name view_name, 
             os.name sequence_name,
             f.name  pk_field,
             f.type  pk_type
      from   xxdoo_db_entities_t e,
             xxdoo_db_objects_t  oo,
             xxdoo_db_objects_t  oc,
             xxdoo_db_objects_t  ot,
             xxdoo_db_objects_t  ov,
             xxdoo_db_objects_t  os,
             xxdoo_db_schemes_t  s,
             xxdoo_db_fields_t   f
      where  1=1
      and    f.is_pk(+) = 'Y'
      and    f.entity_id(+) = e.id
      and    os.type(+) = 'SEQUENCE'
      and    os.entity_id(+) = e.id
      and    ov.type(+) = 'VIEW'
      and    ov.entity_id(+) = e.id
      and    ot.type(+) = 'TABLE'
      and    ot.entity_id(+) = e.id
      and    oc.object_type(+) = 'COLLECTION'
      and    oc.type(+) = 'TYPE'
      and    oc.entity_id(+) = e.id
      and    oo.object_type(+) = 'OBJECT'
      and    oo.type(+) = 'TYPE'
      and    oo.entity_id(+) = e.id
      and    e.name = p_entity_name
      and    e.scheme_id = s.id
      and    s.id = p_scheme_id;
    --
  begin
    open l_entity_cur;
    fetch l_entity_cur 
      into l_result.id, 
           l_result.scheme_id,
           l_result.owner,
           l_result.name,
           l_result.object_name,
           l_result.collect_name,
           l_result.table_name,
           l_result.view_name,
           l_result.sequence_name,
           l_result.pk_field,
           l_result.pk_type;
    --
    if l_entity_cur%notfound = true then
      close l_entity_cur;
      fix_exception('get_entity_info: entity '||p_entity_name||', scheme_id = '||p_scheme_id||' not found.');
      raise apps.fnd_api.g_exc_error;
    end if;
    --
    close l_entity_cur;
    --
    return l_result;
  exception 
    when others then
      fix_exception('get_entity_info finished with error. ');
      raise;
  end;*/
  /*--
  -- Функция возвращает описание сущности
  --
  function get_entity_info(p_entity_id number) return g_entity_typ is
    cursor l_entity_cur is
      select s.id scheme_id, e.name entity_name
      from   xxdoo_db_entities_t e,
             xxdoo_db_schemes_t  s
      where  1=1
      and    s.id = e.scheme_id
      and    e.id = p_entity_id;
    l_entity l_entity_cur%rowtype;
  begin
    open l_entity_cur;
    fetch l_entity_cur into l_entity;
    if l_entity_cur%notfound = true then
      close l_entity_cur;
      fix_exception('get_entity_info: p_entity_id '||p_entity_id||' not found.');
      raise no_data_found;
    end if;
    close l_entity_cur;
    --
    return get_entity_info(l_entity.scheme_id, l_entity.entity_name);
  exception 
    when others then
      fix_exception('get_entity_info(p_entity_id='||p_entity_id||') finished with error. ');
      raise;
  end;
  --
  function get_entity_info(p_owner varchar2, p_object_name varchar2) return xxdoo_db_entities_info_v%rowtype is
    --
    cursor l_entity_cur(p_owner varchar2, p_object_name varchar2) is
        select e.*
        from   xxdoo_db_entities_info_v e
        where  1=1
        and    e.object_name = p_object_name
        and    e.owner = p_owner
        union all
        select e.*
        from   xxdoo_db_entities_info_v e
        where  1=1
        and    e.collect_name = p_object_name
        and    e.owner = p_owner;
    --
    l_result xxdoo_db_entities_info_v%rowtype;
    --
  begin
    --
    open l_entity_cur(p_owner,p_object_name);
    fetch l_entity_cur into l_result;
    --
    if l_entity_cur%notfound = true then
      close l_entity_cur;
      fix_exception('get_entity_info: object '||p_owner||'.'||p_object_name||' not found.');
      raise apps.fnd_api.g_exc_error;
    end if;
    --
    close l_entity_cur;
    --
    return l_result;
  exception 
    when others then
      fix_exception('get_entity_info(p_object='||p_owner||'.'||p_object_name||') finished with error. ');
      raise;
  end;*/
  --
end xxdoo_db_utils_pkg;
/
