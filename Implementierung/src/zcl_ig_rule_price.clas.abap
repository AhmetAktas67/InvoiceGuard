CLASS zcl_ig_rule_price DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_ig_check_rule .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_ig_rule_price IMPLEMENTATION.


  METHOD zif_ig_check_rule~check.

  DATA:
      diffrence TYPE p LENGTH 16 DECIMALS 6,
      tolerance TYPE p LENGTH 16 DECIMALS 6.


   diffrence = abs( i_data-invoice_price - i_data-order_price ).
   tolerance = i_data-order_price * '0.02'.

   r_status = COND #( WHEN diffrence > tolerance
                      THEN zif_ig_check_rule=>c_price
                      ELSE zif_ig_check_rule=>c_ok ).

  ENDMETHOD.
ENDCLASS.
