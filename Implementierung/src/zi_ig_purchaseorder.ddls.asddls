@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase order header'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_IG_PurchaseOrder as select from zig_po

association [1..1] to ZI_IG_Supplier as _Supplier          on $projection.SupplierId = _Supplier.SupplierId
association [0..*] to ZI_IG_PurchaseOrderItem as _Item     on $projection.PoId       = _Item.PoId
{
    key po_id as PoId,
    supplier_id as SupplierId,
    order_date as OrderDate,
    currency as Currency,
    local_created_by as LocalCreatedBy,
    local_created_at as LocalCreatedAt,
    local_last_changed_by as LocalLastChangedBy,
    local_last_changed_at as LocalLastChangedAt,
    last_changed_at as LastChangedAt,
    
    _Supplier,
    _Item
    
}
