PL/SQL Developer Test script 3.0
199
declare
  l_dummy number;
  --
  cursor l_cust_cur is
    select distinct sh.customer_id
    from   xxsl.xxsl_dc_events_t     e,
           xxsl.xxsl_dc_so_headers_t sh
    where  1=1
    and    sh.event_id = e.event_id
    and    e.creation_date > sysdate - 10
    and    e.company_code = 'DEEAG';
  --
  cursor l_site_cur(p_customer_id number) is
    select c.address_id,c.site_number,c.address2 tax_reference, c.address2 tax_payer_id,
           c.COUNTRY,c.POSTAL_CODE,c.CITY,c.ADDRESS1
    from   ar_addresses_v c
    where  c.customer_id = p_customer_id;
  --
  cursor l_site_usus_cur(p_address_id number) is
      select su.site_use_id,
             su.address_id,
             su.site_use_code, 
             case su.status
               when 'A' then
                 'Y'
               else
                 'N'
             end active,
             su.primary_flag primary
      from   hz_site_uses_v su
      where  address_id = p_address_id;
  --
  --
  --
  procedure add_country(p_country varchar2) is
  begin
    select 1
    into   l_dummy
    from   xxdoo.xxdoo_cntr_countries_t c
    where  c.id = p_country;
  exception
    when no_data_found then
      insert into xxdoo.xxdoo_cntr_countries_t(id, name, description, iso_code)
        select t.territory_code, t.territory_short_name , t.description , t.iso_territory_code
        from   fnd_territories_vl t
        where  t.TERRITORY_CODE = p_country;
  end;
  --*/
  procedure add_address(a l_site_cur%rowtype) is
  begin
    add_country(a.country);
    --
    select 1
    into   l_dummy
    from   xxdoo.xxdoo_cntr_addresses_t c
    where  c.id = a.address_id;
  exception
    when no_data_found then
      insert into xxdoo.xxdoo_cntr_addresses_t(id, country, postal_code, town, addr_line)
        values(a.address_id, a.country , a.postal_code , a.city, a.address1);
  end;
  --
  procedure add_site_uses(su l_site_usus_cur%rowtype) is
  begin
    select 1
    into   l_dummy
    from   xxdoo.xxdoo_cntr_site_uses_t c
    where  c.id = su.site_use_id;
  exception
    when no_data_found then
      insert into xxdoo.xxdoo_cntr_site_uses_t(id, site_id, role, active, primary)
        values(su.site_use_id, su.address_id, su.site_use_code, su.active, su.primary);
  end;
  --
  procedure add_sites(p_cust_account_id number) is
    
    --
  begin
    for s in l_site_cur(p_cust_account_id) loop
      add_address(s);
      begin
        select 1
        into   l_dummy
        from   xxdoo.xxdoo_cntr_sites_t ss
        where  ss.id = s.address_id;
      exception
        when no_data_found then
          insert into xxdoo.xxdoo_cntr_sites_t(id, contractor_id, site_number, address_id, tax_reference, tax_payer_id)
            values(s.address_id, p_cust_account_id, s.site_number, s.address_id, s.tax_reference, s.tax_payer_id);
      end;
      for su in l_site_usus_cur(s.address_id) loop
        add_site_uses(su);
      end loop;
    end loop;
  end;
  --
  procedure add_contractor(p_cust_account_id number) is
    l_dummy number;
  begin
    begin
      select 1
      into   l_dummy
      from   xxdoo.xxdoo_cntr_contractors_t
      where  id = p_cust_account_id;
    exception
      when no_data_found then
        --
        insert into xxdoo.xxdoo_cntr_contractors_t(id,contr_number, name, name_alt, category, type, resident, tax_reference, tax_payer_id)
          select c.customer_id,
                 c.customer_number,
                 c.customer_name,
                 c.customer_name_phonetic,
                 case c.attribute1
                   when 'ÀÔÔÈËÈĞÎÂÀÍÍÎÅ ËÈÖÎ' then
                     'A'
                   when 'ÀÔÔÈËÈĞÎÂÀÍÍÎÅ ËÈÖÎ, ÂÕÎÄÈÒ Â ÕÎËÄÈÍÃ ÅÂĞÎÕÈÌ' then
                     'H'
                   else
                     'N'
                 end category,
                 c.attribute16 type,
                 case
                   when c.attribute2 like 'Íå%' then
                     'No'
                   else
                     'Yes'
                 end resident,
                 c.tax_reference,
                 c.taxpayer_id
          from   ar_customers_v c
          where  c.customer_id = p_cust_account_id
          and    rownum = 1;
    end;
    --
    add_sites(p_cust_account_id);
    --
  exception
    when others then
      null;
  end;
  --*/
  procedure fill_cntr_types is
    l_dummy number;
  begin
    select 1
    into   l_dummy
    from   xxdoo.xxdoo_cntr_types_t
    where  rownum = 1;
    --
    dbms_output.put_line('fill_cntr_types filled;');
  exception
    when no_data_found then
      insert into xxdoo.xxdoo_cntr_types_t(id, name)
        select v.flex_value_meaning id,
               v.description
        from   fnd_flex_value_sets s,
               fnd_flex_values_vl  v
        where  s.flex_value_set_name = 'XXBI_CUSTOMER_TYPE'
        and    v.flex_value_set_id = s.flex_value_set_id;
      dbms_output.put_line('fill_cntr_types inserted '||sql%rowcount||' rows');
  end;
  --
  procedure fill_cntr_cat is
    l_dummy number;
  begin
    select 1
    into   l_dummy
    from   xxdoo.xxdoo_cntr_categories_t
    where  rownum = 1;
    --
    dbms_output.put_line('fill_cntr_cat filled;');
  exception
    when no_data_found then
      insert into xxdoo.xxdoo_cntr_categories_t(id, name)
        select case v.flex_value_meaning 
                 when 'ÀÔÔÈËÈĞÎÂÀÍÍÎÅ ËÈÖÎ' then
                   'A'
                 when 'ÀÔÔÈËÈĞÎÂÀÍÍÎÅ ËÈÖÎ, ÂÕÎÄÈÒ Â ÕÎËÄÈÍÃ ÅÂĞÎÕÈÌ' then
                   'H'
                 else
                   'N'
               end name,
               v.flex_value_meaning description
        from   fnd_flex_value_sets s,
               fnd_flex_values_vl  v
        where  s.flex_value_set_name = 'XXGLA_CATEGORY'
        and    v.flex_value_set_id = s.flex_value_set_id;
      dbms_output.put_line('fill_cntr_cat inserted '||sql%rowcount||' rows');
  end;
begin 
  xxsl_a001_gateway_pkg.apps_initialize('AR',1407);
  fill_cntr_types;
  fill_cntr_cat;
  for c in l_cust_cur loop
    add_contractor(c.customer_id);
  end loop;
  --
  commit;
end;
0
0
