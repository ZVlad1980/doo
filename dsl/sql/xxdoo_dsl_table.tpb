create or replace type body xxdoo_dsl_table is
  
  -- Member procedures and functions
  overriding member function get_type_name return varchar2 is
  begin 
    return upper('xxdoo_dsl_table');
  end;
  --
  --
  --
  constructor function xxdoo_dsl_table return self as result is
  begin
    self.head  := xxdoo_dsl_tbl_cell(xxdoo_html());
    self.cells := xxdoo_dsl_tbl_cell(xxdoo_html());
    return;
  end;
  --
  --
  --
  member function ccolumn(p_name      varchar2, 
                          p_content   xxdoo_html, 
                          p_tag       varchar2 default null, 
                          p_css       varchar2 default null) return xxdoo_dsl_table is
    l_new_object xxdoo_dsl_table := self;
  begin
    --
    l_new_object.h := xxdoo_html();
    l_new_object.head.h := l_new_object.head.h.h(
      l_new_object.h.h('th'||case when p_css is not null then '.'||p_css end, p_name)
    );
    --
    l_new_object.h.init;
    l_new_object.cells.h := l_new_object.cells.h.h(
      l_new_object.h.h(
          nvl(p_tag,'td')||case when p_css is not null then '.'||p_css end, 
          p_content
      )
    );
    --
    return l_new_object;
  end ccolumn;
  --
  --
  --
  member function ccolumn(p_name      varchar2, 
                          p_content   varchar2, 
                          p_tag       varchar2 default null, 
                          p_css       varchar2 default null) return xxdoo_dsl_table is
    l_new_object xxdoo_dsl_table := self;
  begin
    --
    l_new_object.h := xxdoo_html();
    l_new_object.head.h := l_new_object.head.h.h(
      l_new_object.h.h('th'||case when p_css is not null then '.'||p_css end, p_name)
    );
    --
    l_new_object.h.init;
    l_new_object.cells.h := l_new_object.cells.h.h(
      l_new_object.h.h(
          nvl(p_tag,'td')||case when p_css is not null then '.'||p_css end, 
          p_content
      )
    );
    --
    return l_new_object;
  end ccolumn;
  --
  --
  --
  member procedure ctable(
    p_caption     varchar2          default null, 
    p_when        varchar2          default null, 
    p_placeholder xxdoo_html        default null, 
    p_rows        xxdoo_dsl_tbl_row default null, 
    p_columns     xxdoo_dsl_table   default null,
    p_css         varchar2          default null) is
    --
    thead xxdoo_html;
    tbody xxdoo_html;
    --
  begin
    if p_rows.collection is null then
      self.h := xxdoo_html();
    else
      self.h := xxdoo_html(p_src_owner => p_rows.collection.owner, p_src_object => p_rows.collection.name);
    end if;
    thead := xxdoo_html();
    thead := thead.h('thead',thead.h('tr',p_columns.head.h));
    tbody := xxdoo_html();
    tbody := thead.h(tbody.h('tbody',tbody.each(p_rows.source, p_rows.h.h(p_columns.cells.h))));
    --
    if p_caption is not null then
      self.h := self.h.h('caption',p_caption);
    end if;
    --
    self.h := self.h.h('table'||case when p_css is not null then '.'||p_css end,self.h.h(tbody));
    --
    if p_placeholder is not null then 
      self.h := self.h.h(self.h.condition(self.h.G(case when p_rows.source is null then 'p_ctx' else p_rows.source end),
                  self.h, p_placeholder.h('div.empty', p_placeholder)));
    end if;
    --
    if p_when is not null then 
      self.h := self.h.when#(p_when, self.h);
    end if;
    --
    self.h := self.h.h('div.table',self.h);
  exception
    when others then
      xxdoo_utl_pkg.fix_exception;
      raise;
  end ctable;
  --
end;
/
