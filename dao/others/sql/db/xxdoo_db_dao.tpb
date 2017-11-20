create or replace type body xxdoo_db_dao is
  
  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin
    return upper('XXDOO.XXDOO_DB_DAO');
  end get_type_name;
  --
  constructor function xxdoo_db_dao return self as result is
  begin
    self.query   := xxdoo_db_query();
    return;
  end;
  --
  constructor function xxdoo_db_dao(p_scheme_name varchar2, p_table_name varchar2) return self as result is
    --
    cursor l_dao_cur is
      select value(d)
      from   xxdoo_db_schemes_t s,
             xxdoo_db_daos_v    d
      where  1=1
      and    d.name = p_table_name
      and    d.scheme_id = s.id
      and    s.name = p_scheme_name;
  begin
    open l_dao_cur;
    fetch l_dao_cur into self;
    if l_dao_cur%notfound = true then
      close l_dao_cur;
      xxdoo_db_utils_pkg.fix_exception('Table '||p_table_name||' into scheme '||p_scheme_name||' not found.');
      raise apps.fnd_api.g_exc_error;
    end if;
    close l_dao_cur;
    --
    self.query   := xxdoo_db_query();
    --
    return;
  end;
  --
  constructor function xxdoo_db_dao(p_object xxdoo_db_object) return self as result is
    l_type_name  varchar2(120);
    --
    cursor l_dao_cur(p_owner varchar2, p_type_name varchar2) is
      select value(d)
      from   xxdoo_db_daos_v d
      where  1=1
      and    upper(d.owner) = p_owner
      and    upper(d.db_type) = p_type_name;
  begin
    l_type_name := p_object.get_type_name;
    open l_dao_cur(regexp_substr(l_type_name,'[^.]+',1,1), regexp_substr(l_type_name,'[^.]+',1,2));
    fetch l_dao_cur into self;
    if l_dao_cur%notfound = true then
      close l_dao_cur;
      xxdoo_db_utils_pkg.fix_exception('Table '||l_type_name||' not found.');
      raise apps.fnd_api.g_exc_error;
    end if;
    close l_dao_cur;
    --
    self.query   := xxdoo_db_query();
    --
    return;
  end;
  --
  constructor function xxdoo_db_dao(p_object anydata) return self as result is
    l_type_name  varchar2(120);
    --
    cursor l_dao_cur(p_owner varchar2, p_type_name varchar2) is
      select value(d)
      from   xxdoo_db_daos_v d
      where  1=1
      and    upper(d.owner) = p_owner
      and    upper(d.db_type) = p_type_name;
  begin
    l_type_name := p_object.GetTypeName;
    open l_dao_cur(regexp_substr(l_type_name,'[^.]+',1,1), regexp_substr(l_type_name,'[^.]+',1,2));
    fetch l_dao_cur into self;
    if l_dao_cur%notfound = true then
      close l_dao_cur;
      xxdoo_db_utils_pkg.fix_exception('Table '||l_type_name||' not found.');
      raise apps.fnd_api.g_exc_error;
    end if;
    close l_dao_cur;
    --
    self.query   := xxdoo_db_query();
    --
    return;
  end;
  --
  constructor function xxdoo_db_dao(p_table_id number) return self as result is
    cursor l_dao_cur is
      select value(d)
      from   xxdoo_db_daos_v d
      where  1=1
      and    d.id = p_table_id;
  begin
    open l_dao_cur;
    fetch l_dao_cur into self;
    if l_dao_cur%notfound = true then
      close l_dao_cur;
      xxdoo_db_utils_pkg.fix_exception('Table '||p_table_id||' not found.');
      raise apps.fnd_api.g_exc_error;
    end if;
    close l_dao_cur;
    --
    self.query   := xxdoo_db_query();
    --
    return;
  end;
  --
  member procedure update_version is
    cursor l_version_cur(p_table_id integer) is
      select t.version
      from   xxdoo_db_tables_t t
      where  t.id = p_table_id;
    l_version integer;
  begin
    open l_version_cur(self.id);
    fetch l_version_cur into l_version;
    close l_version_cur;
    if l_version <> self.instance_version then
      self := xxdoo_db_dao(self.id);
    end if;
  end;
  --
  member function load(p_xmlinfo xmltype) return anydata is
    l_result anydata;
  begin
    --
    execute immediate '
