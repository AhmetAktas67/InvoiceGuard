CLASS lhc_Invoice DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR Invoice RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR Invoice RESULT result.

    METHODS setInvoiceId FOR DETERMINE ON SAVE
      keys FOR Invoice~setInvoiceId.
    METHODS calculateDueDates FOR DETERMINE ON MODIFY
      keys FOR Invoice~calculateDueDates.
    METHODS validateSupplier FOR VALIDATE ON SAVE
      keys FOR Invoice~validateSupplier.
    METHODS validateAmount FOR VALIDATE ON SAVE
      keys FOR Invoice~validateAmount.

    METHODS validateDuplicate FOR VALIDATE ON SAVE
      keys FOR Invoice~validateDuplicate.
    METHODS checkInvoice FOR MODIFY
      keys FOR ACTION Invoice~checkInvoice RESULT result.

ENDCLASS.

CLASS lhc_Invoice IMPLEMENTATION.

  METHOD get_instance_authorizations.

  ENDMETHOD.

  METHOD get_global_authorizations.

  ENDMETHOD.

  METHOD setInvoiceId.

   READ ENTITIES OF zr_ig_invoice IN LOCAL MODE
   ENTITY Invoice
        FIELDS ( InvoiceId )
        WITH CORRESPONDING #( keys )
      RESULT DATA(invoices).

    DELETE invoices WHERE InvoiceId IS NOT INITIAL.

    IF invoices IS INITIAL.
      RETURN.

    ENDIF.

    DATA(today)  = cl_abap_context_info=>get_system_date( ).
    DATA(prefix) = |RE-{ today(4) }-|.
    DATA(pattern) = prefix && '%'.

    SELECT SINGLE FROM zig_invoice
      FIELDS MAX( invoice_id )
      WHERE invoice_id LIKE @pattern
      INTO @DATA(max_id).

    DATA(last_number) = 0.
    IF max_id IS NOT INITIAL.
      last_number = max_id+8(5).
    ENDIF.

     MODIFY ENTITIES OF zr_ig_invoice IN LOCAL MODE
      ENTITY Invoice
        UPDATE FIELDS ( InvoiceId )
        WITH VALUE #( FOR invoice IN invoices INDEX INTO i
                      ( %tky      = invoice-%tky
                        InvoiceId = |{ prefix }{ last_number + i WIDTH = 5 ALIGN = RIGHT PAD = '0' }| ) ).


  ENDMETHOD.

  METHOD calculateDueDates.
    READ ENTITIES OF zr_ig_invoice IN LOCAL MODE
      ENTITY Invoice
        FIELDS ( SupplierId InvoiceDate )
        WITH CORRESPONDING #( keys )
      RESULT DATA(invoices).

    DELETE invoices WHERE SupplierId IS INITIAL OR InvoiceDate IS INITIAL.
    IF invoices IS INITIAL.
      RETURN.
    ENDIF.

    SELECT FROM zi_ig_supplier
      FIELDS SupplierId, DiscountDays, NetDays
      FOR ALL ENTRIES IN @invoices
      WHERE SupplierId = @invoices-SupplierId
      INTO TABLE @DATA(suppliers).

      DATA updates TYPE TABLE FOR UPDATE zr_ig_invoice\\Invoice.

    LOOP AT invoices INTO DATA(invoice).
      READ TABLE suppliers INTO DATA(supplier)
           WITH KEY SupplierId = invoice-SupplierId.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      APPEND VALUE #( %tky            = invoice-%tky
                      DiscountDueDate = COND #( WHEN supplier-DiscountDays > 0
                                                THEN invoice-InvoiceDate + supplier-DiscountDays )
                      NetDueDate      = invoice-InvoiceDate + supplier-NetDays )
             TO updates.
    ENDLOOP.

    MODIFY ENTITIES OF zr_ig_invoice IN LOCAL MODE
      ENTITY Invoice
        UPDATE FIELDS ( DiscountDueDate NetDueDate )
        WITH updates.



  ENDMETHOD.

  METHOD validateSupplier.
    READ ENTITIES OF zr_ig_invoice IN LOCAL MODE
      ENTITY Invoice
        FIELDS ( SupplierId )
        WITH CORRESPONDING #( keys )
      RESULT DATA(invoices).

    IF invoices IS INITIAL.
      RETURN.
    ENDIF.

    SELECT FROM zi_ig_supplier
      FIELDS SupplierId, IsBlocked
      FOR ALL ENTRIES IN @invoices
      WHERE SupplierId = @invoices-SupplierId
      INTO TABLE @DATA(suppliers).

       LOOP AT invoices INTO DATA(invoice).

      " alte Meldung dieser Prüfung entfernen
      APPEND VALUE #( %tky        = invoice-%tky
                      %state_area = 'VALIDATE_SUPPLIER' )
             TO reported-invoice.

      READ TABLE suppliers INTO DATA(supplier)
           WITH KEY SupplierId = invoice-SupplierId.

      IF sy-subrc <> 0.
        " Fehler 1: Lieferant existiert nicht
        APPEND VALUE #( %tky = invoice-%tky ) TO failed-invoice.
        APPEND VALUE #( %tky        = invoice-%tky
                        %state_area = 'VALIDATE_SUPPLIER'
                        %msg        = new_message( id       = 'ZIG_MSG'
                                                   number   = '001'
                                                   severity = if_abap_behv_message=>severity-error
                                                   v1       = invoice-SupplierId )
                        %element-SupplierId = if_abap_behv=>mk-on )
               TO reported-invoice.

      ELSEIF supplier-IsBlocked = abap_true.
        " Fehler 2: Lieferant gesperrt
        APPEND VALUE #( %tky = invoice-%tky ) TO failed-invoice.
        APPEND VALUE #( %tky        = invoice-%tky
                        %state_area = 'VALIDATE_SUPPLIER'
                        %msg        = new_message( id       = 'ZIG_MSG'
                                                   number   = '002'
                                                   severity = if_abap_behv_message=>severity-error
                                                   v1       = invoice-SupplierId )
                        %element-SupplierId = if_abap_behv=>mk-on )
               TO reported-invoice.
      ENDIF.

    ENDLOOP.


  ENDMETHOD.

  METHOD validateAmount.
    READ ENTITIES OF zr_ig_invoice IN LOCAL MODE
      ENTITY Invoice FIELDS ( GrossAmount ) WITH CORRESPONDING #( keys )
      RESULT DATA(invoices).

    LOOP AT invoices INTO DATA(invoice).
      APPEND VALUE #( %tky = invoice-%tky %state_area = 'VALIDATE_AMOUNT' ) TO reported-invoice.

      IF invoice-GrossAmount <= 0.
        APPEND VALUE #( %tky = invoice-%tky ) TO failed-invoice.
        APPEND VALUE #( %tky        = invoice-%tky
                        %state_area = 'VALIDATE_AMOUNT'
                        %msg        = new_message( id       = 'ZIG_MSG'
                                                   number   = '003'
                                                   severity = if_abap_behv_message=>severity-error )
                        %element-GrossAmount = if_abap_behv=>mk-on ) TO reported-invoice.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateDuplicate.
   READ ENTITIES OF zr_ig_invoice IN LOCAL MODE
      ENTITY Invoice FIELDS ( SupplierId SupplierInvoiceRef ) WITH CORRESPONDING #( keys )
      RESULT DATA(invoices).

    IF invoices IS INITIAL.
      RETURN.
    ENDIF.

    SELECT FROM zr_ig_invoice
      FIELDS InvoiceUuid, InvoiceId, SupplierId, SupplierInvoiceRef
      FOR ALL ENTRIES IN @invoices
      WHERE SupplierId         = @invoices-SupplierId
        AND SupplierInvoiceRef = @invoices-SupplierInvoiceRef
      INTO TABLE @DATA(existing).

    LOOP AT invoices INTO DATA(invoice).
      APPEND VALUE #( %tky = invoice-%tky %state_area = 'VALIDATE_DUPLICATE' ) TO reported-invoice.

      LOOP AT existing INTO DATA(ex)
           WHERE SupplierId         = invoice-SupplierId
             AND SupplierInvoiceRef = invoice-SupplierInvoiceRef
             AND InvoiceUuid       <> invoice-InvoiceUuid.
        APPEND VALUE #( %tky = invoice-%tky ) TO failed-invoice.
        APPEND VALUE #( %tky        = invoice-%tky
                        %state_area = 'VALIDATE_DUPLICATE'
                        %msg        = new_message( id       = 'ZIG_MSG'
                                                   number   = '004'
                                                   severity = if_abap_behv_message=>severity-error
                                                   v1       = invoice-SupplierInvoiceRef
                                                   v2       = invoice-SupplierId
                                                   v3       = ex-InvoiceId )
                        %element-SupplierInvoiceRef = if_abap_behv=>mk-on ) TO reported-invoice.
        EXIT.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD checkInvoice.

    READ ENTITIES OF zr_ig_invoice IN LOCAL MODE
      ENTITY Invoice BY \_Item
        FIELDS ( InvoiceUuid PoId PoItem Quantity NetPrice )
        WITH CORRESPONDING #( keys )
      RESULT DATA(items).

       DATA(matcher) = NEW zcl_ig_matcher( ).

    DATA item_updates   TYPE TABLE FOR UPDATE zr_ig_invoice\\Item.
    DATA deviations     TYPE SORTED TABLE OF sysuuid_x16 WITH UNIQUE KEY table_line.
    DATA status         TYPE zig_invoice_item-check_status.

    LOOP AT items INTO DATA(item).
      TRY.
          status = matcher->check_item( i_po_id     = item-PoId
                                        i_po_item   = item-PoItem
                                        i_quantity  = item-Quantity
                                        i_net_price = item-NetPrice ).
        CATCH zcx_ig_check INTO DATA(exc).
          CLEAR status.
          APPEND VALUE #( %tky = item-%tky
                          %msg = new_message_with_text(
                                   severity = if_abap_behv_message=>severity-error
                                   text     = exc->get_text( ) ) )
                 TO reported-item.
      ENDTRY.

      APPEND VALUE #( %tky = item-%tky CheckStatus = status ) TO item_updates.

      IF status <> zif_ig_check_rule=>c_ok.
        INSERT item-InvoiceUuid INTO TABLE deviations.
      ENDIF.
    ENDLOOP.

    " Status der Rechnung: A = Abweichung, O = alles ok
    DATA invoice_updates TYPE TABLE FOR UPDATE zr_ig_invoice\\Invoice.

    invoice_updates = VALUE #( FOR key IN keys
                               ( %tky   = key-%tky
                                 Status = COND #( WHEN line_exists( deviations[ table_line = key-InvoiceUuid ] )
                                                  THEN 'A'
                                                  ELSE 'O' ) ) ).

    " Beides auf einmal schreiben
    MODIFY ENTITIES OF zr_ig_invoice IN LOCAL MODE
      ENTITY Item
        UPDATE FIELDS ( CheckStatus ) WITH item_updates
      ENTITY Invoice
        UPDATE FIELDS ( Status ) WITH invoice_updates.

    " Ergebnis an Fiori zurückgeben
    READ ENTITIES OF zr_ig_invoice IN LOCAL MODE
      ENTITY Invoice ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(invoices).

    result = VALUE #( FOR invoice IN invoices
                      ( %tky = invoice-%tky %param = invoice ) ).
  ENDMETHOD.

ENDCLASS.
