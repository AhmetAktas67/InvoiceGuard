CLASS zcl_ig_rule_quantity DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_ig_check_rule .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_ig_rule_quantity IMPLEMENTATION.


  METHOD zif_ig_check_rule~check.

   r_status = COND #( WHEN i_data-invoice_quantity > i_data-delivered_quantity
                       THEN zif_ig_check_rule=>c_quantity
                       ELSE zif_ig_check_rule=>c_ok ).



  ENDMETHOD.
ENDCLASS.
