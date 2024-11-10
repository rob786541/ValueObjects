"! Immutable value object representing quantity of material
CLASS zcl_vo_quantity_material DEFINITION PUBLIC INHERITING FROM zcl_value_object CREATE PUBLIC.

  PUBLIC SECTION.
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
      IMPORTING i_other         TYPE REF TO zcl_vo_quantity
      RETURNING VALUE(r_result) TYPE REF TO zcl_vo_quantity
      RAISING   zcx_value_object.

    METHODS sub
      IMPORTING i_other         TYPE REF TO zcl_vo_quantity
      RETURNING VALUE(r_result) TYPE REF TO zcl_vo_quantity
      RAISING   zcx_value_object.

    METHODS gt
      IMPORTING i_other         TYPE REF TO zcl_vo_quantity
      RETURNING VALUE(r_result) TYPE abap_bool
      RAISING   zcx_value_object.

    METHODS ge
      IMPORTING i_other         TYPE REF TO zcl_vo_quantity
      RETURNING VALUE(r_result) TYPE abap_bool
      RAISING   zcx_value_object.

    " The call costs 2 db selects for each instance if i_uom is different
    " ZCL_VO_QUANTITY_MATERIAL_MASS could be faster for many objects.
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

    METHODS read_from_db
      IMPORTING i_material TYPE matnr OPTIONAL
      RAISING   zcx_value_object.

    CLASS-DATA alternatives TYPE SORTED TABLE OF I_ProductAlternativeUoM WITH UNIQUE KEY Product AlternativeUnit.
    CLASS-DATA base_units   TYPE SORTED TABLE OF i_product WITH UNIQUE KEY Product.

  PRIVATE SECTION.
    METHODS create_base_quantity
      RETURNING VALUE(r_result) TYPE REF TO zcl_vo_quantity
      RAISING   zcx_value_object.

    DATA quantity      TYPE REF TO zcl_vo_quantity.
    DATA material      TYPE matnr.
    DATA base_quantity TYPE REF TO zcl_vo_quantity.

ENDCLASS.


CLASS zcl_vo_quantity_material IMPLEMENTATION.
  METHOD create_hash.
    TRY.
        create_base_quantity( ).
        FINAL(quantity_in_base_unit) = |{ base_quantity->get_quantity( ) NUMBER = RAW }|.
        add_to_hash( REF #( quantity_in_base_unit ) ).
        add_to_hash( REF #( material ) ).
        r_result = build_hash( ).
      CATCH zcx_value_object.
        RAISE SHORTDUMP NEW cx_sy_create_object_error( ).
    ENDTRY.
  ENDMETHOD.

  METHOD is_valid.
    r_result = abap_true.
  ENDMETHOD.

  METHOD to_string.
    r_result = quantity->to_string( ).
  ENDMETHOD.

  METHOD constructor.
    super->constructor( ).
    quantity = NEW #( i_quantity                = i_quantity
                      i_uom                     = i_uom
                      i_dimmension_check_active = abap_false ).
    material = i_material.
  ENDMETHOD.

  METHOD get_quantity.
    IF i_uom IS NOT BOUND OR quantity->get_uom( )->is_equal( i_uom ).
      r_result = quantity->get_quantity( ).
      RETURN.
    ENDIF.
    create_base_quantity( ).
    IF base_quantity->get_uom( )->is_equal( i_uom ).
      r_result = base_quantity->get_quantity( ).
      RETURN.
    ENDIF.
    " it is not possible to convert between two alternative units directly. In this case,
    " we need to convert alternative unit -> base unit -> alternative unit
    DATA(qty) = COND #( WHEN NOT base_quantity->get_uom( )->is_equal( quantity->get_uom( ) )
                         AND NOT base_quantity->get_uom( )->is_equal( i_uom )
                        THEN base_quantity->get_quantity( )
                        ELSE quantity->get_quantity( ) ).
    DATA(alternative_unit) = COND #( WHEN base_quantity->get_uom( )->is_equal( i_uom )
                                     THEN quantity->get_uom( )->get_in( )
                                     ELSE i_uom->get_in( ) ).
    ASSIGN alternatives[ Product         = material
                         AlternativeUnit = alternative_unit ] TO FIELD-SYMBOL(<alternative>).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_value_object MESSAGE e004(z_value_object) WITH i_uom->to_string( ) |{ material ALPHA = OUT }|.
    ENDIF.
    r_result = COND #( WHEN alternative_unit = quantity->get_uom( )->get_in( )
                       THEN <alternative>-QuantityNumerator / <alternative>-QuantityDenominator * qty    " alternative unit -> base unit
                       ELSE <alternative>-QuantityDenominator / <alternative>-QuantityNumerator * qty ). " base unit -> alternative unit
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

  METHOD create_base_quantity.
    IF base_quantity IS BOUND.
      RETURN.
    ENDIF.
    read_from_db( material ).
    ASSIGN base_units[ Product = material ]-baseunit TO FIELD-SYMBOL(<base_unit>).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_value_object MESSAGE e005(z_value_object) WITH |{ material ALPHA = OUT }|.
    ENDIF.
    IF quantity->get_uom( )->is_equal( NEW zcl_vo_uom( <base_unit> ) ).
      base_quantity = quantity.
      RETURN.
    ENDIF.
    ASSIGN alternatives[ Product         = material
                         AlternativeUnit = quantity->get_uom( )->get_in( ) ] TO FIELD-SYMBOL(<alternative>).
    TRY.
        base_quantity = NEW #(
            i_quantity                = <alternative>-QuantityNumerator / <alternative>-QuantityDenominator * quantity->get_quantity( )
            i_uom                     = NEW #( <base_unit> )
            i_dimmension_check_active = abap_false ).
      CATCH zcx_value_object.
        RAISE SHORTDUMP NEW cx_sy_create_object_error( ).
    ENDTRY.
  ENDMETHOD.

  METHOD add.
    r_result = quantity->add( i_other ).
  ENDMETHOD.

  METHOD ge.
    r_result = quantity->ge( i_other ).
  ENDMETHOD.

  METHOD gt.
    r_result = quantity->gt( i_other ).
  ENDMETHOD.

  METHOD sub.
    r_result = quantity->sub( i_other ).
  ENDMETHOD.

  METHOD to_string_empty_for_zero.
    r_result = quantity->to_string_empty_for_zero( i_uom ).
  ENDMETHOD.

  METHOD to_string_with_uom.
    r_result = quantity->to_string_with_uom( i_uom ).
  ENDMETHOD.

  METHOD get_uom.
    r_result = quantity->get_uom( ).
  ENDMETHOD.

  METHOD read_from_db.
    DATA materials TYPE RANGE OF matnr.
    IF i_material IS NOT INITIAL.
      materials = VALUE #( ( sign = 'I' option = 'EQ' low = i_material ) ).
    ENDIF.
    SELECT product, baseunit FROM i_product
      WHERE Product IN @materials
      INTO CORRESPONDING FIELDS OF TABLE @base_units.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_value_object MESSAGE e005(z_value_object) WITH |{ material ALPHA = OUT }|.
    ENDIF.
    SELECT Product, AlternativeUnit, QuantityNumerator, QuantityDenominator
      FROM I_ProductAlternativeUoM
      WHERE Product IN @materials
      INTO CORRESPONDING FIELDS OF TABLE @alternatives.
    ASSERT sy-subrc = 0.
  ENDMETHOD.
ENDCLASS.
