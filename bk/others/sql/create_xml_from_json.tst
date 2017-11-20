PL/SQL Developer Test script 3.0
118
-- Created on 13.10.2014 by ZHURAVOV_VB 
declare 
  -- Local variables here
  cursor l_parse_cur is
    with t_data as (
      select t.id, t.parent_id, t.name, t.type, t.value,
             row_number()over(partition by t.name order by t.id) rnum
      from   table(xxdoo.xxdoo_json_pkg.parse_json(
      '{"contractor.name":"test",'||
      '"contractor.sites.site.id":null,'||
      '"contractor.sites.site.site_number":"1",'||
      '"contractor.sites.site.phones":[66,88,77],'||
      '"contractor.sites.site.tax_reference":"12345",'||
      '"contractor.sites.site.id":null,'||
      '"contractor.sites.site.site_number":"2",'||
      '"contractor.sites.site.phones":[66,88,77],'||
      '"contractor.sites.site.tax_reference":"56789",'||
      '"contractor.category.name":"vendor"}'
      )) t
      where  1=1
      order by t.id
    ), 
    t_parse as (
      select 0 lvl, 0 id, null parent_id, 'U' type, 0 atom, null parent, 'contractor' name, null         value, 1 rnum
      from dual
      union all
      select level lvl, t.id, t.parent_id, t.type, 
             case t.type
               when 'A' then 0
               else CONNECT_BY_ISLEAF 
             end atom,
             regexp_substr(t.name,'[^.]+',1,level) parent, 
             regexp_substr(t.name,'[^.]+',1,level+1) name,
             t.value,
             row_number()over(partition by sys_connect_by_path(regexp_substr(t.name,'[^.]+',1,level+1),'.') order by t.id) rnum
      from   t_data t
      where  1=1
      connect by prior id = id 
             and prior dbms_random.value is not null
             and level <= regexp_count(name,'[.]+')
    ),
    t_analit as (
      select p.lvl, 
             p.id, 
             p.type, 
             p.atom, 
             p.name, 
             case p.atom
               when 1 then
                 p.value
             end value,
             rnum,
             lag(rnum,1,99)over(order by id, lvl)rnum_prior
      from   t_parse p
    )
    select a.lvl,
           a.atom,
           a.name,
           a.value 
    from   t_analit a
    where  (a.rnum = 1 or (a.rnum < a.rnum_prior))
    and    a.type <> 'A'
    order by a.id, a.lvl;
  --
  type l_parent_nodes_typ is table of varchar2(1024) index by pls_integer;
  l_parent_nodes l_parent_nodes_typ;
  --
  s xxdoo.xxdoo_db_select;
  t xxdoo.xxdoo_db_text;
  l_level_prior number;
  l_atom_prior number;
  x xmltype;
begin
  s := xxdoo.xxdoo_db_select();
  t := xxdoo.xxdoo_db_text();
  t.append('xmlroot(');
  t.inc;
  l_level_prior := 0;
  l_atom_prior  := -1;
  -- Test statements here
  for e in l_parse_cur loop
    
    if l_level_prior > e.lvl then
      t.append(rpad(')',l_level_prior - e.lvl,')'),false);
      t.dec(l_level_prior - e.lvl);
    elsif l_level_prior < e.lvl then
      t.inc(e.lvl - l_level_prior);
    end if;
    --
    if l_atom_prior = 1 then
      t.append(',');
    elsif e.lvl > 1 then 
      t.append(null); 
    end if;
    --
    l_level_prior := e.lvl;
    l_atom_prior  := e.atom;
    t.append('xmlelement("'||e.name||'",',false);
    --
    if e.atom = 1 then
      t.append(''''||e.value||''')',false);
    end if;
    --
  end loop;
  --
  t.append(rpad(')',l_level_prior-1,')')||',');
  t.dec(l_level_prior);
  t.append('version 1.0)');
  dbms_output.put_line(t.get_text);
  --
  s.s(t, 'xml_info');
  s.f('dual');
  --
  dbms_output.put_line(s.build);
  return;
  execute immediate s.build into x;
  dbms_output.put_line(x.getStringVal);  --*/
end;
0
0
