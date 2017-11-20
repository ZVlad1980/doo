declare
  --
  g_owner varchar2(30) := 'xxdoo';
  procedure plog(p_msg in varchar2, p_eof in boolean default false) is
  begin
    if p_eof = true then
      dbms_output.put_line(p_msg);
    else
      dbms_output.put(p_msg);
    end if;
  end;
  --
  procedure create_obj(p_type  in varchar2,
                       p_name  in varchar2,
                       p_body  in varchar2,
                       p_owner  in varchar2 default g_owner) is
    l_obj_exist_exc exception;
    l_obj_exist2_exc exception;
    pragma exception_init(l_obj_exist_exc, -955);
    pragma exception_init(l_obj_exist2_exc, -2303);
    --
  begin
    plog('Create '||p_type||' '||p_name||'...');
    execute immediate 'create '||p_type||' '||p_owner||'.'||p_name||' '||p_body;
    execute immediate 'grant execute, debug on '||p_owner||'.'||p_name||' to apps with grant option';
    plog('Ok',true);
  exception
    when l_obj_exist_exc or l_obj_exist2_exc then
      plog('exist',true);
      execute immediate 'grant execute, debug on '||p_owner||'.'||p_name||' to apps with grant option';
    when others then
      plog('error: '||sqlerrm, true);
      raise;
  end;
  --
  procedure alter_obj(p_type  in varchar2,
                      p_name  in varchar2,
                      p_body  in varchar2,
                      p_owner  in varchar2 default g_owner) is
    l_element_exists_exc exception;
    pragma exception_init(l_element_exists_exc, -1442);
    l_element_exists2_exc exception; --дубирование элементов в типе
    pragma exception_init(l_element_exists2_exc, -22324);
  begin
    plog('Alter '||p_type||' '||p_name||'...');
    execute immediate 'alter '||p_type||' '||p_owner||'.'||p_name||' '||p_body;
    plog('Ok',true);
  exception
    when l_element_exists_exc or l_element_exists2_exc then
      plog('exist',true);
    when others then
      plog('error'||sqlerrm,true); --plog('error: '||sqlerrm, true);
      raise;
  end;
  --
