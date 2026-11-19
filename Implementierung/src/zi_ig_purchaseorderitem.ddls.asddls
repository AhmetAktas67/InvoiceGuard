@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase order item'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_IG_PurchaseOrderItem as select from zig_po_item

association [0..*] to ZI_IG_GoodsReceipt as _GoodsReceipt
  on  $projection.PoId   = _GoodsReceipt.PoId
  and $projection.PoItem = _GoodsReceipt.PoItem
  
association [1..1] to ZI_IG_Material as _Material
  on $projection.MaterialId = _Material.MaterialId 
  
  association [0..1] to ZI_IG_GoodsReceiptSum as _GoodsReceiptSum
  on  $projection.PoId   = _GoodsReceiptSum.PoId
  and $projection.PoItem = _GoodsReceiptSum.PoItem
  
  association [1..1] to ZI_IG_PurchaseOrder as _PurchaseOrder
  on $projection.PoId = _PurchaseOrder.PoId
{
    key po_id as PoId,
    key po_item as PoItem,
    material_id as MaterialId,
    @Semantics.quantity.unitOfMeasure: 'Unit'
    quantity as Quantity,
    unit as Unit,
    @Semantics.amount.currencyCode: 'Currency'
    net_price as NetPrice,
    currency as Currency,
    local_created_by as LocalCreatedBy,
    local_created_at as LocalCreatedAt,
    local_last_changed_by as LocalLastChangedBy,
    local_last_changed_at as LocalLastChangedAt,
    last_changed_at as LastChangedAt,
    
    _Material,
    _GoodsReceipt,
    _GoodsReceiptSum,
    _PurchaseOrder
}
