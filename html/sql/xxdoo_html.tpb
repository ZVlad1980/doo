create or replace type body xxdoo_html is
  
  --Constructors
  constructor function xxdoo_html return self as result is
  begin
    self.elements := xxdoo_html_elements_typ();
    --
    self.id       := xxdoo_html_utils_pkg.get_session_sequence;
    self.application := xxdoo_html_ap_appl_typ;
    return;
  end;
  --
  constructor function xxdoo_html(p_appl_name    varchar2,
                                  p_src_owner    varchar2,
                                  p_src_object   varchar2,
                                  p_appl_code    varchar2 default null) return self as result is
    
    l_source xxdoo_html_ap_source_typ;
  begin
    self.elements := xxdoo_html_elements_typ();
    --
    if p_src_object is not null then
      l_source := xxdoo_html_ap_source_typ(p_name         => 'p_ctx',
                                           p_object_owner => p_src_owner,
                                           p_object_name  => p_src_object);
    end if;
    self.application := xxdoo_html_ap_appl_typ(p_name  => p_appl_name, 
                                               p_code   => p_appl_code,
                                               p_source => l_source);
    --
    self.id := xxdoo_html_utils_pkg.get_session_sequence;
    --
    return;
  end;
  --
  constructor function xxdoo_html(p_src_owner    varchar2,
                                  p_src_object   varchar2) return self as result is
  begin
    --
    self := xxdoo_html;
    self.init_source(p_src_owner, p_src_object);
    --
    return;
  end;
  --
  constructor function xxdoo_html(p_html_object xxdoo_html,
                                  p_src_owner    varchar2,
                                  p_src_object   varchar2) return self as result is
  begin
    self := p_html_object;
    --
    self.init_source(p_src_owner, p_src_object);
    --
    return;
  end;
  --
  --
  --
  member procedure init_source(p_src_owner    varchar2,
                               p_src_object   varchar2) is
    l_source xxdoo_html_ap_source_typ;
  begin
    if p_src_object is not null then
      l_source := xxdoo_html_ap_source_typ(p_name         => 'p_ctx',
                                           p_object_owner => p_src_owner,
                                           p_object_name  => p_src_object);
    end if;
    self.application := xxdoo_html_ap_appl_typ(p_name  => 'others', 
                                               p_code   => 'others',
                                               p_source => l_source);
  end init_source;
  --
  --
  --
  member procedure init is
  begin
    self := xxdoo_html;
  end;
  --
  member function append(self     in out xxdoo_html,
                         p_object in xxdoo_html_element_typ) return number is
  begin
    self.elements.extend;
    --
    self.elements(self.elements.count) := p_object;
    self.elements(self.elements.count).array_id := self.elements.count;
    --
    return self.elements(self.elements.count).id;
  end; 
  --
  member function append(self in out xxdoo_html,
                         p_tag       varchar2, 
                         p_attrs     xxdoo_html_el_tag_attrs_typ default null,  
                         p_content   varchar2                   default null) return number is
  begin
    return append(xxdoo_html_el_tag_typ(p_array_id => self.elements.count,
                                       p_tag      => p_tag,
                                       p_attrs    => p_attrs,
                                       p_content  => p_content));
  end;
  -- Добавляет содержимое p_object в текущий экземпляр объекта
  member procedure merge_new(p_object xxdoo_html)  is
    l_dummy  number;
    l_source xxdoo_html_element_typ;
  begin
    --
    for id in 1..p_object.elements.count loop
      l_source := p_object.elements(id);
      l_dummy  := self.append(p_object => l_source);
    end loop;
    --
  end;
  --Добавляет различия между объектами в текущий экземпляр объекта
  member procedure merge_different(p_object xxdoo_html)  is
    l_dummy  number;
    l_source xxdoo_html_element_typ;
    --
    cursor l_diff_rows(p_object1 xxdoo_html,
                       p_object2 xxdoo_html) is
      select s.array_id, s.id
      from   table(p_object1.elements) s
      minus
      select s.array_id, s.id
      from   table(p_object2.elements) s;
    --
  begin
    --
    for d in l_diff_rows(p_object,self) loop
      l_source := p_object.elements(d.array_id);
      l_dummy  := self.append(p_object => l_source);
    end loop;
    --
  end;
  --
  member function merge(self in out xxdoo_html, p_object in out xxdoo_html) return xxdoo_html is
    --
  begin
    --
    if p_object.id <> self.id then --если новый объект
      p_object.merge_new(self);
      self := p_object;
    elsif self.is_equal_object(p_object) = 'N' then --если другая копия того же объекта
      self.merge_different(p_object);
    end if;
    --
    return self;
    --
  end;
  --функция определяет эквивалентность строк в текущем и заданном объекте
  member function is_equal_object(p_object xxdoo_html) return varchar2 is
    l_result varchar2(1) := 'N';
    l_dummy  number;
  begin
    select count(*)
    into   l_dummy
    from  (select s.array_id, s.id
           from   table(p_object.elements) s
           minus
           select s.array_id, s.id
           from   table(self.elements) s);
    --
    if nvl(l_dummy,0) = 0 then
      l_result := 'Y';
    end if;
    return l_result;
  end;
  --Member procedures and functions
  --H1
  member function h(p_tag         varchar2, 
                    p_attrs       xxdoo_html_el_tag_attrs_typ, 
                    p_content     varchar2 default null) return xxdoo_html is
    l_dummy         number;
    l_new_object xxdoo_html              := self;
    l_attrs xxdoo_html_el_tag_attrs_typ := p_attrs;   
  begin
    l_dummy := l_new_object.append(p_tag => p_tag, p_attrs => l_attrs, p_content => p_content);
    return l_new_object;
  end;
  --H2
  member function h(p_tag         varchar2,
                    p_content       varchar2) return xxdoo_html is
  begin
    return self.h(p_tag => p_tag,
                  p_attrs => null,
                  p_content => p_content);
  end;
  --H3
  member function h(p_tag         varchar2) return xxdoo_html is
  begin
    return self.h(p_tag     => p_tag,
                  p_attrs   => null,
                  p_content   => null);
  end;
  --H4
  member function h(p_tag         varchar2, 
                    p_attrs       xxdoo_html_el_tag_attrs_typ, 
                    p_object      xxdoo_html) return xxdoo_html is
    p_id          number;
    l_self_object xxdoo_html := self;
    l_new_object  xxdoo_html := p_object;
    l_attrs       xxdoo_html_el_tag_attrs_typ := p_attrs;
  begin
    if p_tag is not null then
      p_id := l_new_object.append(p_tag => p_tag,p_attrs => l_attrs);
      l_new_object.set_parent(p_id);
    end if;
    --
    return l_new_object.merge(l_self_object).region(p_id);
  end;
  --H5
  member function h(p_tag         varchar2, 
                    p_object      xxdoo_html) return xxdoo_html is
  begin
    return self.h(p_tag   => p_tag,
                  p_attrs => null,
                  p_object => p_object);
  end;
  --H6
  member function h(p_object xxdoo_html ) return xxdoo_html  is
  begin
    return self.h(p_tag   => null,
                  p_attrs => null,
                  p_object => p_object);
  end;
  --
  member procedure set_parent(p_parent_id number) is 
    cursor l_child_cur(p_id number) is
      select s.array_id id
      from   table(self.elements) s
      where  s.parent_id is null
      and    s.id <> p_id
      order by s.id;
  begin
    --
    for c in l_child_cur(p_parent_id) loop
      self.elements(c.id).parent_id := p_parent_id;
    end loop;
  end;
  --
  
  member function attr(p_name varchar2, p_content varchar2) return xxdoo_html_el_tag_attrs_typ is
    attrs xxdoo_html_el_tag_attrs_typ;
  begin
    attrs := xxdoo_html_el_tag_attrs_typ(p_name,p_content);
    return attrs;
  end;
  --
  member function attrs(attrs         xxdoo_html_el_tag_attrs_typ default null, 
                        class         varchar2 default null, 
                        type          varchar2 default null, 
                        name          varchar2 default null, 
                        value         varchar2 default null, 
                        id            varchar2 default null, 
                        colspan       varchar2 default null, 
                        rowspan       varchar2 default null, 
                        href          varchar2 default null, 
                        title         varchar2 default null, 
                        data_behavior varchar2 default null,
                        rel           varchar2 default null,
                        http_equiv    varchar2 default null,
                        width         varchar2 default null,
                        content       varchar2 default null,
                        onclick       varchar2 default null,
                        charset       varchar2 default null,
                        data_book     varchar2 default null,
                        data_action   varchar2 default null) 
      return xxdoo_html_el_tag_attrs_typ is
    --
    l_attrs xxdoo_html_el_tag_attrs_typ := case
                                           when attrs is null then
                                             xxdoo_html_el_tag_attrs_typ()
                                           else
                                             attrs
                                         end;
    --
    procedure add_attr(p_name varchar2,p_content varchar2) is
      
    begin
      if p_content is null and p_name <> 'href' then
        return;
      end if;
      --
      l_attrs.attr(trim(p_name),p_content);
    end;
    --
  begin
    add_attr('class        ',class        );
    add_attr('type         ',type         );
    add_attr('name         ',name         );
    add_attr('value        ',value        );
    add_attr('id           ',id           );
    add_attr('colspan      ',colspan      );
    add_attr('rowspan      ',rowspan      );
    add_attr('href         ',href         );
    add_attr('title        ',title        );
    add_attr('data-behavior',data_behavior);
    add_attr('rel          ',rel          );
    add_attr('http-equiv   ',http_equiv   );
    add_attr('width        ',width        );
    add_attr('content      ',content      );
    add_attr('onclick      ',onclick      );
    add_attr('charset      ',charset      );
    add_attr('data-book    ',data_book    );
    add_attr('data-action  ',data_action  );
    --
    return l_attrs;
  end;
  --
  member function text(p_content varchar2) return xxdoo_html is
    l_dummy number;
    l_new_object  xxdoo_html := self;
  begin
    l_dummy := l_new_object.append(xxdoo_html_el_cont_typ(p_content));
    return l_new_object;
  end;
  --
  member function g(p_value varchar2) return varchar2 is
  begin
    return xxdoo_html_utils_pkg.get_function_str(p_fn_name => 'getter', 
                                                p_fn_args => xxdoo_html_utils_pkg.g_fn_args(p_value));
  end;
  --
  member function callbacks(p_value varchar2) return varchar2 is
  begin
    return xxdoo_html_utils_pkg.get_function_str(p_fn_name => 'callbacks', 
                                                p_fn_args => xxdoo_html_utils_pkg.g_fn_args(p_value));
  end;
  --
  member function each(p_each_src varchar2, p_object xxdoo_html) return xxdoo_html is
    id number;
    l_self_object xxdoo_html := self;
    l_new_object  xxdoo_html := p_object;
  begin
    id := l_new_object.append(xxdoo_html_el_func_typ(xxdoo_html_utils_pkg.get_function_xml(p_fn_name => 'each', 
                                                                                           p_fn_args => case
                                                                                                          when p_each_src is not null then
                                                                                                            xxdoo_html_utils_pkg.g_fn_args(p_each_src)
                                                                                                          else
                                                                                                            xxdoo_html_utils_pkg.g_fn_args()
                                                                                                        end)));
    l_new_object.set_parent(id);
    --
    return l_new_object.merge(l_self_object);
  end;
  --
  member function each(p_object xxdoo_html) return xxdoo_html is
  begin
    return each('',p_object);
  end;
  --
  member function region(p_id number) return xxdoo_html is
    id number;
    l_result varchar2(32000);
    l_new_object  xxdoo_html := self;       
    cursor l_elements_cur is
      select value(e).get_attribute_value('id')
      from   table(self.elements)e
      where  e.id = p_id;
  begin
    if p_id is null then
      return l_new_object;
    end if;
    open l_elements_cur;
    fetch l_elements_cur
      into l_result;
    close l_elements_cur;
    if l_result = 'content' then
      id := l_new_object.append(xxdoo_html_el_func_typ(
                                  xxdoo_html_utils_pkg.get_function_xml(p_fn_name => 'region', 
                                                                       p_fn_args => xxdoo_html_utils_pkg.g_fn_args(
                                                                                      'content'
                                                                                    )
                                  )
                                )
                              );
      l_new_object.set_parent(id);
    end if;
    --
    return l_new_object;
  end;
  --
  member function as_string(p_parent_id number default null,
                            p_indent    number default 1) return varchar2 is
    l_string varchar2(32000);
    l_str_tmp varchar2(32000);
    --
    cursor l_elements_cur is
      select s.id,
             case
               when (select 1
                     from   table(self.elements) ch
                     where  rownum = 1
                     and    ch.parent_id = s.id) = 1 then
                 0
               else
                 1
             end  is_atom,
             value(s) element
      from   table(self.elements) s
      where  nvl(s.parent_id,-1) = nvl(p_parent_id,-1)
      order by s.id;
    --
    procedure add is
    begin
      --l_string := substr(l_string ||'i'|| p_indent||lpad( ' ',(p_indent-1)*2) || l_str_tmp || p_eol, 1, 32000);
      --l_string := substr(l_string  || p_parent_id || ' - '||lpad( ' ',(p_indent-1)*2) || l_str_tmp || chr(10), 1, 32000);
      l_string := substr(l_string  || lpad( ' ',(p_indent-1)*2) || l_str_tmp || chr(10), 1, 32000);
      l_str_tmp := null;
    end;
    --
    procedure adds(p_str varchar2) is
    begin
      l_string := substr(l_string  || p_str, 1, 32000);
    end;
    --
    procedure addt(p_str varchar2) is
    begin
      l_str_tmp := l_str_tmp || p_str;
    end;
    --
  begin
    for s in l_elements_cur loop
      --
      addt(s.element.as_string);
      --
      if s.is_atom = 0 then
        add;
        adds(self.as_string(s.id,p_indent+1));
      end if;
      --
      addt(s.element.as_string_end);
      add;
      --
    end loop;
    --
    return l_string;
  end;
  --
  member procedure prepare(p_parent_id number, 
                           p_ctx       xxdoo_html_el_context_typ) is
    l_ctx xxdoo_html_el_context_typ := nvl(p_ctx, 
                                          xxdoo_html_el_context_typ(
                                            p_name   => null, 
                                            p_source => case
                                                          when self.application.sources is not null then
                                                            case
                                                              when self.application.sources.exists(1) then
                                                                self.application.sources(1)
                                                            end
                                                        end
                                          )
                                      );
    --
    cursor l_elements_cur is
      select s.id,
             s.array_id array_id
      from   table(self.elements) s
      where  nvl(s.parent_id,-1) = nvl(p_parent_id,-1)
      order by s.id;
  begin
    for s in l_elements_cur loop
      l_ctx := self.elements(s.array_id).prepare(l_ctx);
      if l_ctx.methods.count > 0 then
        self.application.package.add_methods(l_ctx.methods);
        l_ctx.methods.delete;
      end if;
      if l_ctx.region is not null then
        self.application.add_region(l_ctx.region);
        l_ctx.region := null;
      end if;
      self.prepare(s.id,l_ctx);
      if l_ctx.source is not null then
        self.application.save_source(l_ctx.source);
      end if;
    end loop;
  end;
  --
  member procedure create_fn_html(p_method in out nocopy xxdoo_html_ap_pkg_mthd_typ,
                                  p_parent_id number default null) is
    l_str varchar2(32000);
    l_html varchar2(20) := xxdoo_html_utils_pkg.g_fn_html_clob_name;
    l_cmd  varchar2(40) := 'dbms_lob.append('||l_html||',';
    m      number;
    cursor l_elements_cur is
      select s.id,
             case
               when (select 1
                     from   table(self.elements) ch
                     where  rownum = 1
                     and    ch.parent_id = s.id) = 1 then
                 0
               else
                 1
             end  is_atom,
             value(s) element,
             nvl(s.is_inc_indent,'N') is_inc_indent,
             s.method_id
      from   table(self.elements) s
      where  nvl(s.parent_id,-1) = nvl(p_parent_id,-1)
      order by s.id;
    --
    procedure add_line is
    begin
      if l_str is null then
        return;
      end if;
      if substr(l_str,1,1) = chr(0) then
        if substr(l_str,2,1) = chr(1) then 
          l_str := l_cmd||substr(l_str,3)||');';
        else
          l_str := substr(l_str,2);
        end if;
      else
        l_str := l_cmd||''''||l_str||''''||');';
      end if;
      p_method.add_line(l_str);
      l_str := null;
    end;
    --
  begin
    for e in l_elements_cur loop
      l_str := e.element.as_string;
      --
      if e.is_atom = 0 then
        add_line;
        if e.is_inc_indent = 'Y' then
          p_method.indent_inc;
        end if;
        if e.method_id is null then
          self.create_fn_html(p_method,e.id);
        else
          m := self.application.package.get_method_array_id(e.method_id);
          self.create_fn_html(self.application.package.methods(m),e.id);
          self.application.package.methods(m).add_line('return '||l_html||';');
        end if;
        
        if e.is_inc_indent = 'Y' then
          p_method.indent_dec;
        end if;
      end if;
      l_str := l_str || e.element.as_string_end ;
      add_line;
      --
    end loop;
  end;
  --
  member procedure create_fn_html is
    m        number;
    l_html   varchar2(20) := xxdoo_html_utils_pkg.g_fn_html_clob_name;
    l_source xxdoo_html_ap_source_typ;-- := self.application.sources(1);
  begin
    m := self.application.package.add_method(p_type      => 'F',
                                             p_name      => self.application.package.method_html,
                                             p_out_type  => 'clob',
                                             p_is_public => 'Y');
    --параметры
    if self.application.sources is not null then
      if self.application.sources.exists(1) then
        l_source := self.application.sources(1);
        self.application.package.methods(m).add_params(l_source.name,null,l_source.object_owner||'.'||l_source.object_name);
      end if;
    end if;
    self.application.package.methods(m).indent_inc;
    self.application.package.methods(m).add_line(l_html||' clob;');
    self.application.package.methods(m).indent_dec;
    self.application.package.methods(m).add_line('begin');
    self.application.package.methods(m).indent_inc;
    self.application.package.methods(m).add_line('dbms_lob.createtemporary(l_html,true);');
    create_fn_html(self.application.package.methods(m));
    self.application.package.methods(m).add_line('return '||l_html||';');
    self.application.package.methods(m).indent_dec;
    self.application.package.methods(m).add_line('exception');
    self.application.package.methods(m).add_line('  when others then');
    self.application.package.methods(m).add_line('    xxdoo.xxdoo_utl_pkg.fix_exception;');
    self.application.package.methods(m).add_line('    raise;');
    --
  end;
  --
  member function get_method(self in out nocopy xxdoo_html, p_name varchar2 default null) return clob is
  begin
    self.prepare;
    self.application.package.method_html := p_name;
    self.create_fn_html;
    --
    return self.application.package.methods(1).get_method;
    --
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end;
  --
end;
/
