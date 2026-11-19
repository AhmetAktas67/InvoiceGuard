@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Supplier invoice item (projection)'
@Metadata.allowExtensions: true
define view entity ZC_IG_InvoiceItem
  as projection on ZR_IG_InvoiceItem
{
  key ItemUuid,
      InvoiceUuid,
      ItemNo,
      PoId,
      PoItem,
      Quantity,
      Unit,
      NetPrice,
      Currency,
      CheckStatus,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,

      _Invoice : redirected to parent ZC_IG_Invoice,
      _PurchaseOrderItem
}
