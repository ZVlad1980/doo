PL/SQL Developer Test script 3.0
986
-- Created on 11.07.2014 by ZHURAVOV_VB 
declare 
  -- Local variables here
  i integer;
  --t xxdoo.xxdoo_db_scheme_typ := xxdoo.xxdoo_db_scheme_typ(p_name => 'TEST', p_dev_code => 'test', p_owner => 'xxdoo');
  s xxdoo.xxdoo_db_scheme_typ := xxdoo.xxdoo_db_scheme_typ(p_name => 'Sale', p_dev_code => 'xxdoo_sale', p_owner => 'xxdoo');
  --f xxdoo.xxdoo_db_field_typ := xxdoo.xxdoo_db_field_typ();
  --
  function get_xml(s xxdoo.xxdoo_db_scheme_typ) return xmltype is
    l_result xmltype;
  begin
    select xmlroot(xmltype.createxml(s), version 1.0)
    into l_result
    from dual;
    --
    return l_result;
  end;
begin
  --dbms_session.reset_package;
  xxdoo.xxdoo_db_utils_pkg.init_exceptions;
  /*
  xxdoo.xxdoo_db_engine_pkg.drop_objects(s);
  return; --*/
  
  --
  s.ctable('priceModMthds', 'pertonnage percentage lumpsum');
  s.ctable('priceModTypes', 'Discount Surcharge Lump-Sum');
  s.ctable('measures/measure', 'st mt');
  s.ctable('currencies/currency', 'EUR USD CHF');
  s.ctable('salesModels', 'Direct Agent LRD Replenishment');
  s.ctable('incoterms/incoterms', 'EXW FCA DAF DAP FOB FAS CPT CIP CIF CFR DDU DDP');
  s.ctable('incotermsGroups/incotermsGroup', 'C,D-Terms E,F-Terms');
  s.ctable('partTypes', 'Deal Replenishment');
  s.ctable('siteTypes', 'Supply Transhipment Distribution Consignment');
  s.ctable('shuttleTypes', 'Rail Barge');
  s.ctable('shipmentTypes', 'Supply Replenishment Delivery');
  s.ctable('shipmentStates', 'Draft Requested Fixed CheckedIn Loaded Shipped Received Canceling Canceled Invoicing Invoiced');
  s.ctable('cmrRangeStates', 'Active Avaliable Depleted');
  s.ctable('docRangeStates', 'Active Avaliable Depleted');
  s.ctable('operationStates', 'Pending Processing Success Error');
  s.ctable('customerTypes', 'Company Consignee');
  s.ctable('priceAdjModes', 'Gross Subtotal');
  s.ctable('invoiceStates', 'Created Billed Paid Cancelled');
  s.ctable('invoiceTypes', 'Trader LRD Customer Carrier');
  s.ctable('priceInclusions', 'ecotassa 2% ex L. 388 assolta');
  s.ctable('spotFrgTypes', 'shipment mt container');
  --
  s.ctable('participantRols', 
           xxdoo.xxdoo_db_list_typ(
             'Dispatcher',
             'Loading Provider',
             'Surveyor',
             'Stevedores',
             'Reseller',
             'Bank Service Provider',
             'Shipping Agency',
             'Customs Agent',
             'Ship Broker',
             'Sales Representative'
           )
  );
  --
  s.ctable('dealStates', 
          xxdoo.xxdoo_db_list_typ(
            'Canceled',

            'Declined by SCM',
            'Declined by Sales',
            'Declined by Finance',

            'Draft',

            'Committed',

            'Approval by Sales-Finance-SCM',

            'Approval by Sales-Finance',
            'Approval by Finance-SCM',
            'Approval by Sales-SCM',

            'Approval by SCM',
            'Approval by Sales',
            'Approval by Finance',

            'Confirmed'
          )
  );

  s.ctable('opTransferTypes', 
          xxdoo.xxdoo_db_list_typ(
            'To Trader',
            'To LRD',
            'To Customer'
          )
  );

  s.ctable('custsClrTypes', 
          xxdoo.xxdoo_db_list_typ(
            'First EU',
            'DEEAG',
            'Customer'
          )
  );
  --
  s.ctable('people/person',
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',       s.cint().csequence().pk),
             s.f('name',     s.cvarchar(150).notNull),
             s.f('position', s.cvarchar(50)),
             s.f('login',    s.cvarchar(50).notNull().cunique),
             s.f('email',    s.cvarchar(150).notNull),
             s.f('role',     s.cvarchar(50).notNull),
             s.f('scopes',   s.cvarchar(200)),
             s.f('locale',   s.cvarchar(2).cdefault('en')),
             s.f('mobile',   s.cvarchar(20)),
             s.f('phone',    s.cvarchar(20)),
             s.f('fax',      s.cvarchar(20))
           )
  );
  --
  s.ctable('products', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',            s.cint().csequence().pk),
             s.f('CNCode',        s.cvarchar(10)),
             -- TODO,Add localized version of names
             s.f('name',          s.cvarchar(70).notNull),
             s.f('description',   s.text),
             s.f('dangerousNote', s.text)
           )
  );
  --
  s.ctable('packages', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',            s.cvarchar(2).pk),
             s.f('name',          s.cvarchar(50).notNull),
             s.f('localizedName', s.text),
             s.f('capacity',      s.cdecimal(10, 4))
           )
  );
  --
  s.ctable('items', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',             s.cvarchar(13).pk),
             s.f('product_id',     s.tables('products').updated('CASCADE')),
             s.f('package_id',     s.tables('packages').updated('CASCADE')),
             s.f('netToGrossRate', s.cdecimal(10,8).cdefault(1))
           )
  );
  --
  s.ctable('regions', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',   s.cvarchar(3).pk),
             s.f('name', s.cvarchar(100).notNull)
           )
  );
  --
  s.ctable('countries/country', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',            s.cvarchar(2).pk().notNull),
             s.f('name',          s.cvarchar(255).notNull),
             s.f('localizedName', s.text),
             s.f('union_countries',         s.cvarchar(15).indexed)
           )
  );
  --
  s.ctable('provinces', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',         s.cvarchar(5).pk),
             s.f('name',       s.cvarchar(100).notNull),
             s.f('code',       s.cvarchar(2).notNull),
             s.f('country_id', s.tables('countries').fk)
           ),
           xxdoo.xxdoo_db_indexes_typ(
             s.i(p_type => 'unique',
                 p_fields => 'code, country_id')
           )
  );
  --
  s.ctable('locations', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',         s.cvarchar(20).pk),
             s.f('type',       s.cvarchar(10)),
             s.f('name',       s.cvarchar(255).notNull),
             s.f('country_id', s.tables('countries'))
           )
  );
  --
  s.ctable('companies/company', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',                     s.cint().csequence().pk),
             s.f('name',                   s.cvarchar(100).notNull),

             s.f('country_id',             s.tables('countries')),

             s.f('zip',                    s.cvarchar(20)),
             s.f('town',                   s.cvarchar(70)),
             s.f('address',                s.cvarchar(200)),
             s.f('region',                 s.cvarchar(3)),

             s.f('postBox',                s.cvarchar(15)),
             s.f('postZip',                s.cvarchar(20)),
             s.f('postTown',               s.cvarchar(70)),

             s.f('bankName',               s.cvarchar(150)),
             s.f('bankAccount',            s.cvarchar(50)),
             s.f('bankIBAN',               s.cvarchar(50)),
             s.f('bankSWIFT',              s.cvarchar(50)),
             s.f('bankCountry_id',         s.tables('countries').fk),

             s.f('phone',                  s.cvarchar(20)),
             s.f('fax',                    s.cvarchar(20)),

             s.f('taxIdentifier',          s.cvarchar(50)),
             s.f('taxCountry_id',          s.tables('countries').fk),

             s.f('unique_id',                    s.cvarchar(50)),

             s.f('registration',           s.cvarchar(50)),
             s.f('registrationCountry_id', s.tables('countries').fk)
           )
  );
  --
  s.ctable('transportTypes', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',            s.cvarchar(7).pk),
             s.f('name',          s.cvarchar(50).cunique().notNull),
             s.f('localizedName', s.text),
             s.f('type',          s.cvarchar(50)),

             s.f('sealed',        s.cbool),
             s.f('joined',        s.cbool),
             s.f('container',     s.cbool)
           )
  );
  --
  s.ctable('carriers', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',             s.cint().csequence().pk),
             s.f('basfIdentifier', s.cint),
             s.f('company_id',     s.tables('companies').updated('CASCADE')),
             s.f('selectable',     s.cbool)
           )
  );
  --
  s.ctable('carrierTranspts', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cint().csequence().pk),
             s.f('carrier_id',s.tables('carriers').deleted('CASCADE')),
             s.f('transport_id',s.tables('transportTypes').changed('CASCADE')),
             s.f('dummy',s.cvarchar(10))
           )
  );
  --
  s.ctable('plants', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cvarchar(15).pk),
             s.f('company_id',s.tables('companies').updated('CASCADE')),
             s.f('sectioned',s.cbool)
           )
  );

  s.ctable('plantSections', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cvarchar(10).pk),
             s.f('box',s.cvarchar(10)),
             s.f('plant_id',s.tables('plants').updated('CASCADE')),
             s.f('item_id',s.tables('items').updated('CASCADE'))
           )
  );

  s.ctable('sites', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cint().csequence().pk),
             s.f('type',s.tables('siteTypes').updated('CASCADE')),
             s.f('name',s.cvarchar(100).notNull),

             s.f('company_id',s.tables('companies').updated('CASCADE')),
             s.f('location_id',s.tables('locations').updated('CASCADE')),
             s.f('plant_id',s.tables('plants').updated('CASCADE'))
           )
  );

  s.ctable('siteBalances', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cint().csequence().pk),
             s.f('site_id',s.tables('sites').updated('CASCADE')),
             s.f('section_id',s.tables('plantSections').updated('CASCADE')),

             s.f('item_id',s.tables('items')),

             s.f('quantity',s.cdecimal(10, 4)),

             s.f('updatedAt',s.ctimestamp().cdefault('CURRENT_TIMESTAMP').updated('CURRENT_TIMESTAMP'))
           )
  );

  s.ctable('customers', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cint().csequence().pk),
             s.f('basfIdentifier',s.cint),
             s.f('company_id',s.tables('companies').updated('CASCADE')),
             s.f('creditRating',s.cvarchar(5)),
             s.f('creditLimit',s.cdecimal(10, 4)),
             s.f('debt',s.cdecimal(10, 4)),
             s.f('type',s.tables('customerTypes').updated('CASCADE')),
             s.f('locale',s.cvarchar(2).cdefault('en'))
           )
  );

  s.ctable('paymentTerms/paymentTerms', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cvarchar(50).notNull().pk),
             s.f('description',s.text)
           )
  );

  s.ctable('suppliers', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cint().csequence().pk),
             s.f('company_id',s.tables('companies').updated('CASCADE')),
             s.f('defaultDeliveryTerms',s.tables('incoterms')),
             s.f('defaultDeliveryPocint',s.cvarchar(255)),
             s.f('defaultDeliveryTermsSea',s.tables('incoterms')),
             s.f('defaultDeliveryPocintSea',s.cvarchar(255)),
             s.f('defaultPaymentTerms_id',s.tables('paymentTerms').updated('CASCADE')),
             s.f('defaultCurrency',s.tables('currencies').updated('CASCADE'))
           )
  );

  s.ctable('salesUnits', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cvarchar(5).pk),
             s.f('company_id',s.tables('companies').updated('CASCADE')),

             s.f('registryTown',s.cvarchar(70)),
             s.f('registryCourt',s.cvarchar(100)),
             s.f('registryIdentifier',s.cvarchar(50)),

             s.f('manager',s.cvarchar(150))
           )
  );

  s.ctable('sellers', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cint().pk),
             s.f('name',s.cvarchar(100))
           )
  );

  s.ctable('orderTypes', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cvarchar(100).pk)
           )
  );

  s.ctable('oper_models', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cint().csequence().pk),
             s.f('name',s.cvarchar(50).notNull),

             s.f('origin_id',s.tables('plants').updated('CASCADE')),  -- NULL means own warehouse
             s.f('supplier_id',s.tables('suppliers').updated('CASCADE')),
             s.f('product_id',s.tables('products').updated('CASCADE')),
             s.f('salesUnit_id',s.tables('salesUnits').updated('CASCADE')),
             s.f('distributionUnit_id',s.tables('salesUnits').updated('CASCADE')),

             s.f('shipmentType',s.tables('shipmentTypes').updated('CASCADE')),
             s.f('incotermsGroup',s.tables('incotermsGroups').updated('CASCADE')),
             s.f('customsCleared',s.tables('custsClrTypes').updated('CASCADE')),
             s.f('transportationPaid',s.cbool),

             s.f('departureCountry_id',s.tables('countries')),
             s.f('reloadingCountry_id',s.tables('countries')),
             s.f('customerCountry_id',s.tables('countries')),
             s.f('customerRegion_id',s.tables('regions')),
             s.f('outsideEU',s.cbool),
             s.f('unknownTIN',s.cbool),

             s.f('notes',s.cvarchar(255)),

             s.f('activeFrom',s.cdate().notNull),
             s.f('activeTo',s.cdate().notNull)
           )
  );

  s.ctable('taxCodes', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cvarchar(30).pk),
             s.f('description',s.text),
             s.f('active',s.cbool)
           )
  );

  s.ctable('taxValues', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cint().csequence().pk),

             s.f('codeId',s.tables('taxCodes').changed('CASCADE')),
             s.f('value',s.cdecimal(10, 4).notNull),

             s.f('activeFrom',s.cdate().notNull),
             s.f('activeTo',s.cdate().notNull)
           )
  );

  s.ctable('operatTransfers', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cint().csequence().pk),

             s.f('type',s.tables('opTransferTypes').updated('CASCADE')),

             s.f('model_id',s.tables('oper_models').referenced('transfers').deleted('CASCADE')),

             s.f('sellerId',s.tables('sellers').updated('CASCADE').deleted('SET NULL')),
             s.f('orderTypeCode',s.tables('orderTypes').updated('CASCADE').deleted('SET NULL')),

             s.f('supplier_id',s.tables('companies').updated('CASCADE')),
             s.f('customer_id',s.tables('companies').updated('CASCADE')),

             s.f('ingoingTaxId',s.tables('taxCodes').updated('CASCADE').deleted('SET NULL')),
             s.f('outgoingTaxId',s.tables('taxCodes').updated('CASCADE').deleted('SET NULL'))
           )
  );

  s.ctable('deals', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cint().csequence().pk),
             s.f('state',s.tables('dealStates').updated('CASCADE')),

             s.f('salesUnit_id',s.tables('salesUnits').updated('CASCADE')),
             s.f('salesModel',s.tables('salesModels').updated('CASCADE')),

             s.f('paymentTermsId',s.tables('paymentTerms').updated('CASCADE')),

             s.f('author_id',s.tables('people')),
             s.f('trader_id',s.tables('people')),
             s.f('assistant_id',s.tables('people')),
             s.f('scm_id',s.tables('people')),

             s.f('customer_id',s.tables('customers').updated('CASCADE')),
             s.f('shipToCompany_id',s.tables('customers').updated('CASCADE')),
             s.f('billToCompany_id',s.tables('customers').updated('CASCADE')),
             s.f('billShippingToCompany_id',s.tables('customers').updated('CASCADE')),
             s.f('payerCompany_id',s.tables('customers').updated('CASCADE')),

             s.f('origin_id',s.tables('plants').updated('CASCADE')),
             s.f('item_id',s.tables('items').updated('CASCADE')),

             s.f('customsCleared',s.tables('custsClrTypes').updated('CASCADE')),

             s.f('from_id',s.tables('sites')),
             s.f('to_id',s.tables('sites')),

             s.f('deliveryTerms',s.tables('incoterms')),
             s.f('deliveryPocint',s.cvarchar(255)), -- TODO,Show most frequently used
             s.f('deliveryLocationId',s.tables('locations')),
             s.f('transport_id',s.tables('transportTypes').updated('CASCADE')),

             s.f('country_id',s.tables('countries')),
             s.f('province_id',s.tables('provinces')),

             s.f('reloadingCountryId',s.tables('countries')),

             s.f('quantity',s.cdecimal(10, 4)),
             s.f('quantityM',s.tables('measures').updated('CASCADE')),
             s.f('quantityOption',s.cint),

             s.f('currency',s.tables('currencies').updated('CASCADE')),

             s.f('supplier_id',s.tables('suppliers').updated('CASCADE')),
             s.f('purchaseDeliveryTerms',s.tables('incoterms')),
             s.f('purchaseDeliveryPocint',s.cvarchar(255)),
             s.f('purchasePaymentTerms_id',s.tables('paymentTerms').updated('CASCADE')),

             s.f('pricePlant',s.cdecimal(10, 4)),
             s.f('pricePlantC',s.tables('currencies')),
             s.f('priceGross',s.cdecimal(10, 4)),
             s.f('priceLRD',s.cdecimal(10, 4)),
             s.f('priceLRDC',s.tables('currencies')),
             s.f('priceNet',s.cdecimal(10, 4)),

             s.f('priceAdjustmentMode',s.tables('priceAdjModes')),
             s.f('priceInclusion',s.tables('priceInclusions')),

             s.f('agreementDate',s.cdate),
             s.f('deliveryStart',s.cdate),
             s.f('deliveryEnd',s.cdate),

             s.f('updatedAt',s.ctimestamp().cdefault('CURRENT_TIMESTAMP').updated('CURRENT_TIMESTAMP')),
             s.f('createdAt',s.cdate),

             s.f('referenceIdentifier',s.cvarchar(50)),
             s.f('referenceDate',s.cdate),

             s.f('notes',s.text),

             s.f('loadingInstructions',s.text),
             s.f('shippingInstructions',s.text),
             s.f('invoiceRemarks',s.text),

             s.f('withErrors',s.cbool),
             s.f('invoicable',s.cbool),

             s.f('distanceTotal',s.cint),
             s.f('distanceMotorway',s.cint),

             s.f('basfTaxCode',s.cvarchar(50)),

             s.f('model_id',s.tables('oper_models').fk),
             s.f('seller_id',s.tables('salesUnits').fk),
             s.f('vatValue',s.cdecimal(10,4))
           )
  );

  s.ctable('dlParticipants', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cint().csequence().pk),

             s.f('role',s.tables('participantRols')),
             s.f('name',s.cvarchar(200)),

             s.f('company_id',s.tables('companies').updated('CASCADE')),
             s.f('comission',s.cdecimal(10, 4)),

             s.f('deal_id',s.tables('deals').referenced('participants').deleted('CASCADE'))
           )
  );

  s.ctable('priceModifiers', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cvarchar(15).pk),

             s.f('type',s.tables('priceModTypes').updated('CASCADE')),
             s.f('method',s.tables('priceModMthds').updated('CASCADE')),
             s.f('multiplier',s.cdecimal(10, 4)),

             s.f('name',s.cvarchar(100).notNull),
             s.f('localizedName',s.text)
           )
  );

  s.ctable('priceAdjusts', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cint().csequence().pk),
             s.f('deal_id',s.tables('deals').referenced('priceAdjusts').deleted('CASCADE')),
             s.f('modifier_id',s.tables('priceModifiers').updated('CASCADE')),

             s.f('value',s.cdecimal(10, 4))
           )
  );

  s.ctable('invoices', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cint().csequence().pk),
             s.f('type',s.tables('invoiceTypes').updated('CASCADE')),
             s.f('state',s.tables('invoiceStates').updated('CASCADE')),

             s.f('query',s.text),
             s.f('receivableQuery',s.text),
             s.f('salesOrderQuery',s.text),
             s.f('purchaseOrderQuery',s.text),
             s.f('debitMemoQuery',s.text),
             s.f('creditMemoQuery',s.text),

             s.f('identifier',s.cvarchar(50)),
             s.f('receivableIdentifier',s.cvarchar(50)),
             s.f('salesOrderIdentifier',s.cvarchar(50)),
             s.f('purchaseOrderIdentifier',s.cvarchar(50)),
             s.f('debitMemoIdentifier',s.cvarchar(50)),
             s.f('creditMemoIdentifier',s.cvarchar(50)),

             s.f('vendor_id',s.tables('companies').fk().updated('CASCADE')),
             s.f('customer_id',s.tables('companies').fk().updated('CASCADE')),
             s.f('shipTo_id',s.tables('companies').fk().updated('CASCADE')),
             s.f('billTo_id',s.tables('companies').fk().updated('CASCADE')),
             s.f('payer_id',s.tables('companies').fk().updated('CASCADE')),

             s.f('amount',s.cdecimal(10, 4)),
             s.f('amountC',s.tables('currencies')),

             s.f('paymentTerms_id',s.tables('paymentTerms').updated('CASCADE')),

             s.f('paidAt',s.cdate),
             s.f('paidScheduled',s.cdate),

             s.f('invoicedAt',s.cdate),
             s.f('generalLedgerDate',s.cdate),
             s.f('createdAt',s.ctimestamp),

             s.f('creditMemoCreatedAt',s.cdate),
             s.f('debitMemoCreatedAt',s.cdate),

             s.f('attachmentId',s.cint),
             s.f('fileName',s.cvarchar(50))
           )
  );

  s.ctable('shipments', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cint().csequence().pk),
             s.f('isParent',s.cbool().cdefault('FALSE')),
             s.f('parent_id',s.self().referenced('shipments').deleted('CASCADE')),
             s.f('basfIdentifier',s.cvarchar(255)),
             s.f('cmrIdentifier',s.cint),

             s.f('state',s.tables('shipmentStates').updated('CASCADE')),

             s.f('from_id',s.tables('sites')),
             s.f('to_id',s.tables('sites')),

             s.f('supply_id',s.self().deleted('CASCADE')),

             s.f('quantityPerTransfer',s.cdecimal(10, 4)),

             s.f('carrier_id',s.tables('carriers')),
             s.f('subCarrier',s.cvarchar(50)),
             s.f('transport_id',s.tables('transportTypes').updated('CASCADE')),

             s.f('vesselIdentifier',s.cvarchar(100)),
             s.f('cargoIdentifier',s.cvarchar(100)),

             s.f('driverLicense',s.cvarchar(50)),
             s.f('driverIdentifier',s.cvarchar(150)),

             s.f('netWeight',s.cdecimal(10, 4)),
             s.f('tareWeight',s.cdecimal(10, 4)),
             s.f('grossWeight',s.cdecimal(10, 4)),

             s.f('maxCapacity',s.cdecimal(10, 4)),

    -- New set of dates equal to states
             s.f('checkedInScheduled',s.cdate),
             s.f('shippedScheduled',s.cdate),
             s.f('receivedScheduled',s.cdate),

             s.f('checkedInAt',s.cdate),
             s.f('shippedAt',s.cdate),
             s.f('receivedAt',s.cdate),

             s.f('costsSegment',s.cvarchar(20)),

             s.f('totalCost',s.cdecimal(10, 4)),
             s.f('totalCostC',s.tables('currencies').updated('CASCADE')),
             s.f('costTaxAmount',s.cdecimal(10, 4)),

             s.f('spotFreight',s.cdecimal(10, 4)),
             s.f('spotFreightC',s.tables('currencies').updated('CASCADE')),
             s.f('spotFreightType',s.tables('spotFrgTypes')),

             s.f('notes',s.cvarchar(255)),

             s.f('loadingInstructions',s.text),
             s.f('shippingInstructions',s.text),

             s.f('authorId',s.tables('people')),

             s.f('updatedAt',s.ctimestamp().cdefault('CURRENT_TIMESTAMP').updated('CURRENT_TIMESTAMP')),
             s.f('createdAt',s.cdate)
           )
  );

  s.ctable('parts', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cint().csequence().pk),
             s.f('shipment_id',s.tables('shipments').referenced('parts').deleted('CASCADE')),
             s.f('deal_id',s.tables('deals').fk),
             s.f('parent_id',s.self().referenced('parts').deleted('CASCADE')),

             s.f('type',s.tables('partTypes').updated('CASCADE')),

             s.f('origin_id',s.tables('plants')),
             s.f('to_id',s.tables('sites')),

             s.f('item_id',s.tables('items').updated('CASCADE')),
             s.f('quantity',s.cdecimal(10, 4)),

             s.f('price',s.cdecimal(10, 4)),
             s.f('currency',s.tables('currencies').updated('CASCADE'))
           )
  );

  s.ctable('transfers', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cint().csequence().pk),
             s.f('shipment_id',s.tables('shipments').referenced('transfers').deleted('CASCADE')),
             s.f('deal_id',s.tables('deals').fk().deleted('CASCADE')),

             s.f('item_id',s.tables('items').updated('CASCADE')),

             s.f('to_id',s.tables('sites')),
             s.f('deliveryTerms',s.tables('incoterms')),
             s.f('deliveryPocint',s.cvarchar(255)),

             s.f('section_id',s.tables('plantSections').updated('CASCADE')),

             s.f('netWeight',s.cdecimal(10, 4)),
             s.f('tareWeight',s.cdecimal(10, 4)),
             s.f('grossWeight',s.cdecimal(10, 4)),
             s.f('receivedWeight',s.cdecimal(10, 4)),

             s.f('plannedQuantity',s.cdecimal(10, 4)),

             s.f('cargoIdentifier',s.cvarchar(100)),
             s.f('sealIdentifier',s.cvarchar(100)),

             s.f('shuttleIdentifier',s.cvarchar(50)),
             s.f('shuttleCarrierId',s.tables('carriers').fk),
             s.f('shuttleType',s.tables('shuttleTypes').updated('CASCADE')),

             s.f('customsDeclaration',s.cvarchar(50)),
             s.f('customsCertificate',s.cvarchar(50)),
             s.f('customsObligation',s.cvarchar(50)),

             s.f('notes',s.cvarchar(255)),

             s.f('lotIdentifier',s.cvarchar(100)),
             s.f('batchIdentifier',s.cvarchar(100)),

             s.f('updatedAt',s.ctimestamp().cdefault('CURRENT_TIMESTAMP').updated('CURRENT_TIMESTAMP'))
           )
  );

  s.ctable('transferInvs', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cint().csequence().pk),
             s.f('transfer_id',s.tables('transfers').referenced('invoices').deleted('CASCADE')),
             s.f('invoice_id',s.tables('invoices').deleted('CASCADE'))
           )
  );

  s.ctable('costTypes', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cvarchar(4).pk),
             s.f('item',s.cvarchar(13)),
             s.f('name',s.text),
             s.f('account',s.cvarchar(44).notNull)
           )
  );

  s.ctable('shipmentCosts', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cint().csequence().pk),
             s.f('type_id',s.tables('costTypes').updated('CASCADE')),

             s.f('shipment_id',s.tables('shipments').referenced('costs').deleted('CASCADE')),
             s.f('deal_id',s.tables('parts').fk().deleted('CASCADE')),

             s.f('supplier_id',s.tables('carriers').updated('CASCADE')),

             s.f('threshold',s.text),
             s.f('baseFreight',s.cbool),
             s.f('cinternal',s.cbool),

             s.f('quantity',s.cdecimal(10, 4)),

             s.f('price',s.cdecimal(10, 4)),
             s.f('currency',s.cvarchar(3)), -- Don't use here reference to currencies table

             s.f('unitQuantity',s.cdecimal(10, 4)),
             s.f('unitMeasure',s.cvarchar(16)),

             s.f('taxCode_id',s.tables('taxCodes').updated('CASCADE')),
             s.f('taxAmount',s.cdecimal(10, 4)),

             s.f('amount',s.cdecimal(10, 4)),           -- amount in cost currency
             s.f('functionalAmount',s.cdecimal(10, 4)), -- amount in deal currency

             s.f('purchaseAmount',s.cdecimal(10, 4)),   -- amount for purchase order
             s.f('purchaseCurrency',s.cvarchar(3)),     -- currency for purchase order

             s.f('purchasedAt',s.cdate),

             s.f('row_num',s.cint),

    -- FIXME,one cost can be attached to only one invoice
    --        costInvoices table should be removed
             s.f('invoiceIdentifier',s.cvarchar(50))
           )
  );

  s.ctable('costInvoices', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cint().csequence().pk),
             s.f('cost_id',s.tables('shipmentCosts').referenced('invoices').deleted('CASCADE')),
             s.f('invoice_id',s.tables('invoices').deleted('CASCADE'))
           )
  );

  s.ctable('shipmentEvents', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cint().csequence().pk),
             s.f('shipment_id',s.tables('shipments').fk().deleted('CASCADE')),
             s.f('transfer_id',s.tables('transfers').fk().deleted('CASCADE')),

             s.f('name',s.cvarchar(50).notNull),
             s.f('timestamp',s.cdate().notNull),

             s.f('author_id',s.tables('people'))
           )
  );

  s.ctable('registry', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cint().csequence().pk),
             s.f('dealId',s.tables('deals').fk().deleted('CASCADE')),
             s.f('shipmentId',s.tables('shipments').fk().deleted('CASCADE')),

             s.f('action',s.cvarchar(50)),
             s.f('message',s.cvarchar(250)),

             s.f('authorId',s.tables('people')),
             s.f('createdAt',s.ctimestamp().cdefault('CURRENT_TIMESTAMP').updated('CURRENT_TIMESTAMP'))
           )
  );

  s.ctable('operations', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cint().csequence().pk),
             s.f('token',s.cvarchar(32).notNull().indexed),

             s.f('name',s.cvarchar(50)),
             s.f('action',s.cvarchar(50).notNull),

             s.f('state',s.tables('operationStates').updated('CASCADE')),
             s.f('message',s.text),

             s.f('url',s.text),
             s.f('document_id',s.cvarchar(100)),

             s.f('shipmentType',s.tables('shipmentTypes').updated('CASCADE')),
             s.f('shipmentState',s.tables('shipmentStates').updated('CASCADE')),

             s.f('shipment_id',s.tables('shipments').fk().deleted('CASCADE')),
             s.f('part_id',s.tables('parts').fk().deleted('CASCADE')),
             s.f('deal_id',s.tables('deals').fk().deleted('CASCADE')),

             s.f('sequence',s.cint),
             s.f('following_id',s.self),

             s.f('context',s.text),

             s.f('author_id',s.tables('people')),
             s.f('updatedAt',s.ctimestamp().cdefault('CURRENT_TIMESTAMP').updated('CURRENT_TIMESTAMP'))
           )
  );

  s.ctable('transferOpers', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cint().csequence().pk),
             s.f('transfer_id',s.tables('transfers').referenced('operations').deleted('CASCADE')),
             s.f('operation_id',s.tables('operations').deleted('CASCADE'))
           )
  );

  s.ctable('OEBSLots', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cvarchar(100).pk),
             s.f('transfer_id',s.tables('transfers').fk().deleted('CASCADE')),
             s.f('operation_id',s.tables('operations').fk().deleted('CASCADE'))
           )
  );

  s.ctable('OEBSSalesOrders', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cint().pk),
             s.f('identifier',s.cvarchar(100)),
             s.f('url',s.text),

             s.f('operation_id',s.tables('operations').fk().deleted('CASCADE')),
             s.f('deal_id',s.tables('deals').fk().deleted('CASCADE'))
           )
  );

  s.ctable('OEBSInvoices', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cint().pk),
             s.f('identifier',s.cvarchar(100)),
             s.f('url',s.text),

             s.f('salesOrder_id',s.tables('OEBSSalesOrders').referenced('invoices').deleted('CASCADE')),

             s.f('deliveryId',s.cvarchar(100))
           )
  );

  s.ctable('OEBSInvoiceLns', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cint().pk),
             s.f('invoice_id',s.tables('OEBSInvoices').referenced('lines').deleted('CASCADE')),

             s.f('lot_id',s.tables('OEBSLots'))
           )
  );

  s.ctable('OEBSWarehouses', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cint().csequence().pk),
             s.f('site_id',s.tables('sites').fk().deleted('CASCADE')),
             s.f('companyCode',s.cvarchar(5).notNull),
             s.f('code',s.cvarchar(3).notNull),
             s.f('transitCode',s.cvarchar(3).cunique)
           )
  );

  -- Virtual replenishment object
  s.ctable('replenishments', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('site_id',s.tables('sites')),
             s.f('product_id',s.tables('products'))
           )
  );

  -- Virtual filter object
  s.ctable('filters', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('origin_id',s.tables('plants')),
             s.f('country_id',s.tables('countries')),
             s.f('product_id',s.tables('products')),
             s.f('site_id',s.tables('sites')),
             s.f('to_id',s.tables('sites'))
           )
  );

  -- Ranges for CMR Numbers
  s.ctable('cmrRanges', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cint().csequence().pk),
             s.f('state',s.tables('cmrRangeStates').updated('CASCADE')),
             s.f('start_num',s.cint().notNull),
             s.f('end',s.cint().notNull),
             s.f('lastAssigned',s.cint)
           )
  );

  -- Document number ranges

  s.ctable('documentRanges', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cint().csequence().pk),
             s.f('type',s.cvarchar(200).notNull),
             s.f('state',s.tables('docRangeStates').updated('CASCADE')),
             s.f('start_num',s.cint().notNull),
             s.f('end',s.cint().notNull),
             s.f('lastAssigned',s.cint)
           )
  );

  -- Documents registry
  s.ctable('documents', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cint().csequence().pk),
             s.f('deal_id',s.tables('deals').fk),
             s.f('shipment_id',s.tables('shipments').fk),
             s.f('transfer_id',s.tables('transfers').fk),
             s.f('key',s.cvarchar(200)),
             s.f('range_id',s.tables('documentRanges').fk().updated('CASCADE')),
             s.f('identifier',s.cvarchar(100)),
             s.f('template',s.cvarchar(250)),
             s.f('dataset',s.cvarchar(100)),
             s.f('createdAt',s.cdate)
           )
  );

  s.ctable('transferDocs', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cint().csequence().pk),
             s.f('transfer_id',s.tables('transfers').referenced('documents').deleted('CASCADE')),
             s.f('document_id',s.tables('documents').deleted('CASCADE'))
           )
  );

  s.ctable('accounts', 
           xxdoo.xxdoo_db_fields_typ(
             s.f('id',s.cint().csequence().pk),
             s.f('company_id',s.tables('companies').fk),
             s.f('salesUnit_id',s.tables('salesUnits'))
           )
  );
  --
  s.generate;
  --
exception 
  when others then
    xxdoo.xxdoo_db_utils_pkg.fix_exception;
    xxdoo.xxdoo_db_utils_pkg.show_errors;
end;
0
1
instr(p_entity_name,'/')+1
