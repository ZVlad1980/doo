with json as
 (select '{"q"=>"s", "from"=>0, "to"=>50}' json from dual)
select t.name,
       t.value --,
from   json j,
       table(xxdoo_json_pkg.parse_json(replace(replace(j.json, '=>', ':'), ', ', ','))) t
