CLASS zcl_ig_matcher DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
   METHODS constructor.

   METHODS check_item
    IMPORTING i_po_id         TYPE zig_invoice_item-po_id
              i_po_item       TYPE zig_invoice_item-po_item
              i_quantity      TYPE zig_invoice_item-quantity
              i_net_price     TYPE zig_invoice_item-net_price
    RETURNING VALUE(r_status) TYPE zig_invoice_item-check_status

    RAISING zcx_ig_check.

  PROTECTED SECTION.
  PRIVATE SECTION.
   DATA rules TYPE STANDARD TABLE OF REF TO zif_ig_check_rule WITH EMPTY KEY.
ENDCLASS.



CLASS zcl_ig_matcher IMPLEMENTATION.
  METHOD check_item.
   SELECT SINGLE FROM zi_ig_purchaseorderitem
     FIELDS Quantity,
            NetPrice,
            \_GoodsReceiptSum-DeliveredQuantity AS DeliveredQuantity
     WHERE PoId = @i_po_id
     AND PoItem = @i_po_item

     INTO @DATA(po_item).

   IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_ig_check
         EXPORTING textid = zcx_ig_check=>po_item_not_found
                   po_id  = i_po_id
                   po_item = i_po_item.
   ENDIF.

    DATA(check_data) = VALUE zif_ig_check_rule=>ty_check_data(
                         invoice_quantity   = i_quantity
                         invoice_price      = i_net_price
                         ordered_quantity   = po_item-Quantity
                         order_price        = po_item-NetPrice
                         delivered_quantity = po_item-DeliveredQuantity ).

    r_status = zif_ig_check_rule=>c_ok.

    LOOP AT rules INTO DATA(rule).
      r_status = rule->check( check_data ).
      IF r_status <> zif_ig_check_rule=>c_ok.
        RETURN.
      ENDIF.
    ENDLOOP.



  ENDMETHOD.

  METHOD constructor.
      rules = VALUE #( ( NEW zcl_ig_rule_quantity( ) )
                     ( NEW zcl_ig_rule_price( ) ) ).

  ENDMETHOD.

ENDCLASS.
