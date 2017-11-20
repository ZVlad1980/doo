var utils = require('nd-utils');

var W = utils.W;

module.exports = function(s) {
  s.table('priceModifierMethods', W('pertonnage percentage lumpsum'));
  s.table('priceModifierTypes', W('Discount Surcharge Lump-Sum'));
  s.table('measures/measure', W('st mt'));
  s.table('currencies/currency', W('EUR USD CHF'));
  s.table('salesModels', W('Direct Agent LRD Replenishment'));
  s.table('incoterms/incoterms', W('EXW FCA DAF DAP FOB FAS CPT CIP CIF CFR DDU DDP'));
  s.table('incotermsGroups/incotermsGroup', W('C,D-Terms E,F-Terms'));
  s.table('partTypes', W('Deal Replenishment'));
  s.table('siteTypes', W('Supply Transhipment Distribution Consignment'));
  s.table('shuttleTypes', W('Rail Barge'));
  s.table('shipmentTypes', W('Supply Replenishment Delivery'));
  s.table('shipmentStates', W('Draft Requested Fixed CheckedIn Loaded Shipped Received Canceling Canceled Invoicing Invoiced'));
  s.table('cmrRangeStates', W('Active Avaliable Depleted'));
  s.table('documentRangeStates', W('Active Avaliable Depleted'));
  s.table('operationStates', W('Pending Processing Success Error'));
  s.table('customerTypes', W('Company Consignee'));
  s.table('priceAdjustmentModes', W('Gross Subtotal'));
  s.table('invoiceStates', W('Created Billed Paid Cancelled'));
  s.table('invoiceTypes', W('Trader LRD Customer Carrier'));
  s.table('priceInclusions', ['ecotassa 2% ex L. 388 assolta']);
  s.table('spotFreightTypes', W('shipment mt container'));

  s.table('participantRoles', [
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
  ]);

  s.table('dealStates', [
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
  ]);

  s.table('operationTransferTypes', [
    'To Trader',
    'To LRD',
    'To Customer'
  ]);

  s.table('customsClearedTypes', [
    'First EU',
    'DEEAG',
    'Customer'
  ]);

  s.table('people/person', {
    'id': s.int.sequence.pk,
    'name': s.varchar(150).notNull,
    'position': s.varchar(50),
    'login': s.varchar(50).notNull.unique,
    'email': s.varchar(150).notNull,
    'role': s.varchar(50).notNull,
    'scopes': s.text,
    'locale': s.varchar(2).default('en'),
    'mobile': s.varchar(20),
    'phone': s.varchar(20),
    'fax': s.varchar(20)
  });

  s.table('products', {
    'id': s.int.sequence.pk,
    'CNCode': s.varchar(10),
    // TODO: Add localized version of names
    'name': s.varchar(70).notNull,
    'description': s.text,
    'dangerousNote': s.text
  });

  s.table('packages', {
    'id': s.varchar(2).pk,
    'name': s.varchar(50).notNull,
    'localizedName': s.text,
    'capacity': s.decimal(10, 4)
  });

  s.table('items', {
    'id': s.varchar(13).pk,
    'product_id': s.tables.products.updated('CASCADE'),
    'package_id': s.tables.packages.updated('CASCADE'),
    'netToGrossRate': s.decimal(10,8).default(1)
  });

  s.table('regions', {
    'id': s.varchar(3).pk,
    'name': s.varchar(100).notNull
  });

  s.table('countries/country', {
    'id': s.varchar(2).pk.notNull,
    'name': s.varchar(255).notNull,
    'localizedName': s.text,
    'union': s.varchar(15).indexed
  });

  s.table('provinces', {
    'id': s.varchar(5).pk,
    'name': s.varchar(100).notNull,
    'code': s.varchar(2).notNull,
    'country_id': s.tables.countries

    // TODO: Unique index code + country_id
  });

  s.table('locations', {
    'id': s.varchar(20).pk,
    'type': s.varchar(10),
    'name': s.varchar(255).notNull,
    'country_id': s.tables.countries
  });

  s.table('companies/company', {
    'id': s.int.sequence.pk,
    'name': s.varchar(100).notNull,

    'country_id': s.tables.countries,

    'zip': s.varchar(20),
    'town': s.varchar(70),
    'address': s.varchar(200),
    'region': s.varchar(3),

    'postBox': s.varchar(15),
    'postZip': s.varchar(20),
    'postTown': s.varchar(70),

    'bankName': s.varchar(150),
    'bankAccount': s.varchar(50),
    'bankIBAN': s.varchar(50),
    'bankSWIFT': s.varchar(50),
    'bankCountry_id': s.tables.countries.fk,

    'phone': s.varchar(20),
    'fax': s.varchar(20),

    'taxIdentifier': s.varchar(50),
    'taxCountry_id': s.tables.countries.fk,

    'uid': s.varchar(50),

    'registration': s.varchar(50),
    'registrationCountry_id': s.tables.countries.fk
  });

  s.table('transportTypes', {
    'id': s.varchar(7).pk,
    'name': s.varchar(50).unique.notNull,
    'localizedName': s.text,
    'type': s.varchar(50),

    'sealed': s.bool,
    'joined': s.bool,
    'container': s.bool
  });

  s.table('carriers', {
    'id': s.int.sequence.pk,
    'basfIdentifier': s.int,
    'company_id': s.tables.companies.updated('CASCADE'),
    'selectable': s.bool
  });

  s.table('carrierTransports', {
    'id': s.int.sequence.pk,
    'carrier_id': s.tables.carriers.deleted('CASCADE'),
    'transport_id': s.tables.transportTypes.changed('CASCADE'),
    'dummy': s.varchar(10)

    // TODO: Add method 'uniqueTogether' to column DSL
  });

  s.table('plants', {
    'id': s.varchar(15).pk,
    'company_id': s.tables.companies.updated('CASCADE'),
    'sectioned': s.bool
  });

  s.table('plantSections', {
    'id': s.varchar(10).pk,
    'box': s.varchar(10),
    'plant_id': s.tables.plants.updated('CASCADE'),
    'item_id': s.tables.items.updated('CASCADE')
  });

  s.table('sites', {
    'id': s.int.sequence.pk,
    'type': s.tables.siteTypes.updated('CASCADE'),
    'name': s.varchar(100).notNull,

    'company_id': s.tables.companies.updated('CASCADE'),
    'location_id': s.tables.locations.updated('CASCADE'),
    'plant_id': s.tables.plants.updated('CASCADE')
  });

  s.table('siteBalances', {
    'id': s.int.sequence.pk,
    'site_id': s.tables.sites.updated('CASCADE'),
    'section_id': s.tables.plantSections.updated('CASCADE'),

    'item_id': s.tables.items,

    'quantity': s.decimal(10, 4),

    'updatedAt': s.timestamp.default('CURRENT_TIMESTAMP').updated('CURRENT_TIMESTAMP')
  });

  s.table('customers', {
    'id': s.int.sequence.pk,
    'basfIdentifier': s.int,
    'company_id': s.tables.companies.updated('CASCADE'),
    'creditRating': s.varchar(5),
    'creditLimit': s.decimal(10, 4),
    'debt': s.decimal(10, 4),
    'type': s.tables.customerTypes.updated('CASCADE'),
    'locale': s.varchar(2).default('en')
  });

  s.table('paymentTerms/paymentTerms', {
    'id': s.varchar(50).notNull,
    'description': s.text
  });

  s.table('suppliers', {
    'id': s.int.sequence.pk,
    'company_id': s.tables.companies.updated('CASCADE'),
    'defaultDeliveryTerms': s.tables.incoterms,
    'defaultDeliveryPoint': s.varchar(255),
    'defaultDeliveryTermsSea': s.tables.incoterms,
    'defaultDeliveryPointSea': s.varchar(255),
    'defaultPaymentTerms_id': s.tables.paymentTerms.updated('CASCADE'),
    'defaultCurrency': s.tables.currencies.updated('CASCADE')
  });

  s.table('salesUnits', {
    'id': s.varchar(5).pk,
    'company_id': s.tables.companies.updated('CASCADE'),

    'registryTown': s.varchar(70),
    'registryCourt': s.varchar(100),
    'registryIdentifier': s.varchar(50),

    'manager': s.varchar(150)
  });

  s.table('sellers', {
    'id': s.int.pk,
    'name': s.varchar(100)
  });

  s.table('orderTypes', {
    'id': s.varchar(100).pk
  });

  s.table('operationModels', {
    'id': s.int.sequence.pk,
    'name': s.varchar(50).notNull,

    'origin_id': s.tables.plants.updated('CASCADE'),  // NULL means own warehouse
    'supplier_id': s.tables.suppliers.updated('CASCADE'),
    'product_id': s.tables.products.updated('CASCADE'),
    'salesUnit_id': s.tables.salesUnits.updated('CASCADE'),
    'distributionUnit_id': s.tables.salesUnits.updated('CASCADE'),

    'shipmentType': s.tables.shipmentTypes.updated('CASCADE'),
    'incotermsGroup': s.tables.incotermsGroups.updated('CASCADE'),
    'customsCleared': s.tables.customsClearedTypes.updated('CASCADE'),
    'transportationPaid': s.bool,

    'departureCountry_id': s.tables.countries,
    'reloadingCountry_id': s.tables.countries,
    'customerCountry_id': s.tables.countries,
    'customerRegion_id': s.tables.regions,
    'outsideEU': s.bool,
    'unknownTIN': s.bool,

    'notes': s.varchar(255),

    'activeFrom': s.date.notNull,
    'activeTo': s.date.notNull
  });

  s.table('taxCodes', {
    'id': s.varchar(30).pk,
    'description': s.text,
    'active': s.bool
  });

  s.table('taxValues', {
    'id': s.int.sequence.pk,

    'codeId': s.tables.taxCodes.changed('CASCADE'),
    'value': s.decimal(10, 4).notNull,

    'activeFrom': s.date.notNull,
    'activeTo': s.date.notNull
  });

  s.table('operationTransfers', {
    'id': s.int.sequence.pk,

    'type': s.tables.operationTransferTypes.updated('CASCADE'),

    'model_id': s.tables.operationModels.referenced('transfers').deleted('CASCADE'),

    'sellerId': s.tables.sellers.updated('CASCADE').deleted('SET NULL'),
    'orderTypeCode': s.tables.orderTypes.updated('CASCADE').deleted('SET NULL'),

    'supplier_id': s.tables.companies.updated('CASCADE'),
    'customer_id': s.tables.companies.updated('CASCADE'),

    'ingoingTaxId': s.tables.taxCodes.updated('CASCADE').deleted('SET NULL'),
    'outgoingTaxId': s.tables.taxCodes.updated('CASCADE').deleted('SET NULL')
  });

  s.table('deals', {
    'id': s.int.sequence.pk,
    'state': s.tables.dealStates.updated('CASCADE'),

    'salesUnit_id': s.tables.salesUnits.updated('CASCADE'),
    'salesModel': s.tables.salesModels.updated('CASCADE'),

    'paymentTermsId': s.tables.paymentTerms.updated('CASCADE'),

    'author_id': s.tables.people,
    'trader_id': s.tables.people,
    'assistant_id': s.tables.people,
    'scm_id': s.tables.people,

    'customer_id': s.tables.customers.updated('CASCADE'),
    'shipToCompany_id': s.tables.customers.updated('CASCADE'),
    'billToCompany_id': s.tables.customers.updated('CASCADE'),
    'billShippingToCompany_id': s.tables.customers.updated('CASCADE'),
    'payerCompany_id': s.tables.customers.updated('CASCADE'),

    'origin_id': s.tables.plants.updated('CASCADE'),
    'item_id': s.tables.items.updated('CASCADE'),

    'customsCleared': s.tables.customsClearedTypes.updated('CASCADE'),

    'from_id': s.tables.sites,
    'to_id': s.tables.sites,

    'deliveryTerms': s.tables.incoterms,
    'deliveryPoint': s.varchar(255), // TODO: Show most frequently used
    'deliveryLocationId': s.tables.locations,
    'transport_id': s.tables.transportTypes.updated('CASCADE'),

    'country_id': s.tables.countries,
    'province_id': s.tables.provinces,

    'reloadingCountryId': s.tables.countries,

    'quantity': s.decimal(10, 4),
    'quantityM': s.tables.measures.updated('CASCADE'),
    'quantityOption': s.int,

    'currency': s.tables.currencies.updated('CASCADE'),

    'supplier_id': s.tables.suppliers.updated('CASCADE'),
    'purchaseDeliveryTerms': s.tables.incoterms,
    'purchaseDeliveryPoint': s.varchar(255),
    'purchasePaymentTerms_id': s.tables.paymentTerms.updated('CASCADE'),

    'pricePlant': s.decimal(10, 4),
    'pricePlantC': s.tables.currencies,
    'priceGross': s.decimal(10, 4),
    'priceLRD': s.decimal(10, 4),
    'priceLRDC': s.tables.currencies,
    'priceNet': s.decimal(10, 4),

    'priceAdjustmentMode': s.tables.priceAdjustmentModes,
    'priceInclusion': s.tables.priceInclusions,

    'agreementDate': s.date,
    'deliveryStart': s.date,
    'deliveryEnd': s.date,

    'updatedAt': s.timestamp.default('CURRENT_TIMESTAMP').updated('CURRENT_TIMESTAMP'),
    'createdAt': s.datetime,

    'referenceIdentifier': s.varchar(50),
    'referenceDate': s.date,

    'notes': s.text,

    'loadingInstructions': s.text,
    'shippingInstructions': s.text,
    'invoiceRemarks': s.text,

    'withErrors': s.bool,
    'invoicable': s.bool,

    'distanceTotal': s.int,
    'distanceMotorway': s.int,

    'basfTaxCode': s.varchar(50),

    'model_id': s.tables.operationModels.fk,
    'seller_id': s.tables.salesUnits.fk,
    'vatValue': s.decimal(10,4)
  });

  s.table('dealParticipants', {
    'id': s.int.sequence.pk,

    'role': s.tables.participantRoles,
    'name': s.varchar(200),

    'company_id': s.tables.companies.updated('CASCADE'),
    'comission': s.decimal(10, 4),

    'deal_id': s.tables.deals.referenced('participants').deleted('CASCADE')
  });

  s.table('priceModifiers', {
    'id': s.varchar(15).pk,

    'type': s.tables.priceModifierTypes.updated('CASCADE'),
    'method': s.tables.priceModifierMethods.updated('CASCADE'),
    'multiplier': s.decimal(10, 4),

    'name': s.varchar(100).notNull,
    'localizedName': s.text
  });

  s.table('priceAdjustments', {
    'id': s.int.sequence.pk,
    'deal_id': s.tables.deals.referenced('priceAdjustments').deleted('CASCADE'),
    'modifier_id': s.tables.priceModifiers.updated('CASCADE'),

    'value': s.decimal(10, 4)
  });

  s.table('invoices', {
    'id': s.int.sequence.pk,
    'type': s.tables.invoiceTypes.updated('CASCADE'),
    'state': s.tables.invoiceStates.updated('CASCADE'),

    'query': s.text,
    'receivableQuery': s.text,
    'salesOrderQuery': s.text,
    'purchaseOrderQuery': s.text,
    'debitMemoQuery': s.text,
    'creditMemoQuery': s.text,

    'identifier': s.varchar(50),
    'receivableIdentifier': s.varchar(50),
    'salesOrderIdentifier': s.varchar(50),
    'purchaseOrderIdentifier': s.varchar(50),
    'debitMemoIdentifier': s.varchar(50),
    'creditMemoIdentifier': s.varchar(50),

    'vendor_id': s.tables.companies.fk.updated('CASCADE'),
    'customer_id': s.tables.companies.fk.updated('CASCADE'),
    'shipTo_id': s.tables.companies.fk.updated('CASCADE'),
    'billTo_id': s.tables.companies.fk.updated('CASCADE'),
    'payer_id': s.tables.companies.fk.updated('CASCADE'),

    'amount': s.decimal(10, 4),
    'amountC': s.tables.currencies,

    'paymentTerms_id': s.tables.paymentTerms.updated('CASCADE'),

    'paidAt': s.date,
    'paidScheduled': s.date,

    'invoicedAt': s.date,
    'generalLedgerDate': s.date,
    'createdAt': s.timestamp,

    'creditMemoCreatedAt': s.date,
    'debitMemoCreatedAt': s.date,

    'attachmentId': s.int,
    'fileName': s.varchar(50)
  });

  s.table('shipments', {
    'id': s.int.sequence.pk,
    'isParent': s.bool.default('FALSE'),
    'parent_id': s.self.referenced('shipments').deleted('CASCADE'),
    'basfIdentifier': s.varchar(255),
    'cmrIdentifier': s.int,

    'state': s.tables.shipmentStates.updated('CASCADE'),

    'from_id': s.tables.sites,
    'to_id': s.tables.sites,

    'supply_id': s.self.deleted('CASCADE'),

    'quantityPerTransfer': s.decimal(10, 4),

    'carrier_id': s.tables.carriers,
    'subCarrier': s.varchar(50),
    'transport_id': s.tables.transportTypes.updated('CASCADE'),

    'vesselIdentifier': s.varchar(100),
    'cargoIdentifier': s.varchar(100),

    'driverLicense': s.varchar(50),
    'driverIdentifier': s.varchar(150),

    'netWeight': s.decimal(10, 4),
    'tareWeight': s.decimal(10, 4),
    'grossWeight': s.decimal(10, 4),

    'maxCapacity': s.decimal(10, 4),

    // New set of dates equal to states
    'checkedInScheduled': s.date,
    'shippedScheduled': s.date,
    'receivedScheduled': s.date,

    'checkedInAt': s.datetime,
    'shippedAt': s.datetime,
    'receivedAt': s.datetime,

    'costsSegment': s.varchar(20),

    'totalCost': s.decimal(10, 4),
    'totalCostC': s.tables.currencies.updated('CASCADE'),
    'costTaxAmount': s.decimal(10, 4),

    'spotFreight': s.decimal(10, 4),
    'spotFreightC': s.tables.currencies.updated('CASCADE'),
    'spotFreightType': s.tables.spotFreightTypes,

    'notes': s.varchar(255),

    'loadingInstructions': s.text,
    'shippingInstructions': s.text,

    'authorId': s.tables.people,

    'updatedAt': s.timestamp.default('CURRENT_TIMESTAMP').updated('CURRENT_TIMESTAMP'),
    'createdAt': s.datetime
  });

  s.table('parts', {
    'id': s.int.sequence.pk,
    'shipment_id': s.tables.shipments.referenced('parts').deleted('CASCADE'),
    'deal_id': s.tables.deals.fk,
    'parent_id': s.self.referenced('parts').deleted('CASCADE'),

    'type': s.tables.partTypes.updated('CASCADE'),

    'origin_id': s.tables.plants,
    'to_id': s.tables.sites,

    'item_id': s.tables.items.updated('CASCADE'),
    'quantity': s.decimal(10, 4),

    'price': s.decimal(10, 4),
    'currency': s.tables.currencies.updated('CASCADE')
  });

  s.table('transfers', {
    'id': s.int.sequence.pk,
    'shipment_id': s.tables.shipments.referenced('transfers').deleted('CASCADE'),
    'deal_id': s.tables.deals.fk.deleted('CASCADE'),

    'item_id': s.tables.items.updated('CASCADE'),

    'to_id': s.tables.sites,
    'deliveryTerms': s.tables.incoterms,
    'deliveryPoint': s.varchar(255),

    'section_id': s.tables.plantSections.updated('CASCADE'),

    'netWeight': s.decimal(10, 4),
    'tareWeight': s.decimal(10, 4),
    'grossWeight': s.decimal(10, 4),
    'receivedWeight': s.decimal(10, 4),

    'plannedQuantity': s.decimal(10, 4),

    'cargoIdentifier': s.varchar(100),
    'sealIdentifier': s.varchar(100),

    'shuttleIdentifier': s.varchar(50),
    'shuttleCarrierId': s.tables.carriers.fk,
    'shuttleType': s.tables.shuttleTypes.updated('CASCADE'),

    'customsDeclaration': s.varchar(50),
    'customsCertificate': s.varchar(50),
    'customsObligation': s.varchar(50),

    'notes': s.varchar(255),

    'lotIdentifier': s.varchar(100),
    'batchIdentifier': s.varchar(100),

    'updatedAt': s.timestamp.default('CURRENT_TIMESTAMP').updated('CURRENT_TIMESTAMP')
  });

  s.table('transferInvoices', {
    'id': s.int.sequence.pk,
    'transfer_id': s.tables.transfers.referenced('invoices').deleted('CASCADE'),
    'invoice_id': s.tables.invoices.deleted('CASCADE')
  });

  s.table('costTypes', {
    'id': s.varchar(4).pk,
    'item': s.varchar(13),

    'name': s.text,
    'account': s.varchar(44).notNull
  });

  s.table('shipmentCosts', {
    'id': s.int.sequence.pk,
    'type_id': s.tables.costTypes.updated('CASCADE'),

    'shipment_id': s.tables.shipments.referenced('costs').deleted('CASCADE'),
    'deal_id': s.tables.parts.fk.deleted('CASCADE'),

    'supplier_id': s.tables.carriers.updated('CASCADE'),

    'threshold': s.text,
    'baseFreight': s.bool,
    'internal': s.bool,

    'quantity': s.decimal(10, 4),

    'price': s.decimal(10, 4),
    'currency': s.varchar(3), // Don't use here reference to currencies table

    'unitQuantity': s.decimal(10, 4),
    'unitMeasure': s.varchar(16),

    'taxCode_id': s.tables.taxCodes.updated('CASCADE'),
    'taxAmount': s.decimal(10, 4),

    'amount': s.decimal(10, 4),           // amount in cost currency
    'functionalAmount': s.decimal(10, 4), // amount in deal currency

    'purchaseAmount': s.decimal(10, 4),   // amount for purchase order
    'purchaseCurrency': s.varchar(3),     // currency for purchase order

    'purchasedAt': s.date,

    'row': s.int,

    // FIXME: one cost can be attached to only one invoice
    //        costInvoices table should be removed
    'invoiceIdentifier': s.varchar(50)
  });

  s.table('costInvoices', {
    'id': s.int.sequence.pk,
    'cost_id': s.tables.shipmentCosts.referenced('invoices').deleted('CASCADE'),
    'invoice_id': s.tables.invoices.deleted('CASCADE')
  });

  s.table('shipmentEvents', {
    'id': s.int.sequence.pk,
    'shipment_id': s.tables.shipments.fk.deleted('CASCADE'),
    'transfer_id': s.tables.transfers.fk.deleted('CASCADE'),

    'name': s.varchar(50).notNull,
    'timestamp': s.datetime.notNull,

    'author_id': s.tables.people
  });

  s.table('registry', {
    'id': s.int.sequence.pk,
    'dealId': s.tables.deals.fk.deleted('CASCADE'),
    'shipmentId': s.tables.shipments.fk.deleted('CASCADE'),

    'action': s.varchar(50),
    'message': s.varchar(250),

    'authorId': s.tables.people,
    'createdAt': s.timestamp.default('CURRENT_TIMESTAMP').updated('CURRENT_TIMESTAMP')
  });

  s.table('operations', {
    'id': s.int.sequence.pk,
    'token': s.varchar(32).notNull.indexed,

    'name': s.varchar(50),
    'action': s.varchar(50).notNull,

    'state': s.tables.operationStates.updated('CASCADE'),
    'message': s.text,

    'url': s.text,
    'document_id': s.varchar(100),

    'shipmentType': s.tables.shipmentTypes.updated('CASCADE'),
    'shipmentState': s.tables.shipmentStates.updated('CASCADE'),

    'shipment_id': s.tables.shipments.fk.deleted('CASCADE'),
    'part_id': s.tables.parts.fk.deleted('CASCADE'),
    'deal_id': s.tables.deals.fk.deleted('CASCADE'),

    'sequence': s.int,
    'following_id': s.self,

    'context': s.text,

    'author_id': s.tables.people,
    'updatedAt': s.timestamp.default('CURRENT_TIMESTAMP').updated('CURRENT_TIMESTAMP')
  });

  s.table('transferOperations', {
    'id': s.int.sequence.pk,
    'transfer_id': s.tables.transfers.referenced('operations').deleted('CASCADE'),
    'operation_id': s.tables.operations.deleted('CASCADE')
  });

  s.table('OEBSLots', {
    'id': s.varchar(100).pk,

    // FIXME: maybe should store here lot origin (purchase order number/batch number)?

    'transfer_id': s.tables.transfers.fk.deleted('CASCADE'),
    'operation_id': s.tables.operations.fk.deleted('CASCADE')
  });

  s.table('OEBSSalesOrders', {
    'id': s.int.pk,
    'identifier': s.varchar(100),
    'url': s.text,

    'operation_id': s.tables.operations.fk.deleted('CASCADE'),
    'deal_id': s.tables.deals.fk.deleted('CASCADE')
  });

  s.table('OEBSInvoices', {
    'id': s.int.pk,
    'identifier': s.varchar(100),
    'url': s.text,

    'salesOrder_id': s.tables.OEBSSalesOrders.referenced('invoices').deleted('CASCADE'),

    'deliveryId': s.varchar(100)
  });

  s.table('OEBSInvoiceLines', {
    'id': s.int.pk,
    'invoice_id': s.tables.OEBSInvoices.referenced('lines').deleted('CASCADE'),

    'lot_id': s.tables.OEBSLots
  });

  s.table('OEBSWarehouses', {
    'id': s.int.sequence.pk,
    'site_id': s.tables.sites.fk.deleted('CASCADE'),
    'companyCode': s.varchar(5).notNull,
    'code': s.varchar(3).notNull,
    'transitCode': s.varchar(3).unique
  });

  // Virtual replenishment object
  s.table('replenishments', {
    'site_id': s.tables.sites,
    'product_id': s.tables.products
  });

  // Virtual filter object
  s.table('filters', {
    'origin_id': s.tables.plants,
    'country_id': s.tables.countries,
    'product_id': s.tables.products,
    'site_id': s.tables.sites,
    'to_id': s.tables.sites
  });

  // Ranges for CMR Numbers
  s.table('cmrRanges', {
    'id': s.int.sequence.pk,
    'state': s.tables.cmrRangeStates.updated('CASCADE'),
    'start': s.int.notNull,
    'end': s.int.notNull,
    'lastAssigned': s.int
  });

  // Document number ranges

  s.table('documentRanges', {
    'id': s.int.sequence.pk,
    'type': s.varchar(200).notNull,
    'state': s.tables.documentRangeStates.updated('CASCADE'),
    'start': s.int.notNull,
    'end': s.int.notNull,
    'lastAssigned': s.int
  });

  // Documents registry
  s.table('documents', {
    'id': s.int.sequence.pk,
    'deal_id': s.tables.deals.fk,
    'shipment_id': s.tables.shipments.fk,
    'transfer_id': s.tables.transfers.fk,
    'key': s.varchar(200),
    'range_id': s.tables.documentRanges.fk.updated('CASCADE'),
    'identifier': s.varchar(100),
    'template': s.varchar(250),
    'dataset': s.varchar(100),
    'createdAt': s.datetime,
  });

  s.table('transferDocuments', {
    'id': s.int.sequence.pk,
    'transfer_id': s.tables.transfers.referenced('documents').deleted('CASCADE'),
    'document_id': s.tables.documents.deleted('CASCADE')
  });

  s.table('accounts', {
    'id': s.int.sequence.pk,
    'company_id': s.tables.companies.fk,
    'salesUnit_id': s.tables.salesUnits
  });

};