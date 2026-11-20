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

ENDCLASS.
