"! Immutable value object representing quantity of material
CLASS zcl_vo_quantity_material DEFINITION PUBLIC INHERITING FROM zcl_value_object CREATE PUBLIC.

  PUBLIC SECTION.
    " The instantiation costs 2 db selects each time. There is no buffer.
    " ZCL_VO_QUANTITY_MATERIAL_MASS could be faster for many objects.
    METHODS constructor
      IMPORTING i_quantity TYPE decfloat34
                i_material TYPE matnr
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

    METHODS sub
      IMPORTING i_quantity      TYPE REF TO zcl_vo_quantity
      RETURNING VALUE(r_result) TYPE REF TO zcl_vo_quantity
      RAISING   zcx_value_object.

    METHODS gt
      IMPORTING i_quantity      TYPE REF TO zcl_vo_quantity
      RETURNING VALUE(r_result) TYPE abap_bool
      RAISING   zcx_value_object.

    METHODS ge
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

    METHODS create_base_unit
      IMPORTING i_material      TYPE matnr
      RETURNING VALUE(r_result) TYPE REF TO zcl_vo_uom
      RAISING   zcx_value_object.

    METHODS create_base_quantity
      IMPORTING i_uom           TYPE REF TO zcl_vo_uom
      RETURNING VALUE(r_result) TYPE decfloat34.

    CLASS-DATA alternatives TYPE SORTED TABLE OF I_ProductAlternativeUoM WITH UNIQUE KEY Product AlternativeUnit.

  PRIVATE SECTION.
    DATA material      TYPE matnr.
    DATA quantity      TYPE decfloat34.
    DATA uom           TYPE REF TO zcl_vo_uom.
    DATA base_uom      TYPE REF TO zcl_vo_uom.
    DATA base_quantity TYPE decfloat34.

ENDCLASS.


CLASS zcl_vo_quantity_material IMPLEMENTATION.
  METHOD create_hash.
    TRY.
        FINAL(quantity_in_base_unit) = |{ get_quantity( base_uom ) NUMBER = RAW }|.
        add_to_hash( REF #( quantity_in_base_unit ) ).
        add_to_hash( REF #( material ) ).
        r_result = build_hash( ).
      CATCH zcx_value_object.
        RAISE SHORTDUMP NEW cx_sy_create_object_error( ).
    ENDTRY.
  ENDMETHOD.

  METHOD is_valid.
    r_result = xsdbool( quantity >= 0 ).
  ENDMETHOD.

  METHOD to_string.
    r_result = conv_to_string( quantity ).
  ENDMETHOD.

  METHOD constructor.
    super->constructor( ).
    uom = i_uom.
    quantity = i_quantity.
    material = i_material.
    IF NOT is_valid( ).
      RAISE EXCEPTION TYPE zcx_value_object MESSAGE e013(z_value_object) WITH to_string( ).
    ENDIF.
    base_uom = create_base_unit( material ).
    base_quantity = create_base_quantity( base_uom ).
  ENDMETHOD.

  METHOD get_quantity.
    IF i_uom IS NOT BOUND OR uom->is_equal( i_uom ).
      r_result = quantity.
      RETURN.
    ELSEIF base_uom->is_equal( i_uom ) AND base_quantity <> 0.
      r_result = base_quantity.
      RETURN.
    ENDIF.
    " it is not possible to convert between two alternative units directly. In this case,
    " we need to convert alternative unit -> base unit -> alternative unit
    DATA(qty) = COND #( WHEN NOT base_uom->is_equal( uom ) AND NOT base_uom->is_equal( i_uom )
                        THEN base_quantity
                        ELSE quantity ).
    DATA(alternative_unit) = COND #( WHEN base_uom->is_equal( i_uom )
                                     THEN uom->get_in( )
                                     ELSE i_uom->get_in( ) ).
    ASSIGN alternatives[ Product         = material
                         AlternativeUnit = alternative_unit ] TO FIELD-SYMBOL(<alternative>).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_value_object MESSAGE e004(z_value_object) WITH i_uom->to_string( ) |{ material ALPHA = OUT }|.
    ENDIF.
    r_result = COND #( WHEN alternative_unit = uom->get_in( )
                       THEN <alternative>-QuantityNumerator / <alternative>-QuantityDenominator * qty    " from ALTME to MEINS
                       ELSE <alternative>-QuantityDenominator / <alternative>-QuantityNumerator * qty ). " from MEINS to ALTME
    " maybe there is a way to programme this method more elegantly
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

  METHOD create_base_unit.
    SELECT SINGLE baseunit FROM i_product
      WHERE Product = @i_material
      INTO @FINAL(base_unit).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_value_object MESSAGE e005(z_value_object) WITH |{ i_material ALPHA = OUT }|.
    ENDIF.
    r_result = NEW #( base_unit ).
  ENDMETHOD.

  METHOD create_base_quantity.
    SELECT Product, AlternativeUnit, QuantityNumerator, QuantityDenominator
      FROM I_ProductAlternativeUoM
      WHERE Product = @material
      INTO CORRESPONDING FIELDS OF TABLE @alternatives.
    ASSERT sy-subrc = 0.
    TRY.
        r_result = get_quantity( i_uom ).
      CATCH zcx_value_object.
        RAISE SHORTDUMP NEW cx_sy_create_object_error( ).
    ENDTRY.
  ENDMETHOD.

  METHOD add.
    ASSERT i_quantity IS BOUND.
    r_result = NEW #( i_quantity = quantity + i_quantity->get_quantity( uom )
                      i_uom      = uom ).
  ENDMETHOD.

  METHOD ge.
    ASSERT i_quantity IS BOUND.
    r_result = xsdbool( quantity >= i_quantity->get_quantity( uom ) ).
  ENDMETHOD.

  METHOD gt.
    ASSERT i_quantity IS BOUND.
    r_result = xsdbool( quantity > i_quantity->get_quantity( uom ) ).
  ENDMETHOD.

  METHOD sub.
    ASSERT i_quantity IS BOUND.
    r_result = NEW #( i_quantity = quantity - i_quantity->get_quantity( uom )
                      i_uom      = uom ).
  ENDMETHOD.

  METHOD to_string_empty_for_zero.
    FINAL(l_uom) = COND #( WHEN i_uom IS BOUND THEN i_uom ELSE uom ).
    r_result = conv_to_string( i_return_empty_for_zero = abap_true
                               i_value                 = get_quantity( l_uom ) ).
  ENDMETHOD.

  METHOD to_string_with_uom.
    FINAL(l_uom) = COND #( WHEN i_uom IS BOUND THEN i_uom ELSE uom ).
    r_result = |{ conv_to_string( get_quantity( l_uom ) ) } { l_uom->get_out( ) }|.
  ENDMETHOD.

  METHOD get_uom.
    r_result = uom.
  ENDMETHOD.
ENDCLASS.
