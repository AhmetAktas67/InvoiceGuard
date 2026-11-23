@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Supplier invoice (RAP BO root)'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_IG_Invoice as select from ZIG_INVOICE
composition [0..*] of ZR_IG_InvoiceItem as _Item

association [1..1] to ZI_IG_Supplier    as _Supplier
    on $projection.SupplierId = _Supplier.SupplierId
{
    key invoice_uuid as InvoiceUuid,
    invoice_id as InvoiceId,
    supplier_id as SupplierId,
    supplier_invoice_ref as SupplierInvoiceRef,
    invoice_date as InvoiceDate,
    @Semantics.amount.currencyCode: 'Currency'
    gross_amount as GrossAmount,
    currency as Currency,
    status as Status,
     case status
        when 'O' then 3
        when 'F' then 3
        when 'A' then 1
        else 0
      end as StatusCriticality,
    discount_due_date as DiscountDueDate,
    net_due_date as NetDueDate,
   @Semantics.user.createdBy: true
    local_created_by as LocalCreatedBy,
    @Semantics.systemDateTime.createdAt: true
    local_created_at as LocalCreatedAt,
    @Semantics.user.localInstanceLastChangedBy: true
    local_last_changed_by as LocalLastChangedBy,
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    local_last_changed_at as LocalLastChangedAt,
    @Semantics.systemDateTime.lastChangedAt: true
    last_changed_at as LastChangedAt,
    
    _Item,
    _Supplier
    
   
}
