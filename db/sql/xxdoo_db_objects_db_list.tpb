create or replace type body xxdoo_db_objects_db_list is
  
  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin
    return upper('XXDOO.XXDOO_DB_OBJECTS_DB_LIST');
  end get_type_name;
  --
  constructor function xxdoo_db_objects_db_list(p_owner varchar2) return self as result is
  begin 
    self.owner := p_owner;
    self.init;
    --
    return;
  end;
  --
  --
  --
  member procedure init is
  begin
    self.objects_db := xxdoo_db_objects_db();
  end;
  --
  --
  --
  member function object_pos(p_owner varchar2, p_name varchar2, p_type varchar2) return number is
    l_result number;
  begin
    for o in 1..self.objects_db.count loop
      if upper(self.objects_db(o).owner) = upper(p_owner) and
         upper(self.objects_db(o).name) = upper(p_name)   and  
         upper(self.objects_db(o).type) = upper(p_type) then
        l_result := o;
        exit;
      end if;
    end loop;
    --
    return l_result;
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception;
      raise;
  end;
  --
  --
  --
  member procedure new(p_type   varchar2,
                       p_name   varchar2) is
  begin
    --
    if p_type <> 'attribute' and object_pos(self.owner, p_name, p_type) is not null then
      xxdoo_db_utils_pkg.fix_exception('New objects '||p_type||' '||self.owner||'.'||p_name||' already exists into current generation.');
      raise apps.fnd_api.g_exc_error;
    end if;
    --
    self.objects_db.extend;
    self.objects_db(self.objects_db.count) := 
      xxdoo_db_object_db(p_position => self.objects_db.count,
                          p_type     => p_type,
                          p_owner    => self.owner,
                          p_name     => p_name);
    --
  exception
    when others then
      xxdoo_db_utils_pkg.fix_exception('New object '||self.owner||'.'||p_name||' error.');
      raise;
  end new;
  --
  -- Перегрузка методов object_ddl
  --
  member function full_name return varchar2 is begin return self.objects_db(self.objects_db.count).full_name; end;
  member procedure append(p_str varchar2, p_eof boolean default true) is begin self.objects_db(self.objects_db.count).append(p_str,p_eof); end append;
  member procedure appends(p_str varchar2, p_eof boolean default true) is begin self.objects_db(self.objects_db.count).appends(p_str,p_eof); end appends;
  member procedure inc(p_value number default 2) is begin self.objects_db(self.objects_db.count).inc(p_value); end inc;
  member procedure dec(p_value number default 2) is begin self.objects_db(self.objects_db.count).dec(p_value); end dec;
  member procedure incs(p_value number default 2) is begin self.objects_db(self.objects_db.count).incs(p_value); end incs;
  member procedure decs(p_value number default 2) is begin self.objects_db(self.objects_db.count).decs(p_value); end decs;
  member function get_spc return varchar2 is begin return self.objects_db(self.objects_db.count).spc; end get_spc;
  --
  --
  --
  member procedure invoke is
  begin
    for o in 1..self.objects_db.count loop
      self.objects_db(o).invoke;
    end loop;
  end;
  --
  --
  --
  member procedure put(p_scheme_name varchar2) is
    pragma autonomous_transaction;
  begin
    if self.objects_db.count < 1 then
      return;
    end if;
    --
    if self.archive_id is null then
      self.archive_id := xxdoo_db_seq.nextval();
      insert into xxdoo_db_archive_t(id, scheme_name)values(self.archive_id,p_scheme_name);
    end if;
    --
    for o in 1..self.objects_db.count loop
      self.objects_db(o).set_id;
    end loop;
    --
    insert into xxdoo_db_archive_lines_t(id, 
                                         archive_id, 
                                         position, 
                                         type, 
                                         owner, 
                                         name, 
                                         body)
      select o.id,
             self.archive_id,
             o.position,
             o.type,
             o.owner,
             o.name,
             o.body
      from   table(self.objects_db) o
      where  1=1
      and    o.id not in (
               select a.id
               from   xxdoo_db_archive_lines_t a
               where  a.archive_id = self.archive_id
             );
    --
    commit;
  exception
    when others then
      rollback;
      xxdoo_db_utils_pkg.fix_exception('Put archive error.');
      raise;
  end;
  --
end;
/
