*"* use this source file for your ABAP unit test classes
class ltcl_rule_quantity definition final for testing
  duration short
  risk level harmless.

  private section.

  data cut type ref to zif_ig_check_rule.


    METHODS setup.
    METHODS invoiced_equals_delivered_ok FOR TESTING.
    METHODS invoiced_more_than_delivered FOR TESTING.
    METHODS nothing_delivered            FOR TESTING.
endclass.


class ltcl_rule_quantity implementation.

  METHOD invoiced_more_than_delivered.

    DATA(data) = VALUE zif_ig_check_rule=>ty_check_data( invoice_quantity = 60 delivered_quantity = 50 ).

    DATA(result) = cut->check( data ).

    cl_abap_unit_assert=>assert_equals( exp = zif_ig_check_rule=>c_quantity act = result ).

  ENDMETHOD.

  method invoiced_equals_delivered_ok.
   cl_abap_unit_assert=>assert_equals(
      exp = zif_ig_check_rule=>c_ok
      act = cut->check( VALUE #( invoice_quantity = 50 delivered_quantity = 50 ) ) ).
  endmethod.

  method nothing_delivered.
    cl_abap_unit_assert=>assert_equals(
      exp = zif_ig_check_rule=>c_quantity
      act = cut->check( VALUE #( invoice_quantity = 10 delivered_quantity = 0 ) ) ).
  endmethod.

  method setup.
   cut = NEW zcl_ig_rule_quantity( ).
  endmethod.

endclass.
