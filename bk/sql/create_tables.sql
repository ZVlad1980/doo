declare
  --
  g_owner varchar2(15) := 'xxdoo';
  --
  procedure plog(p_msg in varchar2, p_eof in boolean default true) is
  begin
    if p_eof = true then
      dbms_output.put_line(p_msg);
    else
      dbms_output.put(p_msg);
    end if;
  end;
  --
  procedure ei(p_body  in varchar2 default null) is
    l_object_exists_exc exception;
    pragma exception_init(l_object_exists_exc, -955);
    l_element_exists_exc exception;
    pragma exception_init(l_element_exists_exc, -1430);
    l_element_exists2_exc exception;
    pragma exception_init(l_element_exists2_exc, -1442);
    l_element_exists3_exc exception; --дубирование элементов в типе
    pragma exception_init(l_element_exists3_exc, -22324);
    l_element_exists4_exc exception; --дубирование элементов в типе
    pragma exception_init(l_element_exists4_exc, -1430);
    --
  begin
    --plog(p_operation||' '||p_type||' '||p_name||' ... ');
    execute immediate p_body;
    --plog('Ok',true);
  exception
    when l_element_exists_exc or l_object_exists_exc or l_element_exists_exc or l_element_exists2_exc or l_element_exists3_exc or l_element_exists4_exc then
      null;--plog('exist',true);
    when others then
      plog('error: '||sqlerrm);
      plog(p_body);
      raise;
  end;
  --
