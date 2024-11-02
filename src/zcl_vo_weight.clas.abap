CLASS zcl_vo_weight DEFINITION PUBLIC INHERITING FROM zcl_value_object FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING i_weight TYPE decfloat34
                i_uom    TYPE REF TO zcl_vo_uom
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
      IMPORTING i_weight        TYPE REF TO zcl_vo_weight
      RETURNING VALUE(r_result) TYPE REF TO zcl_vo_weight.

    METHODS gt
      IMPORTING i_weight        TYPE REF TO zcl_vo_weight
      RETURNING VALUE(r_result) TYPE abap_bool.

    METHODS get_weight
      IMPORTING i_uom           TYPE REF TO zcl_vo_uom OPTIONAL
      RETURNING VALUE(r_result) TYPE decfloat34
      RAISING   zcx_value_object.

    METHODS get_weight_rounded
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
    DATA weight TYPE decfloat34.
    DATA uom    TYPE REF TO zcl_vo_uom.

    METHODS check_uom_is_mass_dimension
      IMPORTING i_uom TYPE REF TO zcl_vo_uom
      RAISING   zcx_value_object.

ENDCLASS.


CLASS zcl_vo_weight IMPLEMENTATION.
  METHOD create_hash.
    TRY.
        DATA(si) = |{ get_weight( NEW #( 'kg' ) ) NUMBER = RAW }|.
        add_to_hash( REF #( si ) ).
        r_result = build_hash( ).
      CATCH zcx_value_object.
        RAISE SHORTDUMP NEW cx_sy_create_object_error( ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_weight.
    IF i_uom IS NOT BOUND OR uom->is_equal( i_uom ).
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
    ASSERT sy-subrc = 0.
  ENDMETHOD.

  METHOD get_weight_rounded.
    ASSERT i_decimals >= 0 AND i_precision >= 0.
    IF i_precision > 0.
      r_result = round( val  = get_weight( i_uom = i_uom )
                        prec = i_precision ).
    ELSE.
      r_result = round( val = get_weight( i_uom = i_uom )
                        dec = i_decimals ).
    ENDIF.
  ENDMETHOD.

  METHOD add.
    ASSERT i_weight IS BOUND.
    TRY.
        r_result = NEW #( i_weight = weight + i_weight->get_weight( uom )
                          i_uom    = uom ).
      CATCH zcx_value_object.
        RAISE SHORTDUMP NEW cx_sy_create_object_error( ).
    ENDTRY.
  ENDMETHOD.

  METHOD to_string_with_uom.
    DATA(l_uom) = COND #( WHEN i_uom IS BOUND THEN i_uom ELSE uom ).
    r_result = |{ conv_to_string( get_weight( l_uom ) ) } { l_uom->get_out( ) }|.
  ENDMETHOD.

  METHOD constructor.
    super->constructor( ).
    uom = i_uom.
    weight = i_weight.
    check_uom_is_mass_dimension( i_uom ).
    IF NOT is_valid( ).
      RAISE EXCEPTION TYPE zcx_value_object MESSAGE e010(z_value_object) WITH to_string( ).
    ENDIF.
  ENDMETHOD.

  METHOD get_uom.
    r_result = uom.
  ENDMETHOD.

  METHOD gt.
    ASSERT i_weight IS BOUND.
    TRY.
        r_result = xsdbool( weight > i_weight->get_weight( uom ) ).
      CATCH zcx_value_object.
        RAISE SHORTDUMP NEW cx_sy_create_object_error( ).
    ENDTRY.
  ENDMETHOD.

  METHOD is_valid.
    r_result = xsdbool( weight >= 0 ).
  ENDMETHOD.

  METHOD check_uom_is_mass_dimension.
    IF NOT is_dimension( i_dimid = 'MASS'
                         i_msehi = i_uom->get_in( ) ).
      RAISE EXCEPTION TYPE zcx_value_object MESSAGE e004(z_value_object) WITH i_uom->to_string( ).
    ENDIF.
  ENDMETHOD.

  METHOD to_string.
    r_result = conv_to_string( weight ).
  ENDMETHOD.

  METHOD to_string_empty_for_zero.
    DATA(l_uom) = COND #( WHEN i_uom IS BOUND THEN i_uom ELSE uom ).
    r_result = conv_to_string( i_return_empty_for_zero = abap_true
                               i_value                 = get_weight( l_uom ) ).
  ENDMETHOD.
ENDCLASS.
