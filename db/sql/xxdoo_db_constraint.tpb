create or replace type body xxdoo_db_constraint is

  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin
    return upper('XXDOO.XXDOO_DB_CONSTRAINT');
  end get_type_name;
  --
  constructor function xxdoo_db_constraint return self as result is
  begin
    self.column_list := xxdoo_db_columns();
    return;
  end;
  --
  constructor function xxdoo_db_constraint(p_type           varchar2,
                                           p_rel_table_name varchar2 default null,
                                           p_rel_type       varchar2 default null) return self as result is
  begin
    self              := xxdoo_db_constraint();
    self.type         := p_type;
    self.r_table_name := p_rel_table_name;
    self.r_type       := p_rel_type;
    return;
  end;
  --
  --
  --
  member procedure set_id is
  begin
    if self.id is null then
      self.id := xxdoo_db_seq.nextval();
    end if;
    --
    for c in 1..self.column_list.count loop
      self.column_list(c).set_id;
    end loop;
  end;
  --
  member procedure property(p_name                varchar2 default null,
                            p_column_list         xxdoo_db_columns default null,
                            p_rel_table_name      varchar2 default null,
                            p_rel_constraint_name varchar2 default null,
                            p_rel_type            varchar2 default null,
                            p_rel_collect_name    varchar2 default null,
                            p_delete_rule         varchar2 default null,
                            p_update_rule         varchar2 default null,
                            p_rel_db_table        varchar2 default null) is
  begin
    self.name              := nvl(upper(p_name),
                                  self.name);
    self.column_list       := nvl(p_column_list,
                                  self.column_list);
    self.r_table_name      := nvl(upper(p_rel_table_name),
                                  self.r_table_name);
    self.r_constraint_name := nvl(upper(p_rel_constraint_name),
                                  self.r_constraint_name);
    self.r_type            := nvl(upper(p_rel_type),
                                  self.r_type);
    self.r_collection_name := nvl(p_rel_collect_name,
                                  self.r_collection_name);
    self.delete_rule       := nvl(upper(p_delete_rule),
                                  self.delete_rule);
    self.update_rule       := nvl(upper(p_update_rule),
                                  self.update_rule);
    self.r_db_table        := nvl(upper(p_rel_db_table),
                                  self.r_db_table);
    --
  end;
  --
  --
  --
  member procedure set_name(p_owner      varchar2,
                            p_table_name varchar2,
                            p_cons_name  varchar2,
                            p_cons_num   number) is
    --
    cursor l_constraints_cur(p_columns_string varchar2) is
      select ac.constraint_name
      from   xxdoo_db_constraints_db_v ac
      where  1 = 1
      and    ac.column_list = p_columns_string
      and    ac.constraint_type = upper(self.type)
      and    ac.table_name = upper(p_table_name)
      and    ac.owner = upper(p_owner);
    --
    cursor l_cons_max_num_cur(p_cons_templ_name varchar2) is
      select max(regexp_substr(ac.constraint_name,
                               '[[:digit:]$]+')) + 1
      from   xxdoo_db_constraints_db_v ac
      where  1 = 1
      and    ac.constraint_name like (upper(p_cons_templ_name))
      and    ac.constraint_type = upper(self.type)
      and    ac.table_name = upper(p_table_name)
      and    ac.owner = upper(p_owner);
    --
    l_max_number number;
  begin
    --ищем констрэйн в словаре БД
    open l_constraints_cur(upper(self.columns_string));
    fetch l_constraints_cur
      into self.name;
    --если нет
    if l_constraints_cur%notfound = true then
      self.name := p_cons_name || '_' || case
                     when self.type = 'P' then
                      'pk'
                     when self.type = 'R' then
                      'fk'
                     when self.type = 'U' then
                      'uc'
                   end;
      if self.type <> 'P' then
        --Вычислим номер для добавления в имя констрэйна
        --для этого ищем максимальный числовой суффикс контрэйн в словаре БД по шаблону 
        open l_cons_max_num_cur(upper(self.name)||'%');
        fetch l_cons_max_num_cur
          into l_max_number;
        close l_cons_max_num_cur;
        --если в словаре нет констрэйнов - берем номер, присланный из вне...
        if nvl(l_max_number,1) = 1 then
          l_max_number := p_cons_num;
        end if;
        --
        self.name := self.name || l_max_number;
        --
      end if;
    end if;
    --
    close l_constraints_cur;
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception('Set name for '||p_cons_name||' error.');
      raise;
  end;
  --
  --
  --
  member procedure create_join_template is
    a char := chr(38);
  begin
    --
    self.join_template := null;
    for c in 1..self.column_list.count loop
      self.join_template := self.join_template || 
        case
          when self.join_template is not null then
            ' and '
        end ||
        a||'_1_.'||self.column_list(c).name||' = '||a||'_2_.'||self.r_column_list(c).name || 
        case 
          when self.r_type <> 'COLLECTION' then
            '(+)'
        end;
    end loop;
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception('Create joins template for '||self.name||' error.');
      raise;
  end;
  --
  --
  --
  member procedure create_pk_templates(p_pk_template       in out nocopy varchar2,
                                       p_pk_joins_template in out nocopy varchar2) is
  begin
    p_pk_template       := null;
    p_pk_joins_template := null;
    --
    for c in 1..self.column_list.count loop
      p_pk_template := p_pk_template || 
                         case 
                           when c > 1 then
                             ', '
                         end ||
                         chr(38)||'_1_.'||self.column_list(c).name; 
      p_pk_joins_template := p_pk_joins_template || 
                               case 
                                 when c > 1 then
                                   ' and '
                               end ||
                               chr(38)||'_1_.'||self.column_list(c).name || ' = '|| chr(38)||'_2_.'||self.column_list(c).name;
    end loop;
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception('Create PK template for '||self.name||' error.');
      raise;
  end;
  --
  --
  --
  member function columns_string return varchar2 is
  begin
    return xxdoo_db_utils_pkg.columns_as_string(self.column_list);
  end;
  --
  --
  --
  member procedure ddl(o in out nocopy xxdoo_db_objects_db_list, p_owner varchar2, p_table_name varchar2) is
    cursor is_exists_cur is
      select 1
      from   all_constraints c
      where  c.OWNER = upper(p_owner)
      and    c.TABLE_NAME = upper(p_table_name)
      and    c.CONSTRAINT_NAME = upper(self.name);
    l_dummy number;
  begin
    open is_exists_cur;
    fetch is_exists_cur into l_dummy;
    if is_exists_cur%notfound = true then
      --
      o.new('constraint',self.name);
      o.append('alter table '||p_owner||'.'||p_table_name||' add constraint '||self.name||' ', false);
      case self.type
        when 'P' then
          o.append('primary key('||self.columns_string||')', false);
        when 'U' then
          o.append('unique('||self.columns_string||')', false);
        when 'R' then
          o.append('foreign key('||self.columns_string||') references '||p_owner||'.'||self.r_db_table||'('||
            xxdoo_db_utils_pkg.columns_as_string(self.r_column_list)||')'||
            case
              when self.delete_rule is not null then
                'on delete '||self.delete_rule
            end, false);
        else
          xxdoo_db_utils_pkg.fix_exception('Constraint DDL '||self.name||' for '||p_owner||'.'||p_table_name||' : unknown type: '||self.type);
          raise apps.fnd_api.g_exc_error;
      end case;
      --
    end if;
    close is_exists_cur;
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception('Constraint DDL '||self.name||' for '||p_owner||'.'||p_table_name||' : error.');
      raise;
  end;
  --
end;
/
