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
    if p_type like '%TYPE%' then
      execute immediate 'grant execute,debug on '||p_owner||'.'||p_name||' to apps with grant option';
    end if;
    plog('Ok',true);
  exception
    when l_obj_exist_exc or l_obj_exist2_exc then
      plog('exist',true);
      execute immediate 'grant execute,debug on '||p_owner||'.'||p_name||' to apps with grant option';
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
  --Обработчики
  create_obj(p_type  => 'type',
             p_name  => 'xxdoo_html_ap_callback_typ',
             p_body  => ' as object (
                            id   number,
                            name varchar2(30), 
                            --  
                            constructor function xxdoo_html_ap_callback_typ
                              return self as result,
                            constructor function xxdoo_html_ap_callback_typ(p_name varchar2)
                              return self as result
                          )');
  --Коллекция для хранения обработчиков 
  create_obj(p_type  => 'type',
             p_name  => 'xxdoo_html_ap_callbacks_typ',
             p_body  => ' as table of xxdoo_html_ap_callback_typ');
  
  --параметры методов
  create_obj(p_type  => 'type',
             p_name  => 'xxdoo_html_ap_pkg_m_par_typ',
             p_body  => ' as object (
                            name varchar2(15),
                            mod  varchar2(15),
                            type varchar2(100)
                          )');
  --Коллекция параметров
  create_obj(p_type  => 'type',
             p_name  => 'xxdoo_html_ap_pkg_m_pars_typ',
             p_body  => ' as table of xxdoo_html_ap_pkg_m_par_typ');
  --Методы
  create_obj(p_type  => 'type',
             p_name  => 'xxdoo_html_ap_pkg_mthd_typ',
             p_body  => ' as object (
                            id number,
                            array_id number,
                            type varchar2(15),
                            name varchar2(30),
                            in_params xxdoo_html_ap_pkg_m_pars_typ,
                            out_type varchar2(150),
                            body clob,
                            is_public varchar2(1),
                            indent number,
                            constructor function xxdoo_html_ap_pkg_mthd_typ return self as result,
                            constructor function xxdoo_html_ap_pkg_mthd_typ(p_array_id number,
                                                                           p_type varchar2,
                                                                           p_name varchar2,
                                                                           p_in_params xxdoo_html_ap_pkg_m_pars_typ default null,
                                                                           p_out_type varchar2 default null,
                                                                           p_body clob default null,
                                                                           p_is_public varchar2 default ''N'') return self as result,
                            member procedure add_params(p_name varchar2, p_mod varchar2, p_type varchar2),
                            member procedure add_line(p_line varchar2,
                                                      p_new  boolean default true,
                                                      p_eof  boolean default true),
                            member function get_method_spc return varchar2,
                            member function get_method return clob,
                            member procedure indent_inc,
                            member procedure indent_dec
                          )');
  /*alter_obj(p_type  => 'type',
            p_name  => 'xxdoo_html_ap_pkg_mthd_typ',
            p_body  => 'modify attribute name varchar2(30) cascade including table data');*/
  --Коллекция методов
  create_obj(p_type  => 'type',
             p_name  => 'xxdoo_html_ap_pkg_mthds_typ',
             p_body  => ' as table of xxdoo_html_ap_pkg_mthd_typ');
  --Пакет
  create_obj(p_type  => 'type',
             p_name  => 'xxdoo_html_ap_pkg_typ',
             p_body  => ' as object (
                            owner varchar2(30),
                            name  varchar2(30),
                            methods xxdoo_html_ap_pkg_mthds_typ,
                            specification   clob,
                            body            clob,
                            method_html     varchar2(30),
                            method_service  varchar2(30),
                            method_json     varchar2(30),
                            status          varchar2(20),
                            constructor function xxdoo_html_ap_pkg_typ return self as result,
                            constructor function xxdoo_html_ap_pkg_typ(p_owner      varchar2,
                                                                      p_name       varchar2) return self as result,
                            member procedure add_methods(p_methods xxdoo_html_ap_pkg_mthds_typ),
                            member function add_method(self in out nocopy xxdoo_html_ap_pkg_typ,
                                                       p_type      varchar2,
                                                       p_name      varchar2,
                                                       p_in_params xxdoo_html_ap_pkg_m_pars_typ default null,
                                                       p_out_type  varchar2 default null,
                                                       p_is_public varchar2 default ''N'',
                                                       p_body      clob default null) return number,
                            member procedure generate(p_mode varchar2 default ''SPC''),
                            member procedure compile,
                            member function get_method_array_id(p_id number) return number,
                            member procedure set_status(p_status varchar2),
                            member function  get_status return varchar2
                          )');
  alter_obj(p_type => 'type',
            p_name => 'xxdoo_html_ap_pkg_typ',
            p_body => 'add member function get_method(p_name varchar2) return xxdoo_html_ap_pkg_mthd_typ cascade including table data');
  --описание сервиса
  create_obj(p_type  => 'type',
             p_name  => 'xxdoo_html_ap_service_typ',
             p_body  => ' as object (
                            name       varchar2(15),
                            url        varchar2(400),
                            params     xxdoo_html_ap_pkg_m_pars_typ,
                            constructor function xxdoo_html_ap_service_typ return self as result,
                            constructor function xxdoo_html_ap_service_typ(p_name   varchar2,
                                                                          p_params xxdoo_html_ap_pkg_m_pars_typ default null) return self as result,
                            member procedure registration(p_pkg_owner varchar2,
                                                          p_pkg_name varchar2,
                                                          p_method_name varchar2),
                            member function get_url return varchar2
                          )');      
  --Источники
  create_obj(p_type  => 'type',
             p_name  => 'xxdoo_html_ap_source_typ',
             p_body  => ' as object (
                            id             number,
                            name           varchar2(30),
                            object_owner   varchar2(30),
                            object_name    varchar2(30),
                            object_type    varchar2(30),
                            parent_src_id  number,
                            parent_field   varchar2(30),
                            id_name        varchar2(20),
                            ctx_name       varchar2(200),
                            exists_getter  varchar2(1),
                            exists_id      varchar2(1),
                            callbacks      xxdoo_html_ap_callbacks_typ,
                            constructor function xxdoo_html_ap_source_typ return self as result,
                            constructor function xxdoo_html_ap_source_typ(p_name           varchar2, 
                                                                         p_object_owner   varchar2,
                                                                         p_object_name    varchar2,
                                                                         p_parent_src_id  number   default null,
                                                                         p_parent_field   varchar2 default null) return self as result,
                            member function add_callback(self in out nocopy xxdoo_html_ap_source_typ,
                                                         p_callback_name    varchar2) return number,
                            member procedure get_block_callbacks(p_method in out nocopy xxdoo_html_ap_pkg_mthd_typ,
                                                                 p_var_name varchar2,
                                                                 p_data_var_name varchar2)
                          )');
  --Коллекция для хранения источников 
  create_obj(p_type  => 'type',
             p_name  => 'xxdoo_html_ap_sources_typ',
             p_body  => ' as table of xxdoo_html_ap_source_typ');
  --регионы xxdoo_html_ap_region_typ
  create_obj(p_type  => 'type',
             p_name  => 'xxdoo_html_ap_region_typ',
             p_body  => ' as object (
                            name        varchar2(30),
                            function_id number,
                            constructor function xxdoo_html_ap_region_typ return self as result
                          )');
  --Коллекция для хранения источников 
  create_obj(p_type  => 'type',
             p_name  => 'xxdoo_html_ap_regions_typ',
             p_body  => ' as table of xxdoo_html_ap_region_typ');
  --Приложение
  create_obj(p_type  => 'type',
             p_name  => 'xxdoo_html_ap_appl_typ',
             p_body  => ' as object (
                            id           number,
                            name         varchar2(30),
                            code         varchar2(30),
                            service      xxdoo_html_ap_service_typ,
                            package      xxdoo_html_ap_pkg_typ,
                            sources      xxdoo_html_ap_sources_typ,
                            regions      xxdoo_html_ap_regions_typ,
                            api_version  varchar2(20),
                            constructor function xxdoo_html_ap_appl_typ return self as result,
                            constructor function xxdoo_html_ap_appl_typ(p_name         varchar2) return self as result,
                            constructor function xxdoo_html_ap_appl_typ(p_name         varchar2, 
                                                                       p_code         varchar2,
                                                                       p_source       xxdoo_html_ap_source_typ) return self as result,
                            member procedure save,
                            member procedure unregistration,
                            member function add_source(self            in out xxdoo_html_ap_appl_typ,
                                                       p_src_name      varchar2,
                                                       p_object_owner  varchar2,
                                                       p_object_name   varchar2,
                                                       p_parent_src_id number,
                                                       p_parent_field  varchar2
                                                      ) return number,
                            member procedure add_region(p_region xxdoo_html_ap_region_typ),
                            member procedure save_source(p_source in out nocopy xxdoo_html_ap_source_typ),
                            member procedure generate
                          )');
  --
  create_obj(p_type  => 'table',
             p_name  => 'xxdoo_html_ap_appls_t',
             p_body  => ' of xxdoo_html_ap_appl_typ
                          nested table sources store as xxdoo_html_ap_sources_t(
                            nested table callbacks store as xxdoo_html_ap_callbacks_t
                          ),
                          nested table package.methods store as xxdoo_html_ap_pkg_mthds_t(
                            nested table in_params store as xxdoo_html_ap_m_pars_t
                          ),
                          nested table service.params store as xxdoo_html_ap_srv_pars_t,
                          nested table regions store as xxdoo_html_ap_regions_t');
  --
  create_obj(p_type  => 'unique index',
             p_name  => 'xxdoo_html_ap_appls_u1',
             p_body  => ' on xxdoo_html_ap_appls_t(id)');
  --
  create_obj(p_type  => 'unique index',
             p_name  => 'xxdoo_html_ap_appls_u2',
             p_body  => ' on xxdoo_html_ap_appls_t(name)');
  --
  create_obj(p_type  => 'unique index',
             p_name  => 'xxdoo_html_ap_sources_t',
             p_body  => ' on xxdoo_html_ap_sources_t(id)');
  --
exception
  when others then
    plog('Crashed creation objects '||sqlerrm);
end;
/
