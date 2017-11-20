create or replace package xxdoo_bk_engine_pkg is

  -- Author  : ZHURAVOV_VB
  -- Created : 15.08.2014 20:27:20
  -- Purpose : 
  --
  --
  cursor g_methods_cur(p_book xxdoo_bk_book_typ) is
    select c.method.id      id,
           c.method.name    name,
           c.method.spc     spc,
           c.method.body    body,
           c.method.owner   owner,
           c.method.package package
    from   table(p_book.callbacks) c
    union all
    select p_book.service.method.id      id, 
           p_book.service.method.name    name, 
           p_book.service.method.spc     spc, 
           p_book.service.method.body    body ,
           p_book.service.method.owner   owner,
           p_book.service.method.package package
    from   dual
    union all
    select p.content_method.id id, 
           p.content_method.name name, 
           p.content_method.spc spc, 
           p.content_method.body body,
           p.content_method.owner owner,
           p.content_method.package package
    from   table(p_book.pages) p
    union all
    select p_book.package.id id, 
           p_book.package.name name, 
           p_book.package.spc spc, 
           p_book.package.body body,
           p_book.package.owner owner,
           p_book.package.package package
    from   dual
    union all
    select r.html_method.id   id, 
           r.html_method.name name, 
           r.html_method.spc  spc, 
           r.html_method.body body,
           r.html_method.owner owner,
           r.html_method.package package
    from   table(p_book.regions) r
    union all
    select r.build_method.id   id, 
           r.build_method.name name, 
           r.build_method.spc  spc, 
           r.build_method.body body,
           r.build_method.owner owner,
           r.build_method.package package
    from   table(p_book.regions) r
    union all
    select p.condition_method.id   id, 
           p.condition_method.name name, 
           p.condition_method.spc  spc, 
           p.condition_method.body body,
           p.condition_method.owner owner,
           p.condition_method.package package
    from   table(p_book.roles) r,
           table(r.pages) p
    union all
    select r.method.id   id, 
           r.method.name name, 
           r.method.spc  spc, 
           r.method.body body,
           r.method.owner owner,
           r.method.package package
    from   table(p_book.roles) r
    where  r.method.id is not null
    union all
    select p.prepare_method.id   id, 
           p.prepare_method.name name, 
           p.prepare_method.spc  spc, 
           p.prepare_method.body body,
           p.prepare_method.owner owner,
           p.prepare_method.package package
    from   table(p_book.pages) p
    union all
    select t.method.id   id, 
           t.method.name name, 
           t.method.spc  spc, 
           t.method.body body,
           t.method.owner owner,
           t.method.package package
    from   table(p_book.templates) t
    where  t.method.id is not null;
  --
  --
  --
  type g_methods_typ is table of g_methods_cur%rowtype;
  --
  function get_methods return g_methods_typ pipelined;
  --
  --
  procedure init_role_pages(p_role_name varchar2);
  --
  function get_role_page_position(p_role_name varchar2, p_page_name varchar2) return number;
  --
  procedure put(p_book in out nocopy xxdoo_bk_book_typ);
  --
  function get_entity_id(p_scheme varchar2, p_entry varchar2) return number;
  --
  procedure generate_book(p_book in out nocopy xxdoo_bk_book_typ);
  --
end xxdoo_bk_engine_pkg;
/
