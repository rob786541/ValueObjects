CLASS ltcl_length DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    DATA cut TYPE REF TO zcl_vo_length.
    DATA e   TYPE REF TO zcx_value_object.

    METHODS get_length1 FOR TESTING.
    METHODS get_length2 FOR TESTING.
    METHODS negative    FOR TESTING.
    METHODS wrong_uom   FOR TESTING.
    METHODS get_length4 FOR TESTING.
    METHODS get_length5 FOR TESTING.
    METHODS get_length6 FOR TESTING.
    METHODS get_length7 FOR TESTING.
    METHODS get_length8 FOR TESTING.
    METHODS get_length9 FOR TESTING.
    METHODS rounded1    FOR TESTING.
    METHODS rounded2    FOR TESTING.
    METHODS rounded3    FOR TESTING.
    METHODS add1        FOR TESTING.
    METHODS add2        FOR TESTING.
    METHODS add3        FOR TESTING.
    METHODS to_string1  FOR TESTING.
    METHODS to_string2  FOR TESTING.
    METHODS to_string3  FOR TESTING.
    METHODS to_string4  FOR TESTING.
    METHODS to_string5  FOR TESTING.
    METHODS to_string6  FOR TESTING.
    METHODS equal1      FOR TESTING.
    METHODS equal2      FOR TESTING.
    METHODS equal3      FOR TESTING.
    METHODS equal4      FOR TESTING.
    METHODS rounded4    FOR TESTING.
    METHODS rounded5    FOR TESTING.
    METHODS rounded6    FOR TESTING.

ENDCLASS.


