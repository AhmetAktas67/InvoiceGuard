@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Delivered quantity per PO item'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_IG_GoodsReceiptSum as select from zig_gr
{
   
    key po_id as PoId,
    key  po_item as PoItem,
    @Semantics.quantity.unitOfMeasure: 'Unit'   
    sum( quantity ) as DeliveredQuantity,
    unit as Unit

}
group by
    po_id,
    po_item,
    unit
