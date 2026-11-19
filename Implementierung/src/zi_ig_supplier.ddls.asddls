@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Supplier'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_IG_Supplier as select from ZIG_LIEFERANT
{
    key supplier_id as SupplierId,
    name as SupplierName,
    country as Country,
    discount_percent as DiscountPercent,
    discount_days as DiscountDays,
    net_days as NetDays,
    is_blocked as IsBlocked,
    local_created_by as LocalCreatedBy,
    local_created_at as LocalCreatedAt,
    local_last_changed_by as LocalLastChangedBy,
    local_last_changed_at as LocalLastChangedAt,
    last_changed_at as LastChangedAt
}
