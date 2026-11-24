CLASS zcl_ig_fill_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_ig_fill_data IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

 DELETE FROM zig_invoice_item.
    DELETE FROM zig_invoice.
    DELETE FROM zig_invitem_d.
    DELETE FROM zig_invoice_d.



    DELETE FROM zig_gr.
    DELETE FROM zig_po_item.
    DELETE FROM zig_po.
    DELETE FROM zig_material.
    DELETE FROM zig_lieferant.

    "  Lieferanten – L003 ist gesperrt
    INSERT zig_lieferant FROM TABLE @( VALUE #(
      ( supplier_id = 'L001' name = 'Fuchs GmbH'      country = 'DE'
        discount_percent = '2.00' discount_days = 14 net_days = 30 is_blocked = abap_false )

      ( supplier_id = 'L002' name = 'Hydro GmbH'      country = 'DE'
        discount_percent = '3.00' discount_days = 10 net_days = 45 is_blocked = abap_false )

      ( supplier_id = 'L003' name = 'AF Handels GmbH' country = 'AT'
        discount_percent = '0.00' discount_days = 0  net_days = 30 is_blocked = abap_true )
    ) ).

    "  Materialien
    INSERT zig_material FROM TABLE @( VALUE #(
      ( material_id = 'M001' description = 'Schraube M8'      base_unit = 'ST' )

      ( material_id = 'M002' description = 'Mutter M8'        base_unit = 'ST' )

      ( material_id = 'M003' description = 'Hydraulikoel HLP46' base_unit = 'L' )
    ) ).

    "  Bestellköpfe
    INSERT zig_po FROM TABLE @( VALUE #(
      ( po_id = '4500000001' supplier_id = 'L001' order_date = '20261101' currency = 'EUR' )
      ( po_id = '4500000002' supplier_id = 'L002' order_date = '20261105' currency = 'EUR' )
      ( po_id = '4500000003' supplier_id = 'L003' order_date = '20261110' currency = 'EUR' )
    ) ).

    "  Bestellpositionen
    INSERT zig_po_item FROM TABLE @( VALUE #(
      ( po_id = '4500000001' po_item = '00010' material_id = 'M001'
        quantity = 100 unit = 'ST' net_price = '0.20' currency = 'EUR' )

      ( po_id = '4500000001' po_item = '00020' material_id = 'M002'
        quantity = 50  unit = 'ST' net_price = '0.10' currency = 'EUR' )

      ( po_id = '4500000002' po_item = '00010' material_id = 'M003'
        quantity = 200 unit = 'L'  net_price = '4.50' currency = 'EUR' )

      ( po_id = '4500000002' po_item = '00020' material_id = 'M001'
        quantity = 500 unit = 'ST' net_price = '0.19' currency = 'EUR' )

      ( po_id = '4500000003' po_item = '00010' material_id = 'M002'
        quantity = 100 unit = 'ST' net_price = '0.12' currency = 'EUR' )
    ) ).

    "  Wareneingänge
    INSERT zig_gr FROM TABLE @( VALUE #(
      " 4500000001/10: voll geliefert (100 von 100)
      ( gr_id = 'GR00000001' po_id = '4500000001' po_item = '00010'
        gr_date = '20261105' quantity = 100 unit = 'ST' )

      " 4500000001/20: in 2 Teillieferungen voll (30 + 20 = 50)
      ( gr_id = 'GR00000002' po_id = '4500000001' po_item = '00020'
        gr_date = '20261105' quantity = 30  unit = 'ST' )
      ( gr_id = 'GR00000003' po_id = '4500000001' po_item = '00020'
        gr_date = '20261112' quantity = 20  unit = 'ST' )

      " 4500000002/10: nur teilweise (120 von 200)
      ( gr_id = 'GR00000004' po_id = '4500000002' po_item = '00010'
        gr_date = '20261108' quantity = 120 unit = 'L' )

      " 4500000002/20: KEIN Wareneingang
      " 4500000003/10: voll, aber Lieferant gesperrt
      ( gr_id = 'GR00000005' po_id = '4500000003' po_item = '00010'
        gr_date = '20261115' quantity = 100 unit = 'ST' )
    ) ).



    " Eine geprüfte Rechnung von einem ANDEREN Benutzer
    " -> darf freigegeben werden (Vier-Augen-Prinzip)
    DATA(today) = cl_abap_context_info=>get_system_date( ).
    DATA(invoice_date) = CONV d( today - 3 ).

    DATA now TYPE timestampl.
    GET TIME STAMP FIELD now.

    TRY.
        DATA(invoice_uuid) = cl_system_uuid=>create_uuid_x16_static( ).
        DATA(item_uuid1)   = cl_system_uuid=>create_uuid_x16_static( ).
        DATA(item_uuid2)   = cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error.
        out->write( |UUID konnte nicht erzeugt werden.| ).
        RETURN.
    ENDTRY.

    INSERT zig_invoice FROM @( VALUE #(
      invoice_uuid          = invoice_uuid
      invoice_id            = 'RE-2026-00001'
      supplier_id           = 'L001'
      supplier_invoice_ref  = 'FU-2026-0815'
      invoice_date          = invoice_date
      gross_amount          = '29.75'
      currency              = 'EUR'
      status                = 'O'
      discount_due_date     = invoice_date + 14
      net_due_date          = invoice_date + 30
      local_created_by      = 'MUSTERMANN'
      local_created_at      = now
      local_last_changed_by = 'MUSTERMANN'
      local_last_changed_at = now
      last_changed_at       = now ) ).

    INSERT zig_invoice_item FROM TABLE @( VALUE #(
      ( item_uuid = item_uuid1 invoice_uuid = invoice_uuid item_no = '00010'
        po_id = '4500000001' po_item = '00010'
        quantity = 100 unit = 'ST' net_price = '0.20' currency = 'EUR'
        check_status = 'O'
        local_created_by = 'MUSTERMANN' local_created_at = now
        local_last_changed_by = 'MUSTERMANN' local_last_changed_at = now
        last_changed_at = now )
      ( item_uuid = item_uuid2 invoice_uuid = invoice_uuid item_no = '00020'
        po_id = '4500000001' po_item = '00020'
        quantity = 50 unit = 'ST' net_price = '0.10' currency = 'EUR'
        check_status = 'O'
        local_created_by = 'MUSTERMANN' local_created_at = now
        local_last_changed_by = 'MUSTERMANN' local_last_changed_at = now
        last_changed_at = now )
    ) ).

    out->write( |Testdaten angelegt.| ).








  ENDMETHOD.
ENDCLASS.
