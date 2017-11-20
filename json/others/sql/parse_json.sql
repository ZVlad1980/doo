--{"path":"#ALL/New","meta":null,"inputs":{"contractor.name":"test","test_array":[{"test1":"\"{[]}\""},{"test2":"value2"}]},"params":{"contractor2.name":"test2","test_array2":[{"test3":"\"{[]}\""},{"test4":"value2"}]}}
select *
from   table(xxdoo_json_pkg.parse_json('&str'))
