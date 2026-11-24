CLASS zcl_ig_report DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_ig_report IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
   DATA(today) = cl_abap_context_info=>get_system_date( ).


   "  Übersicht pro Status
   SELECT FROM ZR_IG_Invoice
    FIELDS Status,
           COUNT( * )   AS InvoiceCount,
           SUM( GrossAmount ) AS TotalAmount,
           Currency
    GROUP BY Status, Currency
    ORDER BY Status
    INTO TABLE @DATA(status_overview).

     out->write( name = `1. Invoices per status` data = status_overview ).

    " Offene Rechnungen (nicht freigegeben) mit Fälligkeit

    SELECT FROM zr_ig_invoice
      FIELDS InvoiceId,
             \_Supplier-SupplierName AS SupplierName,
             GrossAmount,
             Currency,
             Status,
             NetDueDate
      WHERE Status <> 'F'
      ORDER BY NetDueDate
      INTO TABLE @DATA(open_invoices).

    TYPES: BEGIN OF ty_open,
             invoice_id TYPE zig_invoice-invoice_id,
             supplier   TYPE zig_lieferant-name,
             amount     TYPE zig_invoice-gross_amount,
             currency   TYPE zig_invoice-currency,
             days_left  TYPE i,
             state      TYPE string,
           END OF ty_open.
    DATA open_list TYPE STANDARD TABLE OF ty_open WITH EMPTY KEY.

    open_list = VALUE #( FOR inv IN open_invoices
      LET days = COND i( WHEN inv-NetDueDate IS INITIAL THEN 0
                         ELSE inv-NetDueDate - today )
      IN
      ( invoice_id = inv-InvoiceId
        supplier   = inv-SupplierName
        amount     = inv-GrossAmount
        currency   = inv-Currency
        days_left  = days
        state      = COND #( WHEN inv-NetDueDate IS INITIAL THEN `no due date`
                             WHEN days < 0                  THEN `OVERDUE`
                             WHEN days <= 7                 THEN `due soon`
                             ELSE                                `ok` ) ) ).

    out->write( name = `2. Open invoices` data = open_list ).


     "  Skonto-Chancen: Skontofrist in den nächsten 7 Tagen

    DATA(in_7_days) = CONV d( today + 7 ).

    SELECT FROM zr_ig_invoice
      FIELDS InvoiceId,
             \_Supplier-SupplierName    AS SupplierName,
             \_Supplier-DiscountPercent AS DiscountPercent,
             GrossAmount,
             Currency,
             DiscountDueDate
      WHERE DiscountDueDate BETWEEN @today AND @in_7_days
        AND Status <> 'A'
      ORDER BY DiscountDueDate
      INTO TABLE @DATA(discounts).

    DATA(total_savings) = REDUCE decfloat34(
                            INIT sum = CONV decfloat34( 0 )
                            FOR disc IN discounts
                            NEXT sum = sum + disc-GrossAmount * disc-DiscountPercent / 100 ).

    out->write( name = `3. Cash discount opportunities (next 7 days)` data = discounts ).
    out->write( |Possible savings if paid in time: { total_savings DECIMALS = 2 } EUR| ).

  ENDMETHOD.





ENDCLASS.
