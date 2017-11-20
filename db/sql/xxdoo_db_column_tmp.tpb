create or replace type body xxdoo_db_column_tmp is

  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin
    return upper('XXDOO.XXDOO_DB_COLUMN_TMP');
  end get_type_name;

  --
  constructor function xxdoo_db_column_tmp return self as result is
  begin
    self.constraints_tmp := xxdoo_db_constraints();
    return;
  end;

  --
  constructor function xxdoo_db_column_tmp(p_name   varchar2,
                                           p_column xxdoo_db_column_tmp)
    return self as result is
  begin
    self      := p_column;
    self.name := p_name;
    return;
  end;

  --
  member function property(p_type          varchar2 default null,
                           p_length        number default null,
                           p_scale         number default null,
                           p_nullable      varchar2 default null,
                           p_default_value varchar2 default null,
                           p_indexed       varchar2 default null,
                           p_is_unique     varchar2 default null,
                           p_sequence      varchar2 default null)
    return xxdoo_db_column_tmp is
    o xxdoo_db_column_tmp;
  begin
    o               := self;
    o.type          := nvl(upper(p_type),
                           o.type);
    o.length        := nvl(p_length,
                           o.length);
    o.scale         := nvl(p_scale,
                           o.scale);
    o.nullable      := nvl(upper(p_nullable),
                           o.nullable);
    o.default_value := nvl(upper(p_default_value),
                           o.default_value);
    o.is_indexed    := nvl(upper(p_indexed),
                           o.is_indexed);
    o.is_unique     := nvl(upper(p_is_unique),
                           o.is_unique);
    o.is_sequence   := nvl(upper(p_sequence),
                           o.is_sequence);
    --
    return o;
  end property;

  --
  member function add_constraint(p_type           varchar2 default null,
                                 p_rel_table_name varchar2 default null,
                                 p_rel_type       varchar2 default null)
    return xxdoo_db_column_tmp is
    o xxdoo_db_column_tmp;
  begin
    o := self;
    o.constraints_tmp.extend;
    o.constraints_tmp(o.constraints_tmp.count) := xxdoo_db_constraint(p_type           => p_type,
                                                                      p_rel_table_name => p_rel_table_name,
                                                                      p_rel_type       => p_rel_type);
    --
    return o;
  end add_constraint;

  --
  member function constraint_property(p_rel_type     varchar2 default null,
                                      p_collect_name varchar2 default null,
                                      p_update_rule  varchar2 default null,
                                      p_delete_rule  varchar2 default null)
    return xxdoo_db_column_tmp is
    o xxdoo_db_column_tmp;
  begin
    o := self;
    o.constraints_tmp(o.constraints_tmp.count).property(p_rel_type         => p_rel_type,
                                                        p_rel_collect_name => p_collect_name,
                                                        p_delete_rule      => p_delete_rule,
                                                        p_update_rule      => p_update_rule);
    return o;
  end constraint_property;

  --
  member function cvarchar(p_length number) return xxdoo_db_column_tmp is
  begin
    return property(p_type   => 'varchar2',
                    p_length => p_length);
  end;

  --
  member function cint return xxdoo_db_column_tmp is
  begin
    return property(p_type => 'integer');
  end;

  --
  member function cnumber(p_length number default null,
                          p_scale  number default null)
    return xxdoo_db_column_tmp is
  begin
    return property(p_type   => 'number',
                    p_length => p_length,
                    p_scale  => p_scale);
  end;

  --
  member function cdate return xxdoo_db_column_tmp is
  begin
    return property(p_type => 'date');
  end;

  --
  member function ctimestamp return xxdoo_db_column_tmp is
  begin
    return property(p_type => 'timestamp');
  end;

  --
  member function cclob return xxdoo_db_column_tmp is
  begin
    return property(p_type => 'clob');
  end;

  --
  member function csequence return xxdoo_db_column_tmp is
  begin
    if nvl(self.type,'NULL') not in ('INTEGER','NUMBER') then
      xxdoo_db_utils_pkg.fix_exception('Column has discrard type ('||self.type||'). Assign sequence impossible.');
      raise apps.fnd_api.g_exc_error;
    end if;
    return property(p_sequence => 'Y');
  end;

  --
  member function cdefault(p_value varchar2) return xxdoo_db_column_tmp is
  begin
    return property(p_default_value => p_value);
  end;

  --
  member function notnull return xxdoo_db_column_tmp is
  begin
    return property(p_nullable => 'N');--.add_constraint(p_type => 'C');
  end;

  --
  member function indexed return xxdoo_db_column_tmp is
  begin
    return property(p_indexed => 'Y');
  end;

  --
  member function cunique return xxdoo_db_column_tmp is
  begin
    return add_constraint(p_type => 'U').property(p_is_unique => 'Y');
  end;

  --
  member function pk return xxdoo_db_column_tmp is
  begin
    return add_constraint(p_type => 'P').notnull;
  end;

  --
  member function tables(p_name varchar2) return xxdoo_db_column_tmp is
  begin
    return add_constraint(p_type           => 'R',
                          p_rel_table_name => p_name,
                          p_rel_type       => 'OBJECT'); --l_self.r(p_type => 'OBJECT', p_target_entity => p_name);
  end;

  --
  member function self return xxdoo_db_column_tmp is
  begin
    return add_constraint(p_type           => 'R',
                          p_rel_table_name => '#self',
                          p_rel_type       => 'OBJECT');
  end;

  --
  member function referenced(p_value varchar2) return xxdoo_db_column_tmp is
  begin
    return constraint_property(p_rel_type => 'COLLECTION', p_collect_name => p_value);
  end;

  --
  member function fk return xxdoo_db_column_tmp is
  begin
    return constraint_property(p_rel_type => 'FK');
  end;

  --
  member function changed(p_value varchar2) return xxdoo_db_column_tmp is
  begin
    return constraint_property(p_update_rule => p_value,
                               p_delete_rule => p_value);
  end;

  --
  member function updated(p_value varchar2) return xxdoo_db_column_tmp is
  begin
    return constraint_property(p_update_rule => p_value);
  end;

  --
  member function deleted(p_value varchar2) return xxdoo_db_column_tmp is
  begin
    return constraint_property(p_delete_rule => p_value);
  end;

  --
end;
/