CLASS ltcl_length IMPLEMENTATION.
  METHOD get_length1.
    TRY.
        cut = NEW #( i_length = 15
                     i_uom    = NEW #( 'M' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '15'
                                            act = cut->get_length( ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_length2.
    TRY.
        cut = NEW #( i_length = 15
                     i_uom    = NEW #( 'm' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '15000'
                                            act = cut->get_length( NEW #( 'mm' ) ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD negative.
    TRY.
        cut = NEW #( i_length = '-12.123'
                     i_uom    = NEW #( 'm' ) ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_value_object INTO e.
        cl_abap_unit_assert=>assert_equals( exp = 'Length -12,123 is not valid'
                                            act = e->get_text( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD wrong_uom.
    TRY.
        cut = NEW #( i_length = '12'
                     i_uom    = NEW #( 'kg' ) ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_value_object INTO e.
        cl_abap_unit_assert=>assert_equals( exp = 'UOM KG is not a valid length dimension'
                                            act = e->get_text( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_length4.
    TRY.
        cut = NEW #( i_length = 15
                     i_uom    = NEW #( 'cm' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '0.15'
                                            act = cut->get_length( NEW #( 'm' ) ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_length5.
    TRY.
        cut = NEW #( i_length = '152324123456.321654'
                     i_uom    = NEW #( 'km' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '152324123456321654000'
                                            act = cut->get_length( NEW #( 'MIM' ) ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_length6.
    TRY.
        cut = NEW #( i_length = '0.0000000123456'
                     i_uom    = NEW #( 'mim' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '0.0000000000000000123456'
                                            act = cut->get_length( NEW #( 'km' ) ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_length7.
    TRY.
        cut = NEW #( i_length = 15
                     i_uom    = NEW #( 'm' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '590.5511811023622047244094488188976'
                                            act = cut->get_length( NEW #( 'in' ) ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_length8.
    TRY.
        cut = NEW #( i_length = 15
                     i_uom    = NEW #( 'cm' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '0.00009320567883560009544261512765449773'
                                            act = cut->get_length( NEW #( 'mi' ) ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_length9.
    TRY.
        cut = NEW #( i_length = '6.2'
                     i_uom    = NEW #( 'ft' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '188.976'
                                            act = cut->get_length( NEW #( 'cm' ) ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD rounded1.
    TRY.
        cut = NEW #( i_length = '6.2'
                     i_uom    = NEW #( 'ft' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '189'
                                            act = cut->get_length_rounded( i_uom      = NEW #( 'cm' )
                                                                           i_decimals = 0 ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD rounded2.
    TRY.
        cut = NEW #( i_length = 15
                     i_uom    = NEW #( 'm' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '590.551'
                                            act = cut->get_length_rounded( i_uom = NEW #( 'in' ) ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD rounded3.
    TRY.
        cut = NEW #( i_length = 15
                     i_uom    = NEW #( 'cm' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '0.00009320567883560009544261512765449773'
                                            act = cut->get_length_rounded( i_uom      = NEW #( 'mi' )
                                                                           i_decimals = 60 ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD rounded4.
    TRY.
        cut = NEW #( i_length = 1553
                     i_uom    = NEW #( 'm' ) ).
        cl_abap_unit_assert=>assert_equals( exp = 1600
                                            act = cut->get_length_rounded( i_uom       = NEW #( 'm' )
                                                                           i_precision = 2 ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD rounded5.
    TRY.
        cut = NEW #( i_length = 1553
                     i_uom    = NEW #( 'km' ) ).
        cl_abap_unit_assert=>assert_equals( exp = 1553
                                            act = cut->get_length_rounded( i_uom       = NEW #( 'km' )
                                                                           i_precision = 200 ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD rounded6.
    TRY.
        cut = NEW #( i_length = '1553.32742'
                     i_uom    = NEW #( 'm' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '1553.33'
                                            act = cut->get_length_rounded( i_uom       = NEW #( 'm' )
                                                                           i_precision = 6 ) ).
        cl_abap_unit_assert=>assert_equals( exp = '1553.33'
                                            act = cut->get_length_rounded( i_uom       = NEW #( 'm' )
                                                                           i_decimals  = 14
                                                                           i_precision = 6 ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD add1.
    TRY.
        cut = NEW #( i_length = 15
                     i_uom    = NEW #( 'm' ) ).
        DATA(to_add) = NEW zcl_vo_length( i_length = 15
                                          i_uom    = NEW #( 'm' ) ).
        cut = cut->add( to_add ).
        cl_abap_unit_assert=>assert_equals( exp = '30'
                                            act = cut->get_length( i_uom = NEW #( 'M' ) ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD add2.
    TRY.
        cut = NEW #( i_length = 15
                     i_uom    = NEW #( 'mm' ) ).
        DATA(to_add) = NEW zcl_vo_length( i_length = 15
                                          i_uom    = NEW #( 'm' ) ).
        cut = cut->add( to_add ).
        cl_abap_unit_assert=>assert_equals( exp = '0.015015'
                                            act = cut->get_length( i_uom = NEW #( 'km' ) ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD add3.
    TRY.
        cut = NEW #( i_length = 15
                     i_uom    = NEW #( 'mm' ) ).
        DATA(to_add) = NEW zcl_vo_length( i_length = 0
                                          i_uom    = NEW #( 'm' ) ).
        cut = cut->add( to_add ).
        cl_abap_unit_assert=>assert_equals( exp = '0.000015'
                                            act = cut->get_length( i_uom = NEW #( 'km' ) ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD to_string1.
    TRY.
        cut = NEW #( i_length = 15
                     i_uom    = NEW #( 'm' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '15'
                                            act = cut->to_string( ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD to_string2.
    TRY.
        cut = NEW #( i_length = 0
                     i_uom    = NEW #( 'km' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '0'
                                            act = cut->to_string( ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD to_string3.
    TRY.
        cut = NEW #( i_length = 15
                     i_uom    = NEW #( 'km' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '15 KM'
                                            act = cut->to_string_with_uom( ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD to_string4.
    TRY.
        cut = NEW #( i_length = 150
                     i_uom    = NEW #( 'cm' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '1,5 M'
                                            act = cut->to_string_with_uom( i_uom = NEW #( 'm' ) ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD to_string5.
    TRY.
        cut = NEW #( i_length = '0.00'
                     i_uom    = NEW #( 'm' ) ).
        cl_abap_unit_assert=>assert_equals( exp = ''
                                            act = cut->to_string_empty_for_zero( i_uom = NEW #( 'km' ) ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD to_string6.
    TRY.
        cut = NEW #( i_length = '0.00'
                     i_uom    = NEW #( 'km' ) ).
        cl_abap_unit_assert=>assert_equals( exp = ''
                                            act = cut->to_string_empty_for_zero( ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD equal1.
    TRY.
        cut = NEW #( i_length = 15
                     i_uom    = NEW #( 'km' ) ).
        DATA(other) = NEW zcl_vo_length( i_length = 15
                                         i_uom    = NEW #( 'km' ) ).
        cl_abap_unit_assert=>assert_true( cut->is_equal( other ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD equal2.
    TRY.
        cut = NEW #( i_length = 15
                     i_uom    = NEW #( 'km' ) ).
        DATA(other) = NEW zcl_vo_length( i_length = 15
                                         i_uom    = NEW #( 'm' ) ).
        cl_abap_unit_assert=>assert_false( cut->is_equal( other ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD equal3.
    TRY.
        cut = NEW #( i_length = 1
                     i_uom    = NEW #( 'm' ) ).
        DATA(other) = NEW zcl_vo_length( i_length = 100
                                         i_uom    = NEW #( 'cm' ) ).
        cl_abap_unit_assert=>assert_true( cut->is_equal( other ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD equal4.
    TRY.
        cut = NEW #( i_length = 15
                     i_uom    = NEW #( 'cm' ) ).
        DATA(other) = NEW zcl_vo_length( i_length = '0.00009320567883560009544261512765449773'
                                         i_uom    = NEW #( 'mi' ) ).
        cl_abap_unit_assert=>assert_true( cut->is_equal( other ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