begin
  --return;
  dbms_output.enable(100000);
  --тип для описания члена типа
  create_obj(p_type  => 'type',
             p_name  => 'xxdoo_html_el_member_info_typ',
             p_body  => ' as object (
                            name             varchar2(30),
                            data_type        varchar2(110),
                            data_type_owner  varchar2(90),
                            data_type_code   varchar2(30),
                            lenght           number,
                            constructor function xxdoo_html_el_member_info_typ return self as result,
                            constructor function xxdoo_html_el_member_info_typ(p_owner       varchar2, 
                                                                              p_object_name varchar2, 
                                                                              p_member_name varchar2 default null) return self as result
                          )');
  -- тип контекста (не хранимый)
  create_obj(p_type  => 'type',
             p_name  => 'xxdoo_html_el_context_typ',
             p_body  => ' as object (
                            id       number,
                            ctx_name varchar2(100),
                            source   xxdoo_html_ap_source_typ,
                            methods  xxdoo_html_ap_pkg_mthds_typ,
                            region   xxdoo_html_ap_region_typ,
                            constructor function xxdoo_html_el_context_typ(p_name   varchar2, 
                                                                          p_source xxdoo_html_ap_source_typ) return self as result
                          )');
  --базовый тип элемента
  create_obj(p_type  => 'type',
             p_name  => 'xxdoo_html_element_typ',
             p_body  => ' as object (
                            id            number,
                            parent_id     number,
                            array_id      number,
                            method_id     number,
                            is_inc_indent varchar2(1),
                            command_start varchar2(32000),
                            command_end   varchar2(32000),
                            member function get_source_id return number,
                            member procedure set_id,
                            not instantiable member function as_string return varchar2,
                            not instantiable member function as_string_end return varchar2,
                            not instantiable member function prepare(self in out nocopy xxdoo_html_element_typ, p_ctx xxdoo_html_el_context_typ) return xxdoo_html_el_context_typ,
                            not instantiable member function get_attribute_value(p_name varchar2) return varchar2
                          )
                          not final
                          not instantiable');
  
  --аргументы функций
  create_obj(p_type  => 'type',
             p_name  => 'xxdoo_html_el_func_arg_typ',
             p_body  => ' as object (
                            value       varchar2(2000),
                            type        varchar2(30),
                            path        varchar2(2000),
                            member_info xxdoo_html_el_member_info_typ,
                            col_info    xxdoo_html_el_member_info_typ,
                            in_out      varchar2(2),
                            function    xxdoo_html_element_typ,
                            constructor function xxdoo_html_el_func_arg_typ return self as result,
                            constructor function xxdoo_html_el_func_arg_typ(p_value varchar2) return self as result,
                            constructor function xxdoo_html_el_func_arg_typ(p_function xxdoo_html_element_typ) return self as result,
                            member function as_string return varchar2,
                            member procedure prepare(self in out nocopy xxdoo_html_el_func_arg_typ, p_ctx in out nocopy xxdoo_html_el_context_typ)
                          )');
  --Коллекция для хранения аргументов функций 
  create_obj(p_type  => 'type',
             p_name  => 'xxdoo_html_el_func_args_typ',
             p_body  => ' as table of xxdoo_html_el_func_arg_typ');
  --функции
  create_obj(p_type  => 'type',
             p_name  => 'xxdoo_html_el_func_typ',
             p_body  => ' under xxdoo_html_element_typ(
                            name          varchar2(200),
                            fn_name       varchar2(30),
                            arguments     xxdoo_html_el_func_args_typ,
                            constructor function xxdoo_html_el_func_typ return self as result,
                            constructor function xxdoo_html_el_func_typ(p_func_xml   xmltype) return self as result,
                            member procedure add_argument(p_arguments xmltype),
                            overriding member function as_string return varchar2,
                            overriding member function as_string_end return varchar2,
                            overriding member function prepare(self in out nocopy xxdoo_html_el_func_typ, p_ctx xxdoo_html_el_context_typ) return xxdoo_html_el_context_typ,
                            member procedure each(self   in out nocopy  xxdoo_html_el_func_typ, p_ctx in out nocopy xxdoo_html_el_context_typ),
                            member procedure region(self  in out nocopy xxdoo_html_el_func_typ, 
                                                    p_ctx in out xxdoo_html_el_context_typ),
                            member procedure callbacks(self  in out nocopy xxdoo_html_el_func_typ, 
                                                       p_ctx in out xxdoo_html_el_context_typ),
                            overriding member function get_attribute_value(p_name varchar2) return varchar2
                          )
                          not final');
  /*--
  alter_obj(p_type  => 'type',
            p_name  => 'xxdoo_html_el_func_typ',
            p_body  => 'add member procedure region(self  in out nocopy xxdoo_html_el_func_typ, 
                                                    p_ctx in out xxdoo_html_el_context_typ) cascade including table data');*/

  --тип для хранения значения
  create_obj(p_type  => 'type',
             p_name  => 'xxdoo_html_el_value_typ',
             p_body  => ' as object (
                            type      varchar2(10),
                            value     varchar2(32767),
                            function  xxdoo_html_el_func_typ,
                            constructor function xxdoo_html_el_value_typ return self as result,
                            constructor function xxdoo_html_el_value_typ(p_value varchar2,
                                                                        p_type  varchar2 default ''A'') return self as result,
                            member procedure add_value(p_value varchar2),
                            member function as_string return varchar2,
                            member procedure prepare(self in out nocopy xxdoo_html_el_value_typ, p_ctx in out nocopy xxdoo_html_el_context_typ)
                          )');
  /*create_obj(p_type  => 'type',
             p_name  => 'xxdoo_html_el_values_typ',
             p_body  => ' as table of xxdoo_html_el_value_typ');*/
  --Контент тега
  create_obj(p_type  => 'type',
             p_name  => 'xxdoo_html_el_cont_typ',
             p_body  => ' under xxdoo_html_element_typ(
                            value xxdoo_html_el_value_typ,
                            constructor function xxdoo_html_el_cont_typ return self as result,
                            constructor function xxdoo_html_el_cont_typ(p_content varchar2) return self as result,
                            overriding member function as_string return varchar2,
                            overriding member function as_string_end return varchar2,
                            overriding member function prepare(self in out nocopy xxdoo_html_el_cont_typ, p_ctx xxdoo_html_el_context_typ) return xxdoo_html_el_context_typ,
                            overriding member function get_attribute_value(p_name varchar2) return varchar2
                          )');
  --аттрибуты
  create_obj(p_type  => 'type',
             p_name  => 'xxdoo_html_el_attr_typ',
             p_body  => ' as object (
                            name  varchar2(200),
                            value xxdoo_html_el_value_typ,
                            constructor function xxdoo_html_el_attr_typ return self as result,
                            constructor function xxdoo_html_el_attr_typ(p_name varchar2,p_value varchar2) return self as result,
                            constructor function xxdoo_html_el_attr_typ(p_name varchar2,p_value xxdoo_html_el_value_typ) return self as result,
                            member procedure add_value(p_value varchar2),
                            member function as_string return varchar2,
                            member procedure prepare(self in out nocopy xxdoo_html_el_attr_typ, p_ctx in out nocopy xxdoo_html_el_context_typ)
                          ) not final');
  --Коллекция для хранения аттрибутов 
  create_obj(p_type  => 'type',
             p_name  => 'xxdoo_html_el_attrs_typ',
             p_body  => ' as table of xxdoo_html_el_attr_typ');
  --Тип со списком атрибутов
  create_obj(p_type  => 'type',
             p_name  => 'xxdoo_html_el_tag_attrs_typ',
             p_body  => ' as object (
                            attrs xxdoo_html_el_attrs_typ,
                            constructor function xxdoo_html_el_tag_attrs_typ return self as result,
                            constructor function xxdoo_html_el_tag_attrs_typ(p_name varchar2, p_value varchar2) return self as result,
                            member procedure attr(p_name varchar2, p_value varchar2),
                            member function attr(p_name varchar2, p_value varchar2) return xxdoo_html_el_tag_attrs_typ,
                            member function get_id(p_name varchar2) return number,
                            member function as_string return varchar2,
                            member procedure prepare(self in out nocopy xxdoo_html_el_tag_attrs_typ, p_ctx in out nocopy xxdoo_html_el_context_typ),
                            member function get_attribute_value(p_name varchar2) return varchar2
                          ) not final');
  --Теги
  create_obj(p_type  => 'type',
             p_name  => 'xxdoo_html_el_tag_typ',
             p_body  => ' under xxdoo_html_element_typ(
                            tag            varchar2(2000),
                            attributes     xxdoo_html_el_tag_attrs_typ,
                            content        xxdoo_html_el_cont_typ,
                            constructor function xxdoo_html_el_tag_typ return self as result,
                            constructor function xxdoo_html_el_tag_typ(p_array_id  number,
                                                                      p_tag       varchar2,
                                                                      p_attrs     xxdoo_html_el_tag_attrs_typ,
                                                                      p_content   varchar2) return self as result,
                            constructor function xxdoo_html_el_tag_typ(p_object xxdoo_html_el_tag_typ) return self as result,
                            overriding member function as_string return varchar2,
                            overriding member function as_string_end return varchar2,
                            overriding member function prepare(self in out nocopy xxdoo_html_el_tag_typ, p_ctx xxdoo_html_el_context_typ) return xxdoo_html_el_context_typ,
                            overriding member function get_attribute_value(p_name varchar2) return varchar2
                          )');
  --Коллекция для хранения элементов 
  create_obj(p_type  => 'type',
             p_name  => 'xxdoo_html_elements_typ',
             p_body  => ' as table of xxdoo_html_element_typ');
exception
  when others then
    plog('Crashed creation objects');
end;
/
