@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'association to parent'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZR_IG_InvoiceItem as select from zig_invoice_item

association to parent ZR_IG_Invoice     as _Invoice
    on $projection.InvoiceUuid = _Invoice.InvoiceUuid
    
 association [0..1] to ZI_IG_PurchaseOrderItem as _PurchaseOrderItem
    on  $projection.PoId   = _PurchaseOrderItem.PoId
    and $projection.PoItem = _PurchaseOrderItem.PoItem    
{
    key item_uuid as ItemUuid,
    invoice_uuid as InvoiceUuid,
    item_no as ItemNo,
    po_id as PoId,
    po_item as PoItem,
    @Semantics.quantity.unitOfMeasure: 'Unit' 
    quantity as Quantity,
    unit as Unit,
    @Semantics.amount.currencyCode: 'Currency'
    net_price as NetPrice,
    currency as Currency,
    check_status as CheckStatus,
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
    _Invoice,
    _PurchaseOrderItem
}
