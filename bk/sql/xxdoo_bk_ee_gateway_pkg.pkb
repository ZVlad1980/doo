create or replace package body xxdoo_bk_ee_gateway_pkg is
  -- Private type declarations
  --
  function "request"("book_name" varchar2, "path" varchar2, "inputs" clob, "meta" clob) return xxapps.xxapps_service_raw_block is
    l_result       xxdoo.xxdoo_bk_service_raw_typ;
    l_body         clob;
    l_params       sys.odciVarchar2List;
  begin
    --
    /*l_result := xxdoo.xxdoo_bk_core_pkg.request(
      p_book_name => "book_name",
      p_query     => "path",
      p_path      => SYS_CONTEXT('CLIENTCONTEXT','SERVICE_TAILURI'),
      p_inputs    => replace(replace("inputs",'=>',':'),', ',','),
      p_meta      => replace(replace("meta",'=>',':'),', ',',')
    );
    --
    return xxapps.xxapps_service_raw_block(
      l_result.clob_value,
      l_result.blob_value,
      l_result.is_blob, 
      l_result.file_name, 
      l_result.mime_type, 
      l_result.is_error
    );*/
    dbms_lob.createtemporary(l_body,true);
    dbms_lob.append(l_body,'{"path":"'||"path"||'","inputs":"'||replace(replace("inputs",'=>',':'),', ',',')||'","meta":"'||replace(replace("meta",'=>',':'),', ',',')||'"}');
    l_params  :=  sys.odciVarchar2List();
    l_params.extend(4);
    l_params(1) := '';
    l_params(2) := SYS_CONTEXT('CLIENTCONTEXT','SERVICE_TAILURI');
    l_params(3) := '';
    l_params(4) := '';
    
    return "request"("book_name"=>"book_name", "request_body" => l_body, "request_params" => l_params);
    --
  end "request";
  -- Private type declarations
  --
  function "request"("book_name" varchar2, "request_body" clob, "request_params" in sys.odciVarchar2List) return xxapps.xxapps_service_raw_block is
    l_result       xxdoo.xxdoo_bk_service_raw_typ;
  begin
    --
    l_result := xxdoo.xxdoo_bk_core_pkg.request(
      p_book_name      => "book_name",
      p_request_body   => "request_body",
      p_request_params => "request_params"
    );
    --
    return xxapps.xxapps_service_raw_block(
      l_result.clob_value,
      l_result.blob_value,
      l_result.is_blob, 
      l_result.file_name, 
      l_result.mime_type, 
      l_result.is_error
    );
    --
  end "request";
  --
  --
  --
  procedure create_db_object(p_ddl varchar2) is
  begin
    execute immediate p_ddl;
  end;
  --
end xxdoo_bk_ee_gateway_pkg;
/
