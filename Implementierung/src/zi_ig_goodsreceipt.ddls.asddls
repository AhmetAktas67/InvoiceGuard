@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Goods receipt'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_IG_GoodsReceipt as select from zig_gr
association [1..1] to ZI_IG_PurchaseOrderItem as _PurchaseOrderItem
  on  $projection.PoId   = _PurchaseOrderItem.PoId
  and $projection.PoItem = _PurchaseOrderItem.PoItem
{
    key gr_id as GrId,
    po_id as PoId,
    po_item as PoItem,
    gr_date as GrDate,
    @Semantics.quantity.unitOfMeasure: 'Unit'
    quantity as Quantity,
    unit as Unit,
    local_created_by as LocalCreatedBy,
    local_created_at as LocalCreatedAt,
    local_last_changed_by as LocalLastChangedBy,
    local_last_changed_at as LocalLastChangedAt,
    last_changed_at as LastChangedAt,
    
    _PurchaseOrderItem
}
