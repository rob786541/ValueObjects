CLASS zcl_vo_length DEFINITION PUBLIC INHERITING FROM zcl_value_object FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING i_length TYPE decfloat34
                i_uom    TYPE REF TO zcl_vo_uom
      RAISING   zcx_value_object.

    METHODS to_string REDEFINITION.

    METHODS to_string_with_uom
      IMPORTING i_uom           TYPE REF TO zcl_vo_uom OPTIONAL
      RETURNING VALUE(r_result) TYPE string
      RAISING   zcx_value_object.

    METHODS to_string_empty_for_zero
      IMPORTING i_uom           TYPE REF TO zcl_vo_uom OPTIONAL
      RETURNING VALUE(r_result) TYPE string
      RAISING   zcx_value_object.

    METHODS add
      IMPORTING i_length        TYPE REF TO zcl_vo_length
      RETURNING VALUE(r_result) TYPE REF TO zcl_vo_length.

    METHODS get_length
      IMPORTING i_uom           TYPE REF TO zcl_vo_uom OPTIONAL
      RETURNING VALUE(r_result) TYPE decfloat34
      RAISING   zcx_value_object.

    METHODS get_length_rounded
      IMPORTING i_uom           TYPE REF TO zcl_vo_uom OPTIONAL
                i_precision     TYPE i                 DEFAULT 0
                i_decimals      TYPE i                 DEFAULT 3
      RETURNING VALUE(r_result) TYPE decfloat34
      RAISING   zcx_value_object.

  PROTECTED SECTION.
    METHODS create_hash REDEFINITION.
    METHODS is_valid    REDEFINITION.

  PRIVATE SECTION.
    DATA length TYPE decfloat34.
    DATA uom    TYPE REF TO zcl_vo_uom.

    METHODS check_uom_is_length_dimension
      IMPORTING i_uom TYPE REF TO zcl_vo_uom
      RAISING   zcx_value_object.
ENDCLASS.


CLASS zcl_vo_length IMPLEMENTATION.
  METHOD constructor.
    super->constructor( ).
    uom = i_uom.
    length = i_length.
    check_uom_is_length_dimension( i_uom ).
    IF NOT is_valid( ).
      RAISE EXCEPTION TYPE zcx_value_object MESSAGE e009(z_value_object) WITH to_string( ).
    ENDIF.
  ENDMETHOD.

  METHOD create_hash.
    TRY.
        DATA(si) = |{ get_length( NEW #( 'm' ) ) NUMBER = RAW }|.
        add_to_hash( REF #( si ) ).
        r_result = build_hash( ).
      CATCH zcx_value_object.
        RAISE SHORTDUMP NEW cx_sy_create_object_error( ).
    ENDTRY.
  ENDMETHOD.

  METHOD is_valid.
    r_result = xsdbool( length >= 0 ).
  ENDMETHOD.

  METHOD check_uom_is_length_dimension.
    IF NOT is_dimension( i_dimid = 'LENGTH'
                         i_msehi = i_uom->get_in( ) ).
      RAISE EXCEPTION TYPE zcx_value_object MESSAGE e005(z_value_object) WITH i_uom->to_string( ).
    ENDIF.
  ENDMETHOD.

  METHOD get_length.
    IF i_uom IS NOT BOUND OR uom->is_equal( i_uom ).
      r_result = length.
      RETURN.
    ENDIF.
    check_uom_is_length_dimension( i_uom ).

    CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
      EXPORTING  input         = length
                 unit_in       = uom->get_in( )
                 unit_out      = i_uom->get_in( )
      IMPORTING  output        = r_result
      EXCEPTIONS error_message = 98
                 OTHERS        = 99.
    ASSERT sy-subrc = 0.
  ENDMETHOD.

  METHOD get_length_rounded.
    ASSERT i_decimals >= 0 AND i_precision >= 0.
    IF i_precision > 0.
      r_result = round( val  = get_length( i_uom = i_uom )
                        prec = i_precision ).
    ELSE.
      r_result = round( val = get_length( i_uom = i_uom )
                        dec = i_decimals ).
    ENDIF.
  ENDMETHOD.

  METHOD to_string.
    r_result = conv_to_string( length ).
  ENDMETHOD.

  METHOD add.
    ASSERT i_length IS BOUND.
    TRY.
        r_result = NEW #( i_length = length + i_length->get_length( uom )
                          i_uom    = uom ).
      CATCH zcx_value_object.
        RAISE SHORTDUMP NEW cx_sy_create_object_error( ).
    ENDTRY.
  ENDMETHOD.

  METHOD to_string_empty_for_zero.
    DATA(l_uom) = COND #( WHEN i_uom IS BOUND THEN i_uom ELSE uom ).
    r_result = conv_to_string( i_return_empty_for_zero = abap_true
                               i_value                 = get_length( l_uom ) ).
  ENDMETHOD.

  METHOD to_string_with_uom.
    DATA(l_uom) = COND #( WHEN i_uom IS BOUND THEN i_uom ELSE uom ).
    r_result = |{ conv_to_string( get_length( l_uom ) ) } { l_uom->get_out( ) }|.
  ENDMETHOD.
ENDCLASS.
