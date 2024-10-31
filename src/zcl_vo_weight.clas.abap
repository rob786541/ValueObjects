CLASS zcl_vo_weight DEFINITION PUBLIC INHERITING FROM zcl_value_object FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING i_weight TYPE decfloat34
                i_uom    TYPE REF TO zcl_vo_uom
      RAISING   zcx_value_object.

    METHODS as_str_in
      IMPORTING i_return_empty_for_zero TYPE abap_bool         DEFAULT abap_true
                i_uom                   TYPE REF TO zcl_vo_uom OPTIONAL
      RETURNING VALUE(r_result)         TYPE string
      RAISING   zcx_value_object.

    METHODS as_str_with_uom_in
      IMPORTING i_return_empty_for_zero TYPE abap_bool         DEFAULT abap_true
                i_uom                   TYPE REF TO zcl_vo_uom OPTIONAL
      RETURNING VALUE(r_result)         TYPE string
      RAISING   zcx_value_object.

    METHODS add
      IMPORTING i_weight        TYPE REF TO zcl_vo_weight
      RETURNING VALUE(r_result) TYPE REF TO zcl_vo_weight.

    METHODS gt
      IMPORTING i_weight        TYPE REF TO zcl_vo_weight
      RETURNING VALUE(r_result) TYPE abap_bool.

    METHODS get_weight_in
      IMPORTING i_uom           TYPE REF TO zcl_vo_uom OPTIONAL
      RETURNING VALUE(r_result) TYPE decfloat34
      RAISING   zcx_value_object.

    METHODS get_weight_in_rounded
      IMPORTING i_uom           TYPE REF TO zcl_vo_uom OPTIONAL
                i_decimals      TYPE i                 DEFAULT 3
      RETURNING VALUE(r_result) TYPE decfloat34
      RAISING   zcx_value_object.

    METHODS get_uom
      RETURNING VALUE(r_result) TYPE REF TO zcl_vo_uom.

  PROTECTED SECTION.
    METHODS create_hash REDEFINITION.
    METHODS is_valid    REDEFINITION.

  PRIVATE SECTION.
    DATA weight TYPE decfloat34.
    DATA uom    TYPE REF TO zcl_vo_uom.

    METHODS check_uom_is_mass_dimension
      IMPORTING i_uom TYPE REF TO zcl_vo_uom
      RAISING   zcx_value_object.

    METHODS conv_to_string
      IMPORTING i_return_empty_for_zero TYPE abap_bool
                i_weight                TYPE decfloat34
      RETURNING VALUE(r_result)         TYPE string.

ENDCLASS.


CLASS zcl_vo_weight IMPLEMENTATION.
  METHOD create_hash.
    add_to_hash( REF #( weight ) ).
    add_to_hash( REF #( uom ) ).
    r_result = build_hash( ).
  ENDMETHOD.

  METHOD get_weight_in.
    IF i_uom IS NOT BOUND OR uom->is_equal_to( i_uom ).
      r_result = weight.
      RETURN.
    ENDIF.
    check_uom_is_mass_dimension( i_uom ).

    CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
      EXPORTING  input         = weight
                 unit_in       = uom->get_in( )
                 unit_out      = i_uom->get_in( )
      IMPORTING  output        = r_result
      EXCEPTIONS error_message = 98
                 OTHERS        = 99.
  ENDMETHOD.

  METHOD get_weight_in_rounded.
    ASSERT i_decimals >= 0.
    r_result = round( val = get_weight_in( i_uom = i_uom )
                      dec = i_decimals ).
  ENDMETHOD.

  METHOD as_str_in.
    r_result = conv_to_string( i_weight                = get_weight_in( i_uom )
                               i_return_empty_for_zero = i_return_empty_for_zero ).
  ENDMETHOD.

  METHOD add.
    ASSERT i_weight IS BOUND.
    TRY.
        r_result = NEW #( i_weight = weight + i_weight->get_weight_in( uom )
                          i_uom    = uom ).
      CATCH zcx_value_object.
        RAISE SHORTDUMP NEW cx_sy_create_object_error( ).
    ENDTRY.
  ENDMETHOD.

  METHOD as_str_with_uom_in.
    r_result = |{ as_str_in( i_return_empty_for_zero = i_return_empty_for_zero
                             i_uom                   = i_uom ) } { i_uom->get_out( ) }|.
  ENDMETHOD.

  METHOD constructor.
    super->constructor( ).
    uom = i_uom.
    weight = i_weight.
    check_uom_is_mass_dimension( i_uom ).
  ENDMETHOD.

  METHOD get_uom.
    r_result = uom.
  ENDMETHOD.

  METHOD gt.
    ASSERT i_weight IS BOUND.
    TRY.
        r_result = xsdbool( weight > i_weight->get_weight_in( uom ) ).
      CATCH zcx_value_object.
        RAISE SHORTDUMP NEW cx_sy_create_object_error( ).
    ENDTRY.
  ENDMETHOD.

  METHOD is_valid.
    r_result = abap_true.
  ENDMETHOD.

  METHOD conv_to_string.
    IF i_weight = 0 AND i_return_empty_for_zero = abap_true.
      RETURN.
    ENDIF.
    IF i_weight = round( val = i_weight
                         dec = 0 ).
      r_result = |{ i_weight DECIMALS = 0 NUMBER = USER }|. " display decimals only when necessary
    ELSE.
      r_result = |{ i_weight NUMBER = USER }|.
    ENDIF.
  ENDMETHOD.

  METHOD check_uom_is_mass_dimension.
    IF NOT i_uom->is_mass_dimension( ).
      RAISE EXCEPTION TYPE zcx_value_object MESSAGE e004(z_value_object) WITH CONV string( i_uom->get_out( ) ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
