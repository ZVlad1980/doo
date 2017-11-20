create or replace type body xxdoo_bk_answer_typ is
  -- Member procedures and functions
  -- Member procedures and functions
  constructor function xxdoo_bk_answer_typ return self as result is
  begin
    --
    dbms_lob.createtemporary(self.result, true);
    self.context := xxdoo_html_context();
    self.regions := xxdoo_db_list();
    self.callbacks := xxdoo_db_list_varchar2();
    --
    return;
  end;
  --
  constructor function xxdoo_bk_answer_typ(p_book_name varchar2, 
                                           p_query     varchar2,
                                           p_path      varchar2, 
                                           p_inputs    clob, 
                                           p_meta      varchar2) return self as result is
    --
    l_callback_id varchar2(1024);
    l_dao         xxdoo_dao;
  begin
    self := xxdoo_bk_answer_typ;
    --
    self.book := xxdoo_bk_core_pkg.get_book(p_book_name);
    self.scheme_id := self.book.entity.scheme_id;
    --
    self.path := p_path; --SYS_CONTEXT('CLIENTCONTEXT','SERVICE_TAILURI'); --regexp_substr(p_path,'\#.+\?',1,1);
    --
    l_callback_id := regexp_substr(p_query,'[^=]+',1,2);
    if l_callback_id is not null then
      self.push_callback(l_callback_id);
    end if;
    --
    if length(replace(replace(p_inputs,'{'),'}')) > 0 then
      self.inputs := xxdoo.xxdoo_json_pkg.create_xml(p_inputs);
    else
      self.inputs := null;
    end if;
    --
    self.meta      := p_meta;
    --
    return;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end;
  --
  --
  --
  member function get_callback_num(p_callback_id varchar2) return number is
    l_result number;
  begin
    for c in 1..self.callbacks.count loop
      if self.callbacks(c) = p_callback_id then
        l_result := c;
        exit;
      end if;
    end loop;
    --
    return l_result;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end get_callback_num;
  --
  --
  --
  member procedure push_callback(p_callback_id varchar2) is
    cn number;
  begin
    cn := self.get_callback_num(p_callback_id);
    if cn is null then
      self.callbacks.extend;
      self.callbacks(self.callbacks.count) := p_callback_id;
    end if;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end;
  --
  --
  --
  member procedure execute_callbacks is
   --
   procedure exec_callback(p_cn number) is
   begin
     execute immediate '
begin
  '||self.book.callbacks(p_cn).method.get_method_name||'(:p_answer);
