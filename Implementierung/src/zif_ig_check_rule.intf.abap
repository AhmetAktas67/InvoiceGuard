INTERFACE zif_ig_check_rule


  PUBLIC.

  CONSTANTS:
       c_ok TYPE zig_invoice_item-check_status VALUE 'O',
       c_quantity TYPE zig_invoice_item-check_status VALUE 'Q',
       c_price    TYPE zig_invoice_item-check_status VALUE 'P'.

   TYPES:
        BEGIN OF ty_check_data,
          invoice_quantity   TYPE zig_invoice_item-quantity,
          invoice_price      TYPE zig_invoice_item-net_price,
          ordered_quantity   TYPE zig_po_item-quantity,
          order_price        TYPE zig_po_item-net_price,
          delivered_quantity TYPE zig_gr-quantity,
        END OF ty_check_data.

    METHODS check
    IMPORTING i_data          TYPE ty_check_data
    RETURNING VALUE(r_status) TYPE zig_invoice_item-check_status.



ENDINTERFACE.
