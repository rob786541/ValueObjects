CLASS ltcl_money DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    DATA cut TYPE REF TO zcl_vo_money.
    DATA e   TYPE REF TO zcx_value_object.

    METHODS get_money1 FOR TESTING.
    METHODS get_money2 FOR TESTING.
    METHODS get_money3 FOR TESTING.
    METHODS rounded1   FOR TESTING.
    METHODS rounded2   FOR TESTING.
    METHODS rounded3   FOR TESTING.
    methods to_string1 for testing.
    methods to_string2 for testing.
    methods to_string3 for testing.
    METHODS add1       FOR TESTING.
    METHODS add2       FOR TESTING.
    METHODS sub1       FOR TESTING.
    METHODS sub2       FOR TESTING.
    METHODS sub3       FOR TESTING.
    METHODS equal1     FOR TESTING.
    METHODS equal2     FOR TESTING.
    METHODS equal3     FOR TESTING.

ENDCLASS.


CLASS ltcl_money IMPLEMENTATION.
  METHOD get_money1.
    TRY.
        cut = NEW #( i_amount   = 15
                     i_currency = NEW #( 'CHF' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '15'
                                            act = cut->get_amount( ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_money2.
    TRY.
        cut = NEW #( i_amount   = -15
                     i_currency = NEW #( 'CHF' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '-15'
                                            act = cut->get_amount( ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_money3.
    TRY.
        cut = NEW #( i_amount   = 0
                     i_currency = NEW #( 'EUR' ) ).
        cl_abap_unit_assert=>assert_equals( exp = ''
                                            act = cut->get_amount( ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD rounded1.
    TRY.
        cut = NEW #( i_amount   = '12.216'
                     i_currency = NEW #( 'EUR' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '12.22'
                                            act = cut->get_amount_rounded( ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD rounded2.
    TRY.
        cut = NEW #( i_amount   = '12.29643'
                     i_currency = NEW #( 'EUR' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '12.3'
                                            act = cut->get_amount_rounded( i_decimals = 1 ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD rounded3.
    TRY.
        cut = NEW #( i_amount   = '1723.216'
                     i_currency = NEW #( 'EUR' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '2000'
                                            act = cut->get_amount_rounded( i_precision = 1 ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD add1.
    TRY.
        cut = NEW #( i_amount   = '12.216'
                     i_currency = NEW #( 'EUR' ) ).
        DATA(other) = NEW zcl_vo_money( i_amount   = '0.82'
                                        i_currency = NEW #( 'eur' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '13,036'
                                            act = cut->add( other )->to_string( ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD add2.
    TRY.
        cut = NEW #( i_amount   = '12.216'
                     i_currency = NEW #( 'EUR' ) ).
        DATA(other) = NEW zcl_vo_money( i_amount   = '0.82'
                                        i_currency = NEW #( 'usd' ) ).
        cut->add( other ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_value_object INTO e.
        cl_abap_unit_assert=>assert_equals( exp = 'Currency USD is not equal to EUR'
                                            act = e->get_text( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD sub1.
    TRY.
        cut = NEW #( i_amount   = '12.216'
                     i_currency = NEW #( 'EUR' ) ).
        DATA(other) = NEW zcl_vo_money( i_amount   = '0.82'
                                        i_currency = NEW #( 'eur' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '11,396'
                                            act = cut->sub( other )->to_string( ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD sub2.
    TRY.
        cut = NEW #( i_amount   = '12.216'
                     i_currency = NEW #( 'EUR' ) ).
        DATA(other) = NEW zcl_vo_money( i_amount   = '0.82'
                                        i_currency = NEW #( 'usd' ) ).
        cut->sub( other ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_value_object INTO e.
        cl_abap_unit_assert=>assert_equals( exp = 'Currency USD is not equal to EUR'
                                            act = e->get_text( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD sub3.
    TRY.
        cut = NEW #( i_amount   = 12
                     i_currency = NEW #( 'EUR' ) ).
        DATA(other) = NEW zcl_vo_money( i_amount   = 15
                                        i_currency = NEW #( 'eur' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '-3'
                                            act = cut->sub( other )->to_string( ) ).

      CATCH zcx_value_object INTO e.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD equal1.
    TRY.
        cut = NEW #( i_amount   = '12.216'
                     i_currency = NEW #( 'EUR' ) ).
        DATA(other) = NEW zcl_vo_money( i_amount   = '12.216'
                                        i_currency = NEW #( 'eur' ) ).
        cl_abap_unit_assert=>assert_true( cut->is_equal( other ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD equal2.
    TRY.
        cut = NEW #( i_amount   = '12.216'
                     i_currency = NEW #( 'EUR' ) ).
        DATA(other) = NEW zcl_vo_money( i_amount   = '12.216'
                                        i_currency = NEW #( 'usd' ) ).
        cl_abap_unit_assert=>assert_false( cut->is_equal( other ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD equal3.
    TRY.
        cut = NEW #( i_amount   = '12.2126'
                     i_currency = NEW #( 'EUR' ) ).
        DATA(other) = NEW zcl_vo_money( i_amount   = '12.216'
                                        i_currency = NEW #( 'eur' ) ).
        cl_abap_unit_assert=>assert_false( cut->is_equal( other ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD to_string1.
    TRY.
        cut = NEW #( i_amount   = '1723.216'
                     i_currency = NEW #( 'EUR' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '1.723,216 EUR'
                                            act = cut->to_string_with_currency( ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD to_string2.
    TRY.
        cut = NEW #( i_amount   = 0
                     i_currency = NEW #( 'EUR' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '0'
                                            act = cut->to_string( ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD to_string3.
    TRY.
        cut = NEW #( i_amount   = 0
                     i_currency = NEW #( 'EUR' ) ).
        cl_abap_unit_assert=>assert_equals( exp = ''
                                            act = cut->to_string_empty_for_zero( ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
