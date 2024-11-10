CLASS ltcl_quantity_material DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    TYPES tty_alternatives TYPE STANDARD TABLE OF I_ProductAlternativeUoM WITH EMPTY KEY.
    TYPES tty_product      TYPE SORTED TABLE OF i_product WITH UNIQUE KEY product.

    DATA cut TYPE REF TO zcl_vo_quantity_material.
    DATA e   TYPE REF TO zcx_value_object.

    METHODS constructor1 FOR TESTING.
    METHODS kar1         FOR TESTING.
    METHODS kar2         FOR TESTING.
    METHODS kar3         FOR TESTING.
    METHODS kg1          FOR TESTING.
    METHODS kar_kg1      FOR TESTING.
    METHODS kar_l1       FOR TESTING.

    CLASS-METHODS class_setup.

ENDCLASS.


CLASS ltcl_quantity_material IMPLEMENTATION.
  METHOD class_setup.
    DATA(double) = cl_osql_test_environment=>create( VALUE #( ( 'I_PRODUCTALTERNATIVEUOM' ) ( 'I_PRODUCT' ) ) ).
    double->insert_test_data(
        VALUE tty_alternatives( Product = '4711'
                                ( AlternativeUnit = 'KAR' QuantityNumerator = '10' QuantityDenominator = '1' )
                                ( AlternativeUnit = 'ST' QuantityNumerator = '1' QuantityDenominator = '1' )
                                ( AlternativeUnit = 'KG' QuantityNumerator = '12' QuantityDenominator = '14' ) ) ).
    double->insert_test_data( VALUE tty_product( ( product = '4711' BaseUnit = 'ST' ) ) ).
  ENDMETHOD.

  METHOD constructor1.
    TRY.
        cut = NEW #( i_quantity = '20'
                     i_material = '4711'
                     i_uom      = NEW #( 'ST' ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD kar1.
    TRY.
        cut = NEW #( i_quantity = '20'
                     i_material = '4711'
                     i_uom      = NEW #( 'ST' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '2'
                                            act = cut->get_quantity( NEW #( 'CAR' ) ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD kar2.
    TRY.
        cut = NEW #( i_quantity = '20'
                     i_material = '4711'
                     i_uom      = NEW #( 'car' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '20'
                                            act = cut->get_quantity( ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD kar3.
    TRY.
        cut = NEW #( i_quantity = '20'
                     i_material = '4711'
                     i_uom      = NEW #( 'car' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '200'
                                            act = cut->get_quantity( NEW #( 'ST' ) ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD kg1.
    TRY.
        cut = NEW #( i_quantity = '12'
                     i_material = '4711'
                     i_uom      = NEW #( 'ST' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '14'
                                            act = cut->get_quantity( NEW #( 'kg' ) ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD kar_kg1.
    TRY.
        cut = NEW #( i_quantity = '120'
                     i_material = '4711'
                     i_uom      = NEW #( 'KAR' ) ).
        cl_abap_unit_assert=>assert_equals( exp = '1400'
                                            act = cut->get_quantity( NEW #( 'kg' ) ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD kar_l1.
    TRY.
        cut = NEW #( i_quantity = '120'
                     i_material = '4711'
                     i_uom      = NEW #( 'KAR' ) ).
        cut->get_quantity( NEW #( 'l' ) ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_value_object INTO e.
        cl_abap_unit_assert=>assert_equals( exp = 'UoM L for material 4711 not valid'
                                            act = e->get_text( ) ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
