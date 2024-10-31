CLASS ltcl_weight DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    DATA cut TYPE REF TO zcl_vo_weight.
    DATA e   TYPE REF TO zcx_value_object.

    METHODS get_weight1 FOR TESTING.
    METHODS get_weight2 FOR TESTING.
    METHODS wrong_uom   FOR TESTING.
    METHODS get_weight4 FOR TESTING.
    METHODS get_weight5 FOR TESTING.
    METHODS get_weight6 FOR TESTING.
    METHODS get_weight7 FOR TESTING.
    METHODS get_weight8 FOR TESTING.
    METHODS get_weight9 FOR TESTING.
    METHODS rounded1    FOR TESTING.
    METHODS rounded2    FOR TESTING.
    METHODS rounded3    FOR TESTING.

ENDCLASS.


CLASS ltcl_weight IMPLEMENTATION.
  METHOD get_weight1.
    TRY.
        cut = NEW #( i_weight = 15
                     i_uom    = NEW #( 'KG' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '15'
                                            act = cut->get_weight_in( ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_weight2.
    TRY.
        cut = NEW #( i_weight = 15
                     i_uom    = NEW #( 'KG' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '15000'
                                            act = cut->get_weight_in( NEW #( 'G' ) ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD wrong_uom.
    TRY.
        cut = NEW #( i_weight = '12'
                     i_uom    = NEW #( 'M' ) ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_value_object INTO e.
        cl_abap_unit_assert=>assert_equals( exp = 'UOM M is not a valid mass dimension'
                                            act = e->get_text( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_weight4.
    TRY.
        cut = NEW #( i_weight = 15
                     i_uom    = NEW #( 'G' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '0.015'
                                            act = cut->get_weight_in( NEW #( 'kg' ) ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_weight5.
    TRY.
        cut = NEW #( i_weight = '152324123456.321654'
                     i_uom    = NEW #( 'to' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '152324123456321654000'
                                            act = cut->get_weight_in( NEW #( 'mg' ) ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_weight6.
    TRY.
        cut = NEW #( i_weight = '0.0000000123456'
                     i_uom    = NEW #( 'mg' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '0.0000000000000000123456'
                                            act = cut->get_weight_in( NEW #( 'to' ) ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_weight7.
    TRY.
        cut = NEW #( i_weight = 15
                     i_uom    = NEW #( 'g' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '0.03306936630275666237499779537557982'
                                            act = cut->get_weight_in( NEW #( 'lb' ) ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_weight8.
    TRY.
        cut = NEW #( i_weight = 15
                     i_uom    = NEW #( 'G' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '0.00001653468315137833118749889768778991'
                                            act = cut->get_weight_in( NEW #( 'ton' ) ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_weight9.
    TRY.
        cut = NEW #( i_weight = 15
                     i_uom    = NEW #( 'LB' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '6.80388'
                                            act = cut->get_weight_in( NEW #( 'kg' ) ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD rounded1.
    TRY.
        cut = NEW #( i_weight = 15
                     i_uom    = NEW #( 'LB' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '7'
                                            act = cut->get_weight_in_rounded( i_uom      = NEW #( 'kg' )
                                                                              i_decimals = 0 ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD rounded2.
    TRY.
        cut = NEW #( i_weight = 15
                     i_uom    = NEW #( 'LB' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '6.804'
                                            act = cut->get_weight_in_rounded( i_uom = NEW #( 'kg' ) ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD rounded3.
    TRY.
        cut = NEW #( i_weight = 15
                     i_uom    = NEW #( 'G' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '0.00001653468315137833118749889768778991'
                                            act = cut->get_weight_in_rounded( i_uom      = NEW #( 'ton' )
                                                                              i_decimals = 60 ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
