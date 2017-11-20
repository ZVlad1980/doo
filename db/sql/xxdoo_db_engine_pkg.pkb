create or replace package body xxdoo_db_engine_pkg is
  -----------------------------------------------------------------------------------------------------------
  -- Разработка xxdoo_DB. Создание объектов БД по описанию
  --   Публикация: 
  --
  --   Основной пакет: сохранение схемы, генерация объектов
  --
  -- MODIFICATION HISTORY
  -- Person         Date         Comments
  -- ---------      ------       ------------------------------------------
  -- Журавов В.Б.   16.07.2014   Создание
  -- Журавов В.Б.   07.08.2014   Убрал создание объектов по сущностям не имеющим связей
  -- Журавов В.Б.   20.08.2014   Сделал создаваемые типы финальными (иначе возникает проблема с добавлением атрибутов и использованием anydata)
  -----------------------------------------------------------------------------------------------------------
  --
  g_version varchar2(15) := '3.1.2';
  --
  type g_put_from_type is record(
    from_table varchar2(100),
    from_alias varchar2(10),
    table_info xxdoo_db_table
  );
  type g_put_froms_type is table of g_put_from_type index by binary_integer;
  --
  type g_put_type is record(
    froms g_put_froms_type,
    type_object   varchar2(20)
  );
  --
  --
  function version return varchar2 is begin return g_version; end;
  --
  procedure constructor_default(p_table in out nocopy xxdoo_db_table, o in out nocopy xxdoo_db_objects_db_list) is
    cursor l_attr_coll_cur is
      select a.name, a.owner_type owner, a.type
      from   table(p_table.attribute_list) a
      where  1=1
      and    a.type_code = 'COLLECTION'
      and    a.member_type = 'A';
  begin
    o.new('constructor',p_table.db_type);
    o.appends('constructor function '||p_table.db_type||' return self as result',false);
    o.append(o.get_spc || ' is ');
    o.inc;
    o.append('begin');
    o.inc;
    for a in l_attr_coll_cur loop
      o.append('self.'||a.name||' := '||a.owner||'.'||a.type||'();');
    end loop;
    o.append('return;');
    o.dec;
    o.append('end '||p_table.db_type||';');
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end;
  --
  --
  --
  procedure constructor_anydata(p_table in out nocopy xxdoo_db_table, o in out nocopy xxdoo_db_objects_db_list) is
  begin
    o.new('constructor',p_table.db_type);
    --o.inc;
    o.appends('constructor function '||p_table.db_type||'(p_object anydata) return self as result',false);
    o.append(o.get_spc || ' is ');
    o.inc;
    o.inc;
    o.append('l_dummy pls_integer;');
    o.dec;
    o.append('begin');
    o.inc;
    o.append('if p_object is not null then');
    o.append('  l_dummy := p_object.getObject(self);');
    o.append('else');
    o.append('  self := '||p_table.db_type||'();');
    o.append('end if;');
    o.append('--');
    o.append('return;');
    o.dec;
    o.append('end '||p_table.db_type||';');
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end;
  --
  --
  --
  procedure method_get_type_name(p_table in out nocopy xxdoo_db_table, o in out nocopy xxdoo_db_objects_db_list) is
  begin
    o.new('function','get_type_name');
    o.appends('overriding member function '||o.full_name||' return varchar2',false);
    o.append(o.get_spc || ' is ');
    o.inc;
    o.append('begin');
    o.inc;
    o.append('return '''||upper(p_table.owner||'.'||p_table.db_type)||''';');
    o.dec;
    o.append('end '||o.full_name||';');
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end;
  --
  --
  --
  procedure method_set_id(p_table in out nocopy xxdoo_db_table, o in out nocopy xxdoo_db_objects_db_list) is
    cursor l_attr_coll_cur is
      select a.name--, a.owner_type owner, a.type
      from   table(p_table.attribute_list) a
      where  1=1
      and    a.type_code = 'COLLECTION'
      and    a.member_type = 'A';
    cursor l_columns_cur is
      select c.name
      from   table(p_table.column_list) c
      where  nvl(c.is_sequence,'N') = 'Y';
    --
    l_empty boolean := true;
  begin
    --
    o.new('procedure','set_id');
    o.appends('member procedure '||o.full_name,false);
    o.append(o.get_spc || ' is ');
    o.inc;
    o.append('begin');
    o.inc;
    --
    if p_table.db_sequence is not null then
      for c in l_columns_cur loop
        o.append('--');
        o.append('if self.'||c.name||' is null then');
        o.append('  self.'||c.name||' := '||p_table.owner||'.'||p_table.db_sequence||'.nextval();');
        o.append('end if;');
        l_empty := false;
      end loop;
    end if;
    --
    for a in l_attr_coll_cur loop
      o.append('--');
      o.append('if self.'||a.name||' is not null then');
      o.append('  for i in 1..self.'||a.name||'.count loop');
      o.append('    self.'||a.name||'(i).set_id;');
      o.append('  end loop;');
      o.append('end if;');
      l_empty := false;
    end loop;
    --
    if l_empty = true then
      o.append('null;');
    else
      o.append('--');
    end if;
    o.dec;
    o.append('end '||o.full_name||';');
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end;
  --
  --
  --
  procedure method_get_anydata(p_table in out nocopy xxdoo_db_table, o in out nocopy xxdoo_db_objects_db_list) is
  begin
    o.new('function','get_anydata');
    o.appends('member function '||o.full_name||' return anydata',false);
    o.append(o.get_spc || ' is ');
    o.inc;
    o.append('begin');
    o.inc;
    o.append('return anydata.convertObject(self);');
    o.dec;
    o.append('end '||o.full_name||';');
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end;
  --
  --
  --
  procedure add_attributes(p_table in out nocopy xxdoo_db_table, o in out nocopy xxdoo_db_objects_db_list) is
  begin
    for a in 1..o.objects_db.count loop
      p_table.add_attribute(
        xxdoo_db_attribute(
          o.objects_db(a).name,
          o.objects_db(a).spc,
          o.objects_db(a).body
        )
      );
    end loop;
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end;
  /*--
  --
  --
  procedure (p_table in out nocopy xxdoo_db_table) is
  begin
    null;
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end; --*/
  --
  --
  --
  procedure add_default_methods(p_table in out nocopy xxdoo_db_table) is
    o xxdoo_db_objects_db_list := xxdoo_db_objects_db_list(null);
  begin
    constructor_default(p_table, o);
    constructor_anydata(p_table, o);
    method_get_type_name(p_table, o);
    method_set_id(p_table, o);
    method_get_anydata(p_table, o);
    --
    add_attributes(p_table,o);
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end add_default_methods;
  --
end xxdoo_db_engine_pkg;
/