declare
  l_obj '||self.db_type||';
' || chr(10) || self.load_method || chr(10)||'
begin
  load(l_obj, :p_xmlinfo);
  :l_result := l_obj.get_anydata;
exception
  when others then
    xxdoo_utl_pkg.fix_exception;
    raise;
end;' using in p_xmlinfo, out l_result;
    --
    return l_result;
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception('DAO load object '||self.db_type||' error.');
      raise;
  end;
  --
  member procedure put(p_object anydata) is
    pragma autonomous_transaction;
    l_type_code pls_integer;
    l_type      anytype;
  begin
    l_type_code := p_object.getType(l_type);
    --
    -- PUT object
    --
    if l_type_code = dbms_types.TYPECODE_OBJECT then
      execute immediate '
declare
  l_objs '||self.db_coll_type||' := '||self.db_coll_type||'();
' || chr(10) || self.put_method || chr(10)||'
begin
  l_objs.extend;
  l_objs(1) := '||self.db_type||'(:p_object);
  put(l_objs);
  --
exception
  when others then
    xxdoo_utl_pkg.fix_exception;
    raise;
end;' using in p_object;
    --
    --PUT collection
    --
    elsif l_type_code = dbms_types.TYPECODE_NAMEDCOLLECTION then
      execute immediate '
declare
  l_coll anydata := :p_object;
  l_objs '||self.db_coll_type||';
  l_dummy pls_integer;
' || chr(10) || self.put_method || chr(10)||'
begin
  l_dummy := l_coll.getCollection(l_objs);
  put(l_objs);
  --
exception
  when others then
    xxdoo_utl_pkg.fix_exception;
    raise;
