declare
  c_company_id number := 123;
  --
  l_dummy number;
  l_cnt   number;
  --
  cursor l_cust_cur(p_company_id number) is
    select c.cust_account_id customer_id
    from   hz_cust_accounts c
    where  c.status = 'A'
    and    c.ORG_ID = p_company_id;
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
             case su.site_use_code
               when 'BILL_TO' then
                 'Bill to'
               else
                 'Ship to'
             end site_use_code, 
             case su.status
               when 'A' then
                 'Yes'
               else
                 'No'
             end active,
             case su.primary_flag 
               when 'Y' then
                 'Yes'
               else
                 'No'
             end primary
      from   hz_site_uses_v su
      where  address_id = p_address_id;
  --
  cursor l_bank_acc_cur(p_site_use_id number) is
    select ba.bank_account_id,
           ba.bank_branch_id,
           ba.bank_account_name,
           ba.bank_account_num,
           ba.currency_code,
           b.bank_branch_name,
           bau.bank_account_uses_id,
           bau.customer_site_use_id
    from   ap_bank_account_uses_all bau,
           ap_bank_accounts_all     ba,
           ap_bank_branches         b
    where  1=1
    and    b.bank_branch_id = ba.bank_branch_id
    and    ba.bank_account_id = bau.external_bank_account_id
    and    bau.customer_site_use_id = p_site_use_id;
  --
  --
  --
  procedure add_accounts(au l_bank_acc_cur%rowtype) is
  begin
    begin
      select 1
      into   l_dummy
      from   xxdoo.xxdoo_cntr_bank_branches_t c
      where  c.id = au.bank_branch_id;
    exception
      when no_data_found then
        insert into xxdoo.xxdoo_cntr_bank_branches_t(id, name)
          values(au.bank_branch_id, au.bank_branch_name);
    end;
    --
    if au.currency_code is not null then
      begin
        select 1
        into   l_dummy
        from   xxdoo.xxdoo_cntr_currencies_t c
        where  c.id = au.currency_code;
      exception
        when no_data_found then
          insert into xxdoo.xxdoo_cntr_currencies_t(id)
            values(au.currency_code);
      end;
    end if;
    --
    begin
      select 1
      into   l_dummy
      from   xxdoo.xxdoo_cntr_bank_accounts_t c
      where  c.id = au.bank_account_id;
    exception
      when no_data_found then
        insert into xxdoo.xxdoo_cntr_bank_accounts_t(id, bank_branch_id, name, acc_number, currency, currency_sec)
          values(au.bank_account_id,au.bank_branch_id,au.bank_account_name,au.bank_account_num, au.currency_code, au.currency_code);
    end;
    --
    begin
      select 1
      into   l_dummy
      from   xxdoo.xxdoo_cntr_bank_acc_uses_t c
      where  c.id = au.bank_account_uses_id;
    exception
      when no_data_found then
        insert into xxdoo.xxdoo_cntr_bank_acc_uses_t(id, bank_account, site_use_id)
          values(au.bank_account_uses_id,au.bank_account_id,au.customer_site_use_id);
    end;
  end;
  --
  procedure add_site_uses(su l_site_usus_cur%rowtype) is
  begin
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
    for au in l_bank_acc_cur(su.site_use_id) loop
      add_accounts(au);
    end loop;
  end;
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
      insert into xxdoo.xxdoo_cntr_addresses_t(id, country, postal_code, city, addr_line)
        values(a.address_id, a.country , a.postal_code , a.city, a.address1);
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
          select ca.cust_account_id customer_id,
                 ca.account_number customer_number,
                 p.party_name customer_name,
                 p.organization_name_phonetic customer_name_phonetic,
                 case p.attribute1
                   when '¿‘‘»À»–Œ¬¿ÕÕŒ≈ À»÷Œ' then
                    'A'
                   when '¿‘‘»À»–Œ¬¿ÕÕŒ≈ À»÷Œ, ¬’Œƒ»“ ¬ ’ŒÀƒ»Õ√ ≈¬–Œ’»Ã' then
                    'H'
                   else
                    'N'
                 end category,
                 p.attribute16 type,
                 case
                   when p.attribute2 like 'ÕÂ%' then
                    'No'
                   else
                    'Yes'
                 end resident,
                 p.tax_reference,
                 null
          from   hz_parties       p,
                 hz_cust_accounts ca
          where  ca.party_id = p.party_id
          and    ca.cust_account_id = p_cust_account_id
          and    rownum = 1;
    end;
    --
    add_sites(p_cust_account_id);
    --
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
                 when '¿‘‘»À»–Œ¬¿ÕÕŒ≈ À»÷Œ' then
                   'A'
                 when '¿‘‘»À»–Œ¬¿ÕÕŒ≈ À»÷Œ, ¬’Œƒ»“ ¬ ’ŒÀƒ»Õ√ ≈¬–Œ’»Ã' then
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
  xxsl_a001_gateway_pkg.apps_initialize('AR',c_company_id);
  fill_cntr_types;
  fill_cntr_cat;
  l_cnt := 0;
  for c in l_cust_cur(c_company_id) loop
    add_contractor(c.customer_id);
    l_cnt := l_cnt + 1;
    if l_cnt = 100 then
      l_cnt := 0;
      commit;
      exit;
    end if;
  end loop;
  --
  commit;
end;
/