end;' using in out self;
   end;
   --
   --
   --
  begin
    self.layout_mode := 'Y';
    for c in 1..self.callbacks.count loop
      exec_callback(self.book.get_callback_num_from_id(self.callbacks(c)));
      if self.layout_mode = 'Y' then
        self.layout_mode := 'N';
      end if;
    end loop;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end;
  --
  
  member procedure authenticate is
  begin
    self.user_name := upper(SYS_CONTEXT('CLIENTCONTEXT','SERVICE_USERNAME'));
    if self.user_name is null then
      self.user_name := 'ZHURAVOV_VB@MOSCOW';
    end if;
    --
    execute immediate '
    select fu.user_id
    from   apps.fnd_user fu
    where  1=1
    and    fu.user_name = :user_name' into self.user_id using self.user_name;
    --
  exception
    when no_data_found then
      xxdoo_utl_pkg.fix_exception('User not found '||self.user_name);
      raise;
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end;
  --
  member procedure define_role is
  begin
    self.role := xxdoo_bk_role_typ(self.book.name, 'Owner');
  end;
  --
  member procedure define_params is
    l_key    varchar2(1024);
    l_value  varchar2(1024);
  begin
    self.book.path_parser.parse(self.path);
    self.book.path_parser.first;
    while self.book.path_parser.next(l_key,l_value) loop
      if l_key <> l_value then
        self.parameter(l_key, l_value);
      end if;
    end loop; 
    --
    if self.parameter('filter') is null then
      self.parameter('filter','ALL');
    end if;
  end;
  --
  member procedure define_entries is
    --
    l_key     varchar2(1024);
    l_value   varchar2(1024);
    --
    cursor l_entity_cur(p_scheme_id number, p_entity_name varchar2) is
      select e.entity_id
      from   xxdoo_bk_entities_v e
      where  1=1
      and    (e.entity_name = p_entity_name
               or
              e.entry_name = p_entity_name
             )
      and    e.scheme_id = p_scheme_id;
    --
    l_entity_row l_entity_cur%rowtype;
    l_dao xxdoo_dao;
    --
    l_object anydata;
  begin
    self.context.params.first;
    if self.inputs is not null then
      l_dao := self.dao(p_entity_id => self.book.entity.entity_id);
      self.entry(self.book.entity.entry_name, l_dao.load(self.inputs));
    end if;
    --
    while self.context.params.next(l_key,l_value) loop
      open l_entity_cur(self.book.entity.scheme_id, l_key);
      fetch l_entity_cur into l_entity_row; --dbms_output.put_line('KEY ="' || key || '", value = "' || value || '"');
      --
      if l_entity_cur%found = true then
        l_dao := self.dao(p_entity_id => l_entity_row.entity_id);
        if self.book.entity.entity_id <> l_entity_row.entity_id 
           or (self.book.entity.entity_id = l_entity_row.entity_id 
                and
               self.entry(self.book.entity.entry_name) is null) then
          l_dao.query.w('id',l_value);
          self.entry(
            l_key,
            l_dao.get
          );
        end if;
      end if;
      --
      close l_entity_cur;
    end loop;
    --*/
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end;
  --
  --
  --
  member procedure refresh_regions is
  begin
    for r in 1..self.book.regions.count loop
      if self.layout_mode = 'Y' or (self.is_region(self.book.regions(r).name) = true) then
        self.book.regions(r).refresh := 'Y';
        execute immediate 'begin :result := '||self.book.regions(r).build_method.get_method_name||'(:l_answer); end;'
          using out    self.book.regions(r).html, 
                in out self;

      else
        self.book.regions(r).refresh := 'N';
      end if;
    end loop;
    --
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end refresh_regions;

  --
  --
  --
  member procedure create_result(p_result in out nocopy xxdoo_bk_service_raw_typ) is
    cr        varchar2(1) := chr(10);
    l_refresh number;
    --
    procedure create_path(p_path varchar2) is
      --
      l_key         varchar2(1024);
      l_value       varchar2(1024);
      l_const_value varchar2(1024);
      --
    begin
      --
      self.path := null;
      self.book.path_parser.first_key;
      while self.book.path_parser.next_key(l_key,l_value) loop
        if l_value = l_key then 
          l_const_value := case when l_const_value is not null then '/' end || l_value; 
        else
          l_value := self.parameter(l_key);
          if l_value is not null then
            self.path := 
              self.path
              || case when self.path is not null then '/' end
              || case when l_const_value is not null then l_const_value || '/' end
              || l_value;
            l_const_value := null;
          end if;
        end if;
      end loop;
      -- 
      return;
      --
    end create_path;
  --
  begin
    --
    --xxdoo_bk_core_pkg.plog(p_message => 'create_result:parameters',p_xml_data => xmltype.createXML(self.params));
    p_result.mime_type := 'text/html';
    if self.layout_mode = 'Y' then
      --self.entry(p_name => 'book', p_object => anydata.ConvertObject(self.book));
      --self.book.layout.html(p_result.clob_value, self.get_context);
      p_result.clob_value := self.template('layout', anydata.ConvertObject(self.book));
    else
      if length(self.result) = 0 and self.layout_mode <> 'L' then
        p_result.mime_type := 'application/json';
        create_path(self.book.path); --self.path := 'ALL/1/NEW';
        --self.append('{' || cr || '  "path": "call/' || replace(self.path,'"','\"') || '",' || cr || '  "regions": {' || cr);
        self.append('{' || cr || '  "path": "'||xxdoo_bk_core_pkg.get_medium_uri(self.book.name)||'call/' || replace(self.path,'"','\"') || '",' || cr || '  "regions": {' || cr);
        --
        l_refresh := 1;
        for r in 1..self.book.regions.count loop
          if self.book.regions(r).refresh = 'Y' then
            self.append(case
                          when l_refresh > 1 then
                            ','||cr
                        end ||
                        '    "' || self.book.regions(r).name || '": "'
                        || replace(self.book.regions(r).html,'"','\"')
                        || '"');
            l_refresh := l_refresh + 1;
          end if;
        end loop;
        --
        self.append(cr||'  }'||cr||'}');
      --
      end if;
      --
      p_result.clob_value := self.result;
      --
    end if;
    --
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;

  end;
  --
  --
  --
  member function entry(p_name varchar2) return anydata is
  begin
    return self.context.entries.get_value(p_name);
  end;
  --
  --
  --
  member procedure entry(p_name varchar2, p_object anydata) is
  begin
    self.context.entries.add_value(p_name, p_object);
  end;
  --
  --
  --
  member procedure parameter(p_name varchar2, p_value varchar2) is
  begin
    self.context.params.add_value(p_name, p_value);
  end;
  --
  --
  --
  member function parameter(p_name varchar2) return varchar2 is
  begin
    return self.context.params.get_varchar2(p_name);
  exception
    when others then
      xxdoo_utl_pkg.fix_exception('Get parameter "'||p_name||'" error.');
      raise; --return null;
  end;
  --
  --
  --
  member procedure refresh(p_region_name varchar2) is
  begin
    self.regions.add_value(p_region_name);
  exception
    when others then
      xxdoo_utl_pkg.fix_exception('Mark region "'||p_region_name||'" for refresh error.');
      raise;
  end;
  --
  --
  --
  member function is_region(p_region_name varchar2) return boolean is
  begin
    return self.regions.is_exists(p_region_name);
  end is_region;
  --
  --
  --
  member procedure append(p_str varchar2) is
  begin
    dbms_lob.append(self.result, p_str);
  end;
  --
  --
  --
  member procedure append(p_str clob) is
  begin
    dbms_lob.append(self.result, p_str);
  end;
  --
  --
  --
  member function dao(p_entity_id number) return xxdoo_dao is
  begin
    return xxdoo_bk_core_pkg.get_dao(p_entity_id);
  end;
  --
  --
  --
  member function dao(p_entity_name varchar2) return xxdoo_dao is
    cursor l_entity_cur(p_scheme_id number, p_entity_name varchar2) is
      select e.entity_id
      from   xxdoo_bk_entities_v e
      where  1=1
      and    (e.entry_name = p_entity_name
               or
              e.entity_name = p_entity_name
             )
      and    e.scheme_id = p_scheme_id;
    l_entity_id number;
  begin
    open l_entity_cur(self.scheme_id, p_entity_name);
    fetch l_entity_cur into l_entity_id;
    if l_entity_cur%notfound = true then
      close l_entity_cur;
      xxdoo_utl_pkg.fix_exception('DAO: entity "'||p_entity_name||'" not found.');
      raise xxdoo_db_utils_pkg.g_exc_error;
    end if;
    close l_entity_cur;
    --
    return dao(l_entity_id);
    --
  exception
    when others then
      xxdoo_utl_pkg.fix_exception('DAO: entity "'||p_entity_name||'" error.');
      raise;
  end;
  --
  --
  --
  member function template(self in out nocopy xxdoo_bk_answer_typ, p_template_name varchar2, p_object anydata default null) return clob is
  begin
    return xxdoo_bk_core_pkg.get_template(self.book.id, p_template_name).content(self.context, p_object);
  end;
  --
  --
  --
  member function page_conditions(self in out nocopy xxdoo_bk_answer_typ, rpn number) return boolean is
    l_result boolean := true;
    l_result_char varchar2(1) := 'Y';
  begin
    --
    if self.role.pages(rpn).condition_method is not null then
      --dbms_output.put_line(self.condition_method.body);
      execute immediate self.role.pages(rpn).condition_method.body  using in out self, out l_result_char;
      if l_result_char = 'N' then
        l_result := false;
      end if;
    end if;
    --
    return l_result;
    --
  exception 
    when others then
      xxdoo_utl_pkg.fix_exception('Check condition for page '||self.role.pages(rpn).page.name||' error.');
      raise;
  end page_conditions;
  --
  --
  --
  member procedure page_prepare(rpn number) is
  begin
    --
    if self.role.pages(rpn).page.prepare_method is not null then
      execute immediate '
