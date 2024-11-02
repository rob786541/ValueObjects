CLASS ltcl_currency DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    DATA cut TYPE REF TO zcl_vo_currency.
    DATA e   TYPE REF TO zcx_value_object.

    METHODS enter_currency     FOR TESTING.
    METHODS enter_lower        FOR TESTING.
    METHODS enter_non_existing FOR TESTING.
    METHODS enter_empty        FOR TESTING.
    METHODS as_string          FOR TESTING.

ENDCLASS.


CLASS ltcl_currency IMPLEMENTATION.
  METHOD enter_currency.
    TRY.
        cut = NEW #( 'CHF' ).
        cl_abap_unit_assert=>assert_equals( exp = 'CHF'
                                            act = cut->get_currency( ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD enter_non_existing.
    TRY.
        cut = NEW #( 'asd' ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_value_object INTO e.
        cl_abap_unit_assert=>assert_equals( exp = 'Currency asd is not valid'
                                            act = e->get_text( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD enter_empty.
    TRY.
        cut = NEW #( '' ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_value_object INTO e.
        cl_abap_unit_assert=>assert_equals( exp = 'Empty currency is not allowed'
                                            act = e->get_text( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD enter_lower.
    TRY.
        cut = NEW #( 'eur' ).
        cl_abap_unit_assert=>assert_equals( exp = 'EUR'
                                            act = cut->get_currency( ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD as_string.
    TRY.
        cut = NEW #( 'usd' ).
        cl_abap_unit_assert=>assert_equals( exp = 'USD'
                                            act = cut->as_string( ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
