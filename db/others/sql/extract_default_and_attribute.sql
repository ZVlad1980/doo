with xmlinfo as (
select xmltype('<content>
  <id>1</id>
  <name>Lenovo2</name>
  <type format="YYYY-MM-DD">Vendor</type>
  <site1>
    <id>1</id>
  </site1>
</content>
') xmlinfo
from dual
)
--
select xx.*,
       case xx.name
         when chr(0) then
           t2.name
         else
           xx.name
       end name2,
       case xx.type 
         when chr(0) then
           'NULL'
         else
           xx.type
       end type2,
       case 
         when xx.sites is null then
           xmltype('<A>Default</A>')
         else
           sites
       end sites2,
       case
         when xx.site is null then
           xmltype('<id>none</id>')
         else
           xx.site
       end site2
from xmlinfo x,
     xmltable('/content' passing(x.xmlinfo)
       columns
           id number path 'id',
           name varchar2(100) path 'name' default chr(0),
           type varchar2(100) path 'type' default chr(0),
           f#type varchar2(12) path 'type/./@format',
           site xmltype path 'site',
           sites xmltype path 'sites') xx,
    xxdoo_cntr_contractors_t t2
where 1=1
  and   t2.id(+) = xx.id