begin
  '||self.role.pages(rpn).page.prepare_method.get_method_name||'(:p_answer);
end;
'     using in out self;
    end if;
    --
  exception
    when others then
      xxdoo_utl_pkg.fix_exception('Prepare context for page ' || self.role.pages(rpn).page.name || ' error.');
      raise;
  end page_prepare;
  --
  --
  --
  
  member function page_content(self in out nocopy xxdoo_bk_answer_typ, rpn number) return clob is
    l_entry anydata;
  begin
    -- dbms_output.put_line(self.content_method.body);
    if self.role.pages(rpn).page.entity.entity_id is null then
      return xxdoo_html_pkg.get_html(self.role.pages(rpn).page.content_method.get_body);
    else
      --добавить проверку наличия объекта! Если нет - не формировать контент!
      l_entry := self.entry(self.role.pages(rpn).page.entity.entry_name);
      if l_entry is null then
        execute immediate 'begin :result := anydata.convertObject('||self.role.pages(rpn).page.entity.object_name||'); end;' using out l_entry;
      end if;
      --
      self.entry(p_name => self.role.pages(rpn).page.entity.entry_name, p_object => l_entry);
      --
      return xxdoo_html_pkg.get_html(self.role.pages(rpn).page.content_method.get_body, 
                                     anydata.ConvertObject(self.context));
    end if;
  exception
    when others then
      xxdoo_utl_pkg.fix_exception('Get content for page ' || self.role.pages(rpn).page.name || ' error.');
      raise;
  end page_content;
  --
  --
  --
  member procedure role_prepare is
  begin
    --
    if self.role.method is not null then
      execute immediate '
begin
  '||self.role.method.get_method_name||'(:p_answer);
end;
'     using in out self;
    end if;
    --
  exception
    when others then
      xxdoo_utl_pkg.fix_exception('Prepare context for role ' || self.role.name || ' error.');
      raise;
  end role_prepare;
  --
end;
/
