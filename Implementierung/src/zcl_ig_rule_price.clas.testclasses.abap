*"* use this source file for your ABAP unit test classes
class ltcl_rule_price definition final for testing
  duration short
  risk level harmless.

  private section.

  DATA cut TYPE REF TO zif_ig_check_rule.

    methods:
    setup,
    same_price_ok FOR TESTING,
    exactly_2_percent_ok FOR TESTING,
    too_expensive FOR TESTING,
    too_cheap FOR TESTING.

endclass.


class ltcl_rule_price implementation.


  method exactly_2_percent_ok.
   cl_abap_unit_assert=>assert_equals(
      exp = zif_ig_check_rule=>c_ok
      act = cut->check( VALUE #( order_price = 100 invoice_price = 102 ) ) ).
  endmethod.

   method setup.
    cut = NEW zcl_ig_rule_price( ).
  endmethod.


  method same_price_ok.
     cl_abap_unit_assert=>assert_equals(
      exp = zif_ig_check_rule=>c_ok
      act = cut->check( VALUE #( order_price = 100 invoice_price = 100 ) ) ).
  endmethod.

  method too_cheap.
     cl_abap_unit_assert=>assert_equals(
     exp = zif_ig_check_rule=>c_price
     act = cut->check( VALUE #( order_price = 100 invoice_price = 95 ) ) ).
  endmethod.

  method too_expensive.
    cl_abap_unit_assert=>assert_equals(
     exp = zif_ig_check_rule=>c_price
     act = cut->check( VALUE #( order_price = 100 invoice_price = 105 ) ) ).
  endmethod.


endclass.