end;' using in p_object;
    else
      xxdoo_db_utils_pkg.fix_exception('DAO put object '||p_object.GetTypeName||' has unknown type code: '||l_type_code);
      raise apps.fnd_api.g_exc_error;
    end if;
    --
    commit;
    --
    return;
    --
  exception
    when others then
      rollback;
      xxdoo_db_utils_pkg.fix_exception('DAO put object '||p_object.GetTypeName||' error.');
      raise;
  end;
  --
  --
  --
  member function get_query(p_fast_mode boolean) return varchar2 is
    --
    el xxdoo_db_query_elements;
    s xxdoo_db_select;
    l_result varchar2(32767);
    l_view_name varchar2(32);
    --
    l_last_column varchar2(32);
    l_path        varchar2(200);
    l_new_path    varchar2(200);
    l_pk_columns  varchar2(200);
    --
    type l_table_typ is record (
      name varchar2(32),
      alias varchar2(32),
      conditions varchar2(200),
      new boolean
    );
    type l_tables_typ is table of l_table_typ index by varchar2(200);
    l_tables l_tables_typ;
    l_seq    number := 1;
    --
    cursor l_joins_cur(p_table_name varchar2, p_column_name varchar2) is
      select j.r_table_name table_name, j.condition_template
      from   table(self.joins) j
      where  1=1
      and    j.column_name = p_column_name
      and    j.table_name = p_table_name;
    l_joins_row l_joins_cur%rowtype;
    --
    cursor l_path_parse_cur(p_path varchar2) is
      select regexp_substr(p_path,'[^.]+',1,level) column_name
      from   dual
      connect by regexp_substr(p_path,'[^.]+',1,level) is not null;
    --
    procedure add_table(p_path       varchar2, 
                        p_table_name varchar2, 
                        p_conditions varchar2,
                        p_old_path   varchar2) is
      l_conditions xxdoo_db_tab_joins_t.condition_template%type;
    begin 
      if not l_tables.exists(p_path) then
        if p_old_path is not null then
          l_conditions := replace(p_conditions,chr(38)||'_1_',l_tables(p_old_path).alias);
        end if;
        --
        l_tables(p_path).name := p_table_name;
        l_tables(p_path).alias := 't' || l_seq;
        l_tables(p_path).conditions := replace(l_conditions,chr(38)||'_2_',l_tables(p_path).alias);
        l_tables(p_path).new := true;
        l_seq := l_seq + 1;
        --
      end if;
    end;
    --
    procedure add_table(p_path varchar2) is
    begin
      if l_tables(p_path).new then
        s.f(l_tables(p_path).name || ' ' || l_tables(p_path).alias);
        if l_tables(p_path).conditions is not null then
          s.w(l_tables(p_path).conditions);
        end if;
        l_tables(p_path).new := false;
      end if;
    end;
    --
  begin 
    --
    el := self.query.elements;
    s := xxdoo_db_select();
    --
    add_table(self.db_table,self.db_table, null, null);
    --Пробежим по элементам запроса (where, order, group)
    for e in 1..el.count loop
      --путь каждого элемента начинается с базовой таблицы
      l_new_path := self.db_table;--l_tables(l_table_name).alias;
      l_path     := case e when 1 then null else l_new_path end;
      --парсинг пути
      for c in l_path_parse_cur(el(e).name) loop
        --
        if nvl(l_path,'NULL') <> l_new_path then
          l_path := l_new_path;
          add_table(l_path);
        end if;
        --является ли текущее поле внешним ключом 
        open l_joins_cur(l_tables(l_path).name, c.column_name);
        fetch l_joins_cur into l_joins_row;
        --если текущее поле является встроенным объектом или внешним ключом
        if l_joins_cur%found then
          l_new_path := l_path || '.' || c.column_name;
          add_table(l_new_path,l_joins_row.table_name,l_joins_row.condition_template,l_path);
        end if;
        --
        close l_joins_cur;
        --
        l_last_column := c.column_name;
        --
      end loop;
      --пропишем алиас таблицы-источника и имя поля в элемент
      el(e).name := l_tables(l_path).alias || '.' || l_last_column;
      --добавим элемент в запрос
      el(e).push_string(s);
    end loop;
    --
    l_pk_columns := null;
    for c in 1..self.pk_columns.count loop
      s.s(l_tables(self.db_table).alias||'.'||self.pk_columns(c).name);
      l_pk_columns := l_pk_columns ||case when c > 1 then ', ' end || 'v.'||self.pk_columns(c).name;
    end loop;
    --собираем итоговый запрос
    l_view_name := case
                     when p_fast_mode or (p_fast_mode is null and self.query.is_page_mode) then
                       self.db_view_fast
                     else
                       self.db_view
                   end;
    --
    l_result := 'select value(obj) obj from ';
    if self.query.is_page_mode = true then
      l_result := l_result ||
     '(select rownum rnum,'||l_pk_columns||'
       from ('||s.build||') v
       where rownum <= '||to_char(self.query.to_row)||') v,
           '||l_view_name||' obj
     where v.rnum >= '||to_char(self.query.from_row);
    else
      l_result := l_result || '(select rownum rnum, '||l_pk_columns||' from ('||s.build||') v) v, '||l_view_name||' obj where 1=1';
    end if;
    --
    for c in 1..self.pk_columns.count loop
      l_result := l_result || ' and v.'||self.pk_columns(c).name||' = obj.'||self.pk_columns(c).name;
    end loop;
    l_result := l_result || ' order by v.rnum';
    --
    return l_result;
    --
  exception 
    when others then
      xxdoo_db_utils_pkg.fix_exception('DAO: create query for get '||self.name||' error.');
      raise;
  end get_query;
  --
  --
  --
  member function  get_all(p_fast_mode boolean default null) return anydata is
    l_result anydata;
  begin
    --
    execute immediate 'select anydata.ConvertCollection(cast(multiset('||get_query(p_fast_mode)||') as '||self.db_coll_type||')) from   dual' 
      into l_result;
    --
    return l_result;
  exception 
    when others then
      xxdoo_db_utils_pkg.fix_exception('DAO: get_all '||self.name||' error.');
      raise;
  end get_all;
  --
  --
  --
  member function get(p_fast_mode boolean default null) return anydata is
    l_result anydata;
  begin
    --
    execute immediate 'select anydata.convertObject(v.obj) from ('||get_query(p_fast_mode)||') v where rownum = 1'
      into l_result;
    --
    return l_result;
  exception 
    when others then
      xxdoo_db_utils_pkg.fix_exception('DAO: get '||self.name||' error.');
      raise;
  end;
  --
end;
/
