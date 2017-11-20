with xmlinfo as (
select xmltype('<content>
  <id>1</id>
  <name>Lenovo</name>
  <type>Vendor</type>
  <sites>
    <site>
      <id>1</id>
      <contractor_id>1</contractor_id>
      <role>ship to</role>
      <siteAccounts>
        <siteAccount>
          <id>1</id>
          <bankAccount>
            <id>1</id>
            <siteId>1</siteId>
            <accountNum>10101010101</accountNum>
          </bankAccount>
          <siteId>1</siteId>
        </siteAccount>
      </siteAccounts>
    </site>
    <site>
      <id>2</id>
      <contractor_id>1</contractor_id>
      <role>bill to</role>
      <address>
        <id>1</id>
        <postal_code>111111</postal_code>
        <addr_line>moscow</addr_line>
      </address>
      <accounts/>
    </site>
  </sites>
</content>
') xmlinfo
from dual
),
x as (
--
select xxdoo_cntr_contractor_typ(
        id => 
        nvl(xt1.id,t2.id),
        name => 
          case xt1.name
            when chr(0) then
              t2.name
            else
              xt1.name
          end,
        type => 
          case xt1.type
            when chr(0) then
              t2.type
            else
              xt1.type
          end,
        sites => 
          case
            when xt1.sites is null then
              cast(multiset(
                select value(t3)
                 from   xxdoo_CNTR_SITES_V t3
                 where  t3.contractor_id = t2.id)
                 as xxdoo_cntr_sites_typ)
            else
              cast(multiset(
                select xxdoo_cntr_site_typ(
                  id => 
                  nvl(xt4.id,t5.id),
                  contractor_id => t2.id,
                  role => 
                    case xt4.role
                      when chr(0) then
                        t5.role
                      else
                        xt4.role
                    end,
                  address => 
                    case
                      when xt4.address is null then
                        (select value(v7)
                         from   xxdoo_CNTR_ADDRESSES_V v7
                         where  v7.id = t5.address_id)
                      else
                        xxdoo_cntr_address_typ(
                          id => 
                          nvl(xt4.address_id,t6.id),
                          country => 
                            case
                              when xt4.country is null then
                                (select value(v9)
                                 from   xxdoo_CNTR_COUNTRIES_V v9
                                 where  v9.id = t6.country)
                              else
                                xxdoo_cntr_country_typ(
                                  id => 
                                    case xt4.country_id
                                      when chr(0) then
                                        t8.id
                                      else
                                        xt4.country_id
                                    end,
                                  name => 
                                    case xt4.country_name
                                      when chr(0) then
                                        t8.name
                                      else
                                        xt4.country_name
                                    end,
                                  localizedname => 
                                    case xt4.country_localizedName
                                      when chr(0) then
                                        t8.localizedname
                                      else
                                        xt4.country_localizedName
                                    end,
                                  union_countries => 
                                    case xt4.country_union_countries
                                      when chr(0) then
                                        t8.union_countries
                                      else
                                        xt4.country_union_countries
                                    end)
                            end,
                          postal_code => 
                            case xt4.address_postal_code
                              when chr(0) then
                                t6.postal_code
                              else
                                xt4.address_postal_code
                            end,
                          addr_line => 
                            case xt4.address_addr_line
                              when chr(0) then
                                t6.addr_line
                              else
                                xt4.address_addr_line
                            end)
                    end,
                  accounts => 
                    case
                      when xt4.accounts is null then
                        cast(multiset(
                          select value(t10)
                           from   xxdoo_CNTR_SITEACCOUNTS_V t10
                           where  t10.siteId = t5.id)
                           as xxdoo_cntr_siteaccounts_typ)
                      else
                        cast(multiset(
                          select xxdoo_cntr_siteaccount_typ(
                            id => 
                            nvl(xt11.id,t12.id),
                            bankaccount => 
                              case
                                when xt11.bankaccount is null then
                                  (select value(v14)
                                   from   xxdoo_CNTR_BANKACCOUNTS_V v14
                                   where  v14.id = t12.accountId)
                                else
                                  xxdoo_cntr_bankaccount_typ(
                                    id => 
                                    nvl(xt11.bankaccount_id,t13.id),
                                    siteid => 
                                    nvl(xt11.bankaccount_siteId,t13.siteid),
                                    accountnum => 
                                      case xt11.bankaccount_accountNum
                                        when chr(0) then
                                          t13.accountnum
                                        else
                                          xt11.bankaccount_accountNum
                                      end)
                              end,
                            siteid => t5.id)
                          from xmltable('/accounts/siteAccount' passing(xt4.accounts)
                                 columns
                                     id_f varchar2(100) path 'id/./@format',
                                     id varchar2(100) path 'id'default chr(0),
                                    bankaccount xmltype path 'bankaccount',
                                             bankaccount_id_f varchar2(100) path 'bankaccount/id/./@format',
                                             bankaccount_id varchar2(100) path 'bankaccount/id'default chr(0),
                                             bankaccount_siteId_f varchar2(100) path 'bankaccount/siteId/./@format',
                                             bankaccount_siteId varchar2(100) path 'bankaccount/siteId'default chr(0),
                                             bankaccount_accountNum varchar2(40) path 'bankaccount/accountNum'default chr(0),
                                     siteId_f varchar2(100) path 'siteId/./@format',
                                     siteId varchar2(100) path 'siteId'default chr(0)) xt11,
                              xxdoo_cntr_siteaccounts_t t12,
                                xxdoo_cntr_bankaccounts_t t13
                          where 1=1
                            and   t12.id(+) = 
                              case xt11.id
                                when chr(0) then
                                  null
                                else
                                  xt11.id
                              end
                                    and   t13.id(+) = 
                                      case xt11.bankaccount_id
                                        when chr(0) then
                                          null
                                        else
                                          xt11.bankaccount_id
                                      end
                        ) as xxdoo_cntr_siteaccounts_typ)
                      end
                  )
                from xmltable('/sites/site' passing(xt1.sites)
                       columns
                           id_f varchar2(100) path 'id/./@format',
                           id varchar2(100) path 'id'default chr(0),
                           contractor_id_f varchar2(100) path 'contractor_id/./@format',
                           contractor_id varchar2(100) path 'contractor_id'default chr(0),
                           role varchar2(7) path 'role'default chr(0),
                          address xmltype path 'address',
                                   address_id_f varchar2(100) path 'address/id/./@format',
                                   address_id varchar2(100) path 'address/id'default chr(0),
                                  country xmltype path 'address/country',
                                           country_id varchar2(2) path 'address/country/id'default chr(0),
                                           country_name varchar2(255) path 'address/country/name'default chr(0),
                                           country_localizedName varchar2(240) path 'address/country/localizedName'default chr(0),
                                           country_union_countries varchar2(15) path 'address/country/union_countries'default chr(0),
                                   address_postal_code varchar2(30) path 'address/postal_code'default chr(0),
                                   address_addr_line varchar2(150) path 'address/addr_line'default chr(0),
                           accounts xmltype path 'accounts') xt4,
                    xxdoo_cntr_sites_t t5,
                              xxdoo_cntr_countries_t t8,
                      xxdoo_cntr_addresses_t t6
                where 1=1
                  and   t5.id(+) = 
                    case xt4.id
                      when chr(0) then
                        null
                      else
                        xt4.id
                    end
                          and   t6.id(+) = 
                            case xt4.address_id
                              when chr(0) then
                                null
                              else
                                xt4.address_id
                            end
                                  and   t8.id(+) = 
                                    case xt4.country_id
                                      when chr(0) then
                                        null
                                      else
                                        xt4.country_id
                                    end
              ) as xxdoo_cntr_sites_typ)
            end
        ) x
      from xmlinfo x,
           xmltable('/content' passing(x.xmlinfo)
             columns
                 id_f varchar2(100) path 'id/./@format',
                 id varchar2(100) path 'id'default chr(0),
                 name varchar2(150) path 'name'default chr(0),
                 type varchar2(8) path 'type'default chr(0),
                 sites xmltype path 'sites') xt1,
          xxdoo_cntr_contractors_t t2
      where 1=1
        and   t2.id(+) = 
          case xt1.id
            when chr(0) then
              null
            else
              xt1.id
          end
--
)
select xmlroot(xmltype.createxml(x.x),version 1.0)
from   x.x

-- xmlinfo x,
-- xmltable('/content' passing(x.xmlinfo)
