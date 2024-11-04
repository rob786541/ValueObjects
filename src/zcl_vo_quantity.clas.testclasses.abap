CLASS ltcl_quantity DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    DATA cut TYPE REF TO zcl_vo_quantity.
    DATA e   TYPE REF TO zcx_value_object.

    METHODS get_quantity1    FOR TESTING.
    METHODS get_quantity2    FOR TESTING.
    METHODS negative         FOR TESTING.
    METHODS different_dimms1 FOR TESTING.
    METHODS different_dimms2 FOR TESTING.
    METHODS different_dimms3 FOR TESTING.
    METHODS get_quantity4    FOR TESTING.
    METHODS get_quantity5    FOR TESTING.
    METHODS get_quantity6    FOR TESTING.
    METHODS get_quantity7    FOR TESTING.
    METHODS get_quantity8    FOR TESTING.
    METHODS get_quantity9    FOR TESTING.
    METHODS rounded1         FOR TESTING.
    METHODS rounded2         FOR TESTING.
    METHODS rounded3         FOR TESTING.
    METHODS add1             FOR TESTING.
    METHODS add2             FOR TESTING.
    METHODS add3             FOR TESTING.
    METHODS to_string1       FOR TESTING.
    METHODS to_string2       FOR TESTING.
    METHODS to_string3       FOR TESTING.
    METHODS to_string4       FOR TESTING.
    METHODS to_string5       FOR TESTING.
    METHODS to_string6       FOR TESTING.
    METHODS equal1           FOR TESTING.
    METHODS equal2           FOR TESTING.
    METHODS equal3           FOR TESTING.
    METHODS equal4           FOR TESTING.
    METHODS rounded4         FOR TESTING.
    METHODS rounded5         FOR TESTING.
    METHODS rounded6         FOR TESTING.

ENDCLASS.