begin
  dbms_output.enable(100000);  --
  /*ei(p_body => 
'create table XXDOO.XXDOO_BK_STATESBOOK_T (
  id varchar2(8)  NOT NULL  ,
  constraint xxdoo_bk_statesBook_pk primary key(id)
)
'
  );--*/
  --
  ei(p_body => 
'create table XXDOO.XXDOO_BK_LOGS_T (
  creation_date timestamp,
  book_name     varchar2(15), 
  query         varchar2(1024),
  path          varchar2(1024), 
  inputs        clob, 
  meta          varchar2(4000)
)');
  --
  ei(p_body => 
'create table XXDOO.XXDOO_BK_METHODS_T (
  id         number  NOT NULL,
  book_id    number,
  version    integer,
  owner      varchar2(32),
  name       varchar2(30),
  package    varchar2(32),
  spc        varchar2(4000)  ,
  body       clob    ,
  constraint xxdoo_bk_methods_pk primary key(id)
)
'
  );
  --
  ei(p_body => 
'create table XXDOO.XXDOO_BK_SERVICES_T (
  id number  not null,
  name varchar2(20)  not null,
  namespace varchar2(400),
  method_id number    ,
  url       varchar2(400),
  is_default varchar2(1),
  constraint xxdoo_bk_services_pk primary key(id),
  constraint xxdoo_bk_services_fk1 foreign key(method_id) references XXDOO.XXDOO_BK_METHODS_T(id)
)');
  --
  ei(p_body => 
'create table XXDOO.XXDOO_BK_BOOKS_T (
  id number  NOT NULL,
  version    integer,
  name varchar2(15)  NOT NULL,
  owner varchar2(15)  ,
  dev_code varchar2(10)  ,
  title varchar2(200)  ,
  search varchar2(200)  ,
  service number  ,
  state varchar2(8)  ,
  created_date date  default SYSDATE NOT NULL,
  entity_id      number,
  package_id     number,
  home_page      varchar2(45),
  path           varchar2(1024),
  constraint xxdoo_bk_books_pk primary key(id),
  constraint xxdoo_bk_books_fk2 foreign key(service) references XXDOO.XXDOO_BK_SERVICES_T(id),
  constraint xxdoo_bk_books_fk4 foreign key(package_id) references XXDOO.XXDOO_BK_METHODS_T(id)
)
'
  );
  --
  ei(p_body => 
'create table XXDOO.XXDOO_BK_REGIONS_T (
  id number,
  book_id number,
  name varchar2(45),
  build_method_id number,
  html_method_id number,
  constraint xxdoo_bk_regions_pk  primary key(id),
  constraint xxdoo_bk_regions_fk  foreign key(book_id) references XXDOO.XXDOO_BK_BOOKS_T(id) on delete cascade,
  constraint xxdoo_bk_regions_fk2 foreign key(build_method_id) references XXDOO.XXDOO_BK_METHODS_T(id) on delete cascade,
  constraint xxdoo_bk_regions_fk3 foreign key(html_method_id) references XXDOO.XXDOO_BK_METHODS_T(id) on delete cascade
)
');
  --
  ei(p_body => 
'create table XXDOO.XXDOO_BK_RESOURCES_T (
  id number  NOT NULL,
  book_id number  ,
  name varchar2(45)  ,
  value varchar2(400)    ,
  constraint xxdoo_bk_resources_pk primary key(id),
  constraint xxdoo_bk_resources_fk2 foreign key(book_id) references XXDOO.XXDOO_BK_BOOKS_T(id) on delete cascade
)
');
  --
  ei(p_body => 
'create table XXDOO.XXDOO_BK_ROLES_T (
  id number  NOT NULL,
  book_id number  ,
  name varchar2(45)  NOT NULL,
  method_id number    ,
  constraint xxdoo_bk_roles_pk primary key(id),
  constraint xxdoo_bk_roles_fk2 foreign key(book_id) references XXDOO.XXDOO_BK_BOOKS_T(id) on delete cascade,
  constraint xxdoo_bk_roles_fk4 foreign key(method_id) references XXDOO.XXDOO_BK_METHODS_T(id)
)');
  --
  ei(p_body => 
'create table XXDOO.XXDOO_BK_ROLE_PARAMS_T (
  role_id number  ,
  key     varchar2(200),
  value   anydata    ,
  constraint xxdoo_bk_role_params_pk primary key(role_id, key),
  constraint xxdoo_bk_role_params_fk foreign key(role_id) references XXDOO.XXDOO_BK_ROLES_T(id) on delete cascade
)');

  --
  ei(p_body => 
'create table XXDOO.XXDOO_BK_PAGES_T (
  id number  NOT NULL,
  book_id number  ,
  name varchar2(45)  NOT NULL,
  content_method_id number    ,
  entity_id number,
  prepare_method_id number,
  constraint xxdoo_bk_pages_pk  primary key(id),
  constraint xxdoo_bk_pages_fk  foreign key(book_id) references XXDOO.XXDOO_BK_BOOKS_T(id) on delete cascade,
  constraint xxdoo_bk_pages_fk2 foreign key(content_method_id) references XXDOO.XXDOO_BK_METHODS_T(id),
  constraint xxdoo_bk_pages_fk4 foreign key(prepare_method_id) references XXDOO.XXDOO_BK_METHODS_T(id)
)
'
  );
  --
  ei(p_body => 
'create table XXDOO.XXDOO_BK_ROLE_PAGES_T (
  id number  NOT NULL,
  role_id number  ,
  page_id number  ,
  condition_method_id number,
  order_num number,
  constraint xxdoo_bk_role_pages_pk primary key(id),
  constraint xxdoo_bk_role_pages_fk2 foreign key(role_id) references XXDOO.XXDOO_BK_ROLES_T(id) on delete cascade,
  constraint xxdoo_bk_role_pages_fk3 foreign key(page_id) references XXDOO.XXDOO_BK_PAGES_T(id),
  constraint xxdoo_bk_role_pages_fk4 foreign key(condition_method_id) references XXDOO.XXDOO_BK_METHODS_T(id)
)
');
  --
  ei(p_body => 
'create table XXDOO.XXDOO_BK_CALLBACKS_T (
  id        varchar2(32)  NOT NULL,
  book_id   number,
  method_id number,
  constraint xxdoo_bk_callbacks_pk primary key(id),
  constraint xxdoo_bk_callbacks_fk2 foreign key(book_id) references XXDOO.XXDOO_BK_BOOKS_T(id) on delete cascade,
  constraint xxdoo_bk_callbacks_fk6 foreign key(method_id) references XXDOO.XXDOO_BK_METHODS_T(id)
)
'
  );  
  --
  ei(p_body => 
'create table XXDOO.xxdoo_bk_templates_t (
  id        number  NOT NULL,
  book_id   number  ,
  name      varchar2(200),
  entity_id number,
  method_id number,
  source    varchar2(100),
  constraint xxdoo_bk_templates_pk primary key(id),
  constraint xxdoo_bk_templates_fk1 foreign key(book_id) references XXDOO.XXDOO_BK_BOOKS_T(id) on delete cascade,
  constraint xxdoo_bk_templates_fk2 foreign key(method_id) references XXDOO.XXDOO_BK_METHODS_T(id)
)'
  );
  --
  ei(p_body => 
'create index xxdoo.xxdoo_bk_template_n1 on XXDOO.xxdoo_bk_templates_t(book_id)'
  );
  --
  ei(p_body => 
'create index xxdoo.xxdoo_bk_regions_n1 on XXDOO.XXDOO_BK_REGIONS_T(name)'
  );
  --
  ei(p_body => 
'create index xxdoo.xxdoo_bk_methods_n1 on XXDOO.XXDOO_BK_METHODS_T(name)'
  );
  --
  ei(p_body => 
'create index xxdoo.xxdoo_bk_services_n1 on XXDOO.XXDOO_BK_SERVICES_T(name)'
  );
  --
  ei(p_body => 
'create index xxdoo.xxdoo_bk_books_n1 on XXDOO.XXDOO_BK_BOOKS_T(name)'
  );
  --
  ei(p_body => 
'create sequence xxdoo.xxdoo_bk_methods_seq start with 1 nocache
'
  );
  --
  ei(p_body => 
'create sequence xxdoo.xxdoo_bk_services_seq start with 1 nocache
'
  );
  --
  ei(p_body => 
'create sequence xxdoo.xxdoo_bk_books_seq start with 1 nocache
'
  );
  --
  ei(p_body => 
'create sequence xxdoo.xxdoo_bk_objects_seq start with 1 nocache
'
  );
  --
  ei(p_body => 
'create sequence xxdoo.xxdoo_bk_roles_seq start with 1 nocache
'
  );
  --
  ei(p_body => 
'create sequence xxdoo.xxdoo_bk_pages_seq start with 1 nocache
'
  );
  --
  ei(p_body => 
'create sequence xxdoo.xxdoo_bk_role_pages_seq start with 1 nocache
'
  );
  --
  ei(p_body => 
'create sequence xxdoo.xxdoo_bk_callbacks_seq start with 1 nocache
'
  );
  --
  ei(p_body => 
'create sequence xxdoo.xxdoo_bk_resources_seq start with 1 nocache
'
  );
  --
  ei(p_body => 
'create sequence xxdoo.xxdoo_bk_regions_seq start with 1 nocache
'
  );
  --
  ei(p_body => 
'create sequence xxdoo.xxdoo_bk_templates_seq start with 1 nocache
'
  );
  --
end;
/
