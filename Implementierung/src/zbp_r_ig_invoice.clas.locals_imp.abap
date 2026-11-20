CLASS lhc_Invoice DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR Invoice RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR Invoice RESULT result.

    METHODS setInvoiceId FOR DETERMINE ON SAVE
      keys FOR Invoice~setInvoiceId.

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

ENDCLASS.
