CLASS zcl_vo_quantity DEFINITION PUBLIC INHERITING FROM zcl_value_object CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS class_constructor.

    METHODS constructor
      IMPORTING i_quantity TYPE decfloat34
                i_uom      TYPE REF TO zcl_vo_uom
      RAISING   zcx_value_object.

    METHODS to_string_with_uom
      IMPORTING i_uom           TYPE REF TO zcl_vo_uom OPTIONAL
      RETURNING VALUE(r_result) TYPE string
      RAISING   zcx_value_object.

    METHODS to_string_empty_for_zero
      IMPORTING i_uom           TYPE REF TO zcl_vo_uom OPTIONAL
      RETURNING VALUE(r_result) TYPE string
      RAISING   zcx_value_object.

    METHODS add
      IMPORTING i_quantity      TYPE REF TO zcl_vo_quantity
      RETURNING VALUE(r_result) TYPE REF TO zcl_vo_quantity
      RAISING   zcx_value_object.

    METHODS gt
      IMPORTING i_quantity      TYPE REF TO zcl_vo_quantity
      RETURNING VALUE(r_result) TYPE abap_bool
      RAISING   zcx_value_object.

    METHODS get_quantity
      IMPORTING i_uom           TYPE REF TO zcl_vo_uom OPTIONAL
      RETURNING VALUE(r_result) TYPE decfloat34
      RAISING   zcx_value_object.

    METHODS get_quantity_rounded
      IMPORTING i_uom           TYPE REF TO zcl_vo_uom OPTIONAL
                i_precision     TYPE i                 DEFAULT 0
                i_decimals      TYPE i                 DEFAULT 3
      RETURNING VALUE(r_result) TYPE decfloat34
      RAISING   zcx_value_object.

    METHODS get_uom
      RETURNING VALUE(r_result) TYPE REF TO zcl_vo_uom.

    METHODS to_string REDEFINITION.

  PROTECTED SECTION.
    METHODS create_hash REDEFINITION.
    METHODS is_valid    REDEFINITION.

  PRIVATE SECTION.
    DATA quantity TYPE decfloat34.
    DATA uom      TYPE REF TO zcl_vo_uom.

    CLASS-DATA uom_conversion TYPE REF TO cl_uom_conversion.

    METHODS check_is_dimension_equal
      IMPORTING i_uom TYPE REF TO zcl_vo_uom
      RAISING   zcx_value_object.

    METHODS check_dimension_supported
      RAISING zcx_value_object.

ENDCLASS.


CLASS zcl_vo_quantity IMPLEMENTATION.
  METHOD create_hash.
    TRY.
        FINAL(si) = |{ get_quantity( NEW #( uom->get_si_unit( ) ) ) NUMBER = RAW }|.
        add_to_hash( REF #( si ) ).
        r_result = build_hash( ).
      CATCH zcx_value_object.
        RAISE SHORTDUMP NEW cx_sy_create_object_error( ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_quantity.
    IF i_uom IS NOT BOUND OR uom->is_equal( i_uom ).
      r_result = quantity.
      RETURN.
    ENDIF.
    check_is_dimension_equal( i_uom ).
    uom_conversion->unit_conversion_simple( EXPORTING  input    = quantity
                                                       unit_in  = uom->get_in( )
                                                       unit_out = i_uom->get_in( )
                                            IMPORTING  output   = r_result
                                            EXCEPTIONS OTHERS   = 99 ).
    ASSERT sy-subrc = 0.
  ENDMETHOD.

  METHOD get_quantity_rounded.
    ASSERT i_decimals >= 0 AND i_precision >= 0.
    IF i_precision > 0.
      r_result = round( val  = get_quantity( i_uom = i_uom )
                        prec = i_precision ).
    ELSE.
      r_result = round( val = get_quantity( i_uom = i_uom )
                        dec = i_decimals ).
    ENDIF.
  ENDMETHOD.

  METHOD add.
    ASSERT i_quantity IS BOUND.
    r_result = NEW #( i_quantity = quantity + i_quantity->get_quantity( uom )
                      i_uom      = uom ).
  ENDMETHOD.

  METHOD to_string_with_uom.
    FINAL(l_uom) = COND #( WHEN i_uom IS BOUND THEN i_uom ELSE uom ).
    r_result = |{ conv_to_string( get_quantity( l_uom ) ) } { l_uom->get_out( ) }|.
  ENDMETHOD.

  METHOD constructor.
    super->constructor( ).
    uom = i_uom.
    quantity = i_quantity.
    check_dimension_supported( ).
    IF NOT is_valid( ).
      RAISE EXCEPTION TYPE zcx_value_object MESSAGE e013(z_value_object) WITH to_string( ).
    ENDIF.
  ENDMETHOD.

  METHOD get_uom.
    r_result = uom.
  ENDMETHOD.

  METHOD gt.
    ASSERT i_quantity IS BOUND.
    r_result = xsdbool( quantity > i_quantity->get_quantity( uom ) ).
  ENDMETHOD.

  METHOD is_valid.
    r_result = xsdbool( quantity >= 0 ).
  ENDMETHOD.

  METHOD to_string.
    r_result = conv_to_string( quantity ).
  ENDMETHOD.

  METHOD to_string_empty_for_zero.
    FINAL(l_uom) = COND #( WHEN i_uom IS BOUND THEN i_uom ELSE uom ).
    r_result = conv_to_string( i_return_empty_for_zero = abap_true
                               i_value                 = get_quantity( l_uom ) ).
  ENDMETHOD.

  METHOD check_is_dimension_equal.
    IF uom->get_dimension( ) <> i_uom->get_dimension( ).
      RAISE EXCEPTION TYPE zcx_value_object MESSAGE e011(z_value_object) WITH uom->to_string( ) i_uom->to_string( ).
    ENDIF.
  ENDMETHOD.

  METHOD check_dimension_supported.
    IF uom->get_si_unit( ) IS INITIAL.
      RAISE EXCEPTION TYPE zcx_value_object MESSAGE e012(z_value_object) WITH uom->get_dimension( ).
    ENDIF.
  ENDMETHOD.

  METHOD class_constructor.
    uom_conversion = NEW #( ).
  ENDMETHOD.
ENDCLASS.
