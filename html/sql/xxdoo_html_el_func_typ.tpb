create or replace type body xxdoo_html_el_func_typ is
  
  -- Member procedures and functions
  constructor function xxdoo_html_el_func_typ return self as result is
  begin
    self.set_id;
    return;
  end;
  --
  constructor function xxdoo_html_el_func_typ(p_func_xml   xmltype) return self as result is
    l_dummy varchar2(32000) := p_func_xml.getStringVal;
    cursor l_fn_cur(p_func_xml xmltype) is
      select extractvalue(p_func_xml,'/F/N') fname,
             extract(p_func_xml,'/F/AS') arguments
      from   dual;
    l_args xmltype;
  begin
    self.set_id;
    open l_fn_cur(p_func_xml);
    fetch l_fn_cur
      into  self.name,
            l_args;
    close l_fn_cur;
    --
    
    --
    self.arguments   := xxdoo_html_el_func_args_typ();
    if l_args is not null then
    --  l_dummy := l_args.getStringVal;
      self.add_argument(l_args);
    end if;
    return;
  end;
  --
  member procedure add_argument(p_arguments xmltype) is
    cursor l_args_cur(p_arguments xmltype) is
      select a.arg,a.argfn
      from   xmltable('/AS/A' passing(p_arguments)
               columns 
                 arg   varchar2(200) path '/',  --атомарное значение
                 argfn xmltype       path '/A/F') a; --вложенная функция
    l_dummy varchar2(32000) := p_arguments.getStringVal;
  begin
    for a in l_args_cur(p_arguments) loop
      self.arguments.extend;
      if a.argfn is not null then
        self.arguments(self.arguments.count) := xxdoo_html_el_func_arg_typ(xxdoo_html_el_func_typ(a.argfn));
      elsif a.arg is not null then
        self.arguments(self.arguments.count) := xxdoo_html_el_func_arg_typ(a.arg);
      else
        self.arguments(self.arguments.count) := xxdoo_html_el_func_arg_typ;
      end if;
    end loop;
  end;
  --
  member procedure callbacks(self  in out nocopy xxdoo_html_el_func_typ, 
                             p_ctx in out xxdoo_html_el_context_typ) is
  begin
    self.arguments(1).value := '"'||p_ctx.source.add_callback(self.arguments(1).path)||'"';
  end;
  --
  member procedure each(self  in out nocopy xxdoo_html_el_func_typ, 
                        p_ctx in out xxdoo_html_el_context_typ) is
    l_arg xxdoo_html_el_func_arg_typ;-- := self.arguments(1);
    l_clc_name varchar2(200);
    l_ctx_name varchar2(200);
    l_member_info xxdoo_html_el_member_info_typ;
  begin
    if self.arguments.exists(1) then
      l_arg := self.arguments(1);
      l_member_info := l_arg.member_info;
    else
      l_member_info := xxdoo_html_el_member_info_typ(p_ctx.source.object_owner,p_ctx.source.object_name,'');
    end if;
    if l_member_info.data_type_code = 'COLLECTION' then
      l_clc_name := 'id'||xxdoo_html_utils_pkg.get_session_sequence;
      l_ctx_name := p_ctx.ctx_name ||
                    case
                      when l_arg is not null then
                        '.' || l_arg.path
                    end;
      self.command_start := 'for ' || l_clc_name || ' in 1..' || l_ctx_name || '.count loop';
      l_ctx_name := l_ctx_name || '(' || l_clc_name || ')';
      l_member_info := xxdoo_html_utils_pkg.get_collection_info(l_member_info);
    else
      xxdoo_html_utils_pkg.fix_exception('prepare.each source '||l_member_info.data_type||' must be collection.');
      raise apps.fnd_api.g_exc_error;
    end if;
    --
    p_ctx := xxdoo_html_el_context_typ(l_ctx_name,
                                      xxdoo_html_ap_source_typ(
                                        null,
                                        l_member_info.data_type_owner,
                                        l_member_info.data_type,
                                        p_ctx.source.id,
                                        case
                                          when l_arg is not null then
                                            l_arg.path
                                        end
                                      )
                                     );
    self.command_end := 'end loop;';
    self.is_inc_indent := 'Y';
    --
  end;
  --
  member procedure region(self  in out nocopy xxdoo_html_el_func_typ, 
                          p_ctx in out nocopy xxdoo_html_el_context_typ) is
    l_method_name varchar2(30) := 'get_' || self.arguments(1).path ||'_'|| xxdoo_html_utils_pkg.get_session_sequence;
    l_html   varchar2(20) := xxdoo_html_utils_pkg.g_fn_html_clob_name;
    m number;
  begin
    self.command_start := chr(1) || l_method_name||'('||p_ctx.ctx_name||')';
    p_ctx.methods.extend;
    m := p_ctx.methods.count;
    p_ctx.methods(m) := xxdoo_html_ap_pkg_mthd_typ(
                                          p_array_id  => m,
                                          p_type      => 'f'     ,
                                          p_name      => l_method_name     ,
                                          p_in_params => xxdoo_html_ap_pkg_m_pars_typ(
                                                           xxdoo_html_ap_pkg_m_par_typ(
                                                             'p_ctx',
                                                             null,
                                                             p_ctx.source.object_owner||'.'||p_ctx.source.object_name
                                                           )
                                                         ),
                                          p_out_type  => 'clob',
                                          p_is_public => 'N'
                                        );
    --
    p_ctx.methods(m).indent_inc;
    p_ctx.methods(m).add_line(l_html ||' clob;');
    p_ctx.methods(m).indent_dec;
    p_ctx.methods(m).add_line('begin');
    p_ctx.methods(m).indent_inc;
    p_ctx.methods(m).add_line('dbms_lob.createtemporary('||l_html||',true);');
    p_ctx.ctx_name := 'p_ctx';
    self.method_id := p_ctx.methods(m).id;
    --
    p_ctx.region := xxdoo_html_ap_region_typ(self.arguments(1).path,self.method_id);
    --
  end;
  --
  overriding member function prepare(self in out nocopy xxdoo_html_el_func_typ, p_ctx xxdoo_html_el_context_typ) return xxdoo_html_el_context_typ is
    l_ctx xxdoo_html_el_context_typ := p_ctx;
  begin
    for a in 1..self.arguments.count loop
      self.arguments(a).prepare(l_ctx);
    end loop;
    --
    if self.name = 'each' then
      each(l_ctx);
    elsif self.name = 'callbacks' then
      callbacks(l_ctx);
    elsif self.name = 'region' then
      region(l_ctx);
    end if;
    --
    return l_ctx;
  end;
  --
  --overriding member function prepare(p_ctx xxdoo_html_el_context_typ) return xxdoo_html_el_context_typ
  --
  overriding member function as_string return varchar2 is
    l_result varchar2(32000);
  begin
    if self.command_start is not null then
      return chr(0) || self.command_start;
    else
      for a in 1..self.arguments.count loop
        l_result := case
                      when l_result is not null then
                        ','
                    end || self.arguments(a).as_string;
      end loop;
    end if;
    if self.fn_name is not null then
      l_result := self.fn_name || 
                    case
                      when l_result is not null then
                        '(' || l_result || ')'
                    end;
    end if;
    --
    return l_result;
  end;
  --
  overriding member function as_string_end return varchar2 is
  begin
    return chr(0) || self.command_end;
  end;
  --
  overriding member function get_attribute_value(p_name varchar2) return varchar2 is 
  begin
    return null;
  end;
  --
end;
/
