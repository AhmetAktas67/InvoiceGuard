@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Supplier invoice (projection)'
@Metadata.allowExtensions: true
define root view entity ZC_IG_Invoice 
provider contract transactional_query
as projection on ZR_IG_INVOICE
{
    key InvoiceUuid,
    InvoiceId,
    SupplierId,
    _Supplier.SupplierName as SupplierName,
    SupplierInvoiceRef,
    InvoiceDate,
    GrossAmount,
    Currency,
    Status,
    DiscountDueDate,
    NetDueDate,
    LocalCreatedBy,
    LocalCreatedAt,
    LocalLastChangedBy,
    LocalLastChangedAt,
    LastChangedAt,
    /* Associations */
    _Item : redirected to composition child ZC_IG_InvoiceItem,
    _Supplier
    
}