CLASS ltcl_quantity IMPLEMENTATION.
  METHOD get_quantity1.
    TRY.
        cut = NEW #( i_quantity = 15
                     i_uom      = NEW #( 'M' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '15'
                                            act = cut->get_quantity( ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_quantity2.
    TRY.
        cut = NEW #( i_quantity = 15
                     i_uom      = NEW #( 'm' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '15000'
                                            act = cut->get_quantity( NEW #( 'mm' ) ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD negative.
    TRY.
        cut = NEW #( i_quantity = '-12.123'
                     i_uom      = NEW #( 'm' ) ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_value_object INTO e.
        cl_abap_unit_assert=>assert_equals( exp = 'Quantity -12,123 is not valid'
                                            act = e->get_text( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD different_dimms1.
    TRY.
        cut = NEW #( i_quantity = '12.123'
                     i_uom      = NEW #( 'm' ) ).
        DATA(other) = NEW zcl_vo_quantity( i_quantity = 15
                                           i_uom      = NEW #( 'kg' ) ).
        cut->add( other ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_value_object INTO e.
        cl_abap_unit_assert=>assert_equals( exp = 'Dimensions of KG and M are different'
                                            act = e->get_text( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD different_dimms2.
    TRY.
        cut = NEW #( i_quantity = '12.123'
                     i_uom      = NEW #( 'm' ) ).
        cut->get_quantity( NEW #( 'kg' ) ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_value_object INTO e.
        cl_abap_unit_assert=>assert_equals( exp = 'Dimensions of M and KG are different'
                                            act = e->get_text( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD different_dimms3.
    TRY.
        cut = NEW #( i_quantity = '12.123'
                     i_uom      = NEW #( 'm' ) ).
        DATA(other) = NEW zcl_vo_quantity( i_quantity = 15
                                           i_uom      = NEW #( 'kg' ) ).
        cut->gt( other ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_value_object INTO e.
        cl_abap_unit_assert=>assert_equals( exp = 'Dimensions of KG and M are different'
                                            act = e->get_text( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_quantity4.
    TRY.
        cut = NEW #( i_quantity = 15
                     i_uom      = NEW #( 'cm' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '0.15'
                                            act = cut->get_quantity( NEW #( 'm' ) ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_quantity5.
    TRY.
        cut = NEW #( i_quantity = '152324123456.321654'
                     i_uom      = NEW #( 'km' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '152324123456321654000'
                                            act = cut->get_quantity( NEW #( 'MIM' ) ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_quantity6.
    TRY.
        cut = NEW #( i_quantity = '0.0000000123456'
                     i_uom      = NEW #( 'mim' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '0.0000000000000000123456'
                                            act = cut->get_quantity( NEW #( 'km' ) ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_quantity7.
    TRY.
        cut = NEW #( i_quantity = 15
                     i_uom      = NEW #( 'm' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '590.5511811023622047244094488188976'
                                            act = cut->get_quantity( NEW #( 'in' ) ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_quantity8.
    TRY.
        cut = NEW #( i_quantity = 15
                     i_uom      = NEW #( 'cm' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '0.00009320567883560009544261512765449773'
                                            act = cut->get_quantity( NEW #( 'mi' ) ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_quantity9.
    TRY.
        cut = NEW #( i_quantity = '6.2'
                     i_uom      = NEW #( 'ft' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '188.976'
                                            act = cut->get_quantity( NEW #( 'cm' ) ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD rounded1.
    TRY.
        cut = NEW #( i_quantity = '6.2'
                     i_uom      = NEW #( 'ft' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '189'
                                            act = cut->get_quantity_rounded( i_uom      = NEW #( 'cm' )
                                                                             i_decimals = 0 ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD rounded2.
    TRY.
        cut = NEW #( i_quantity = 15
                     i_uom      = NEW #( 'm' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '590.551'
                                            act = cut->get_quantity_rounded( i_uom = NEW #( 'in' ) ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD rounded3.
    TRY.
        cut = NEW #( i_quantity = 15
                     i_uom      = NEW #( 'cm' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '0.00009320567883560009544261512765449773'
                                            act = cut->get_quantity_rounded( i_uom      = NEW #( 'mi' )
                                                                             i_decimals = 60 ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD rounded4.
    TRY.
        cut = NEW #( i_quantity = 1553
                     i_uom      = NEW #( 'm' ) ).
        cl_abap_unit_assert=>assert_equals( exp = 1600
                                            act = cut->get_quantity_rounded( i_uom       = NEW #( 'm' )
                                                                             i_precision = 2 ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD rounded5.
    TRY.
        cut = NEW #( i_quantity = 1553
                     i_uom      = NEW #( 'km' ) ).
        cl_abap_unit_assert=>assert_equals( exp = 1553
                                            act = cut->get_quantity_rounded( i_uom       = NEW #( 'km' )
                                                                             i_precision = 200 ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD rounded6.
    TRY.
        cut = NEW #( i_quantity = '1553.32742'
                     i_uom      = NEW #( 'm' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '1553.33'
                                            act = cut->get_quantity_rounded( i_uom       = NEW #( 'm' )
                                                                             i_precision = 6 ) ).
        cl_abap_unit_assert=>assert_equals( exp = '1553.33'
                                            act = cut->get_quantity_rounded( i_uom       = NEW #( 'm' )
                                                                             i_decimals  = 14
                                                                             i_precision = 6 ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD add1.
    TRY.
        cut = NEW #( i_quantity = 15
                     i_uom      = NEW #( 'm' ) ).
        DATA(to_add) = NEW zcl_vo_quantity( i_quantity = 15
                                            i_uom      = NEW #( 'm' ) ).
        cut = cut->add( to_add ).
        cl_abap_unit_assert=>assert_equals( exp = '30'
                                            act = cut->get_quantity( i_uom = NEW #( 'M' ) ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD add2.
    TRY.
        cut = NEW #( i_quantity = 15
                     i_uom      = NEW #( 'mm' ) ).
        DATA(to_add) = NEW zcl_vo_quantity( i_quantity = 15
                                            i_uom      = NEW #( 'm' ) ).
        cut = cut->add( to_add ).
        cl_abap_unit_assert=>assert_equals( exp = '0.015015'
                                            act = cut->get_quantity( i_uom = NEW #( 'km' ) ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD add3.
    TRY.
        cut = NEW #( i_quantity = 15
                     i_uom      = NEW #( 'mm' ) ).
        DATA(to_add) = NEW zcl_vo_quantity( i_quantity = 0
                                            i_uom      = NEW #( 'm' ) ).
        cut = cut->add( to_add ).
        cl_abap_unit_assert=>assert_equals( exp = '0.000015'
                                            act = cut->get_quantity( i_uom = NEW #( 'km' ) ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD to_string1.
    TRY.
        cut = NEW #( i_quantity = 15
                     i_uom      = NEW #( 'm' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '15'
                                            act = cut->to_string( ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD to_string2.
    TRY.
        cut = NEW #( i_quantity = 0
                     i_uom      = NEW #( 'km' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '0'
                                            act = cut->to_string( ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD to_string3.
    TRY.
        cut = NEW #( i_quantity = 15
                     i_uom      = NEW #( 'km' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '15 KM'
                                            act = cut->to_string_with_uom( ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD to_string4.
    TRY.
        cut = NEW #( i_quantity = 150
                     i_uom      = NEW #( 'cm' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '1,5 M'
                                            act = cut->to_string_with_uom( i_uom = NEW #( 'm' ) ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD to_string5.
    TRY.
        cut = NEW #( i_quantity = '0.00'
                     i_uom      = NEW #( 'm' ) ).
        cl_abap_unit_assert=>assert_equals( exp = ''
                                            act = cut->to_string_empty_for_zero( i_uom = NEW #( 'km' ) ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD to_string6.
    TRY.
        cut = NEW #( i_quantity = '0.00'
                     i_uom      = NEW #( 'km' ) ).
        cl_abap_unit_assert=>assert_equals( exp = ''
                                            act = cut->to_string_empty_for_zero( ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD equal1.
    TRY.
        cut = NEW #( i_quantity = 15
                     i_uom      = NEW #( 'km' ) ).
        DATA(other) = NEW zcl_vo_quantity( i_quantity = 15
                                           i_uom      = NEW #( 'km' ) ).
        cl_abap_unit_assert=>assert_true( cut->is_equal( other ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD equal2.
    TRY.
        cut = NEW #( i_quantity = 15
                     i_uom      = NEW #( 'km' ) ).
        DATA(other) = NEW zcl_vo_quantity( i_quantity = 15
                                           i_uom      = NEW #( 'm' ) ).
        cl_abap_unit_assert=>assert_false( cut->is_equal( other ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD equal3.
    TRY.
        cut = NEW #( i_quantity = 1
                     i_uom      = NEW #( 'm' ) ).
        DATA(other) = NEW zcl_vo_quantity( i_quantity = 100
                                           i_uom      = NEW #( 'cm' ) ).
        cl_abap_unit_assert=>assert_true( cut->is_equal( other ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD equal4.
    TRY.
        cut = NEW #( i_quantity = 15
                     i_uom      = NEW #( 'cm' ) ).
        DATA(other) = NEW zcl_vo_quantity( i_quantity = '0.00009320567883560009544261512765449773'
                                           i_uom      = NEW #( 'mi' ) ).
        cl_abap_unit_assert=>assert_true( cut->is_equal( other ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
