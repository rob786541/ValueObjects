CLASS zcl_vo_quantity_material DEFINITION PUBLIC INHERITING FROM zcl_value_object CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS class_constructor.

    METHODS constructor
      IMPORTING i_quantity TYPE decfloat34
                i_material TYPE matnr
                i_uom      TYPE REF TO zcl_vo_uom
      RAISING   zcx_value_object.

    METHODS get_quantity
      IMPORTING i_uom           TYPE REF TO zcl_vo_uom OPTIONAL
      RETURNING VALUE(r_result) TYPE decfloat34
      RAISING   zcx_value_object.

    METHODS to_string REDEFINITION.

  PROTECTED SECTION.
    METHODS create_hash REDEFINITION.
    METHODS is_valid    REDEFINITION.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_alternative,
        alternative_unit TYPE I_ProductAlternativeUoM-AlternativeUnit,
        numerator        TYPE I_ProductAlternativeUoM-QuantityNumerator,
        denominator      TYPE I_ProductAlternativeUoM-QuantityDenominator,
      END OF ty_alternative,
      tty_alternatives TYPE SORTED TABLE OF ty_alternative WITH UNIQUE KEY alternative_unit.

    METHODS create_base_unit
      RAISING zcx_value_object.

    METHODS create_base_quantity
      RETURNING VALUE(r_result) TYPE decfloat34.

    CLASS-DATA uom_conversion TYPE REF TO cl_uom_conversion.

    DATA alternatives  TYPE tty_alternatives.
    DATA quantity      TYPE decfloat34.
    DATA material      TYPE matnr.
    DATA base_uom      TYPE REF TO zcl_vo_uom.
    DATA base_quantity TYPE decfloat34.
    DATA uom           TYPE REF TO zcl_vo_uom.

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
    create_base_unit( ).
    create_base_quantity( ).
    IF NOT is_valid( ).
      RAISE EXCEPTION TYPE zcx_value_object MESSAGE e013(z_value_object) WITH to_string( ).
    ENDIF.
  ENDMETHOD.

  METHOD get_quantity.
    IF i_uom IS NOT BOUND OR uom->is_equal( i_uom ).
      r_result = quantity.
      RETURN.
    ENDIF.
    DATA(qty) = COND #( WHEN NOT base_uom->is_equal( uom ) AND NOT base_uom->is_equal( i_uom ) THEN base_quantity ELSE quantity ).
    DATA(alternative_unit) = COND #( WHEN base_uom->is_equal( i_uom ) THEN uom->get_in( ) ELSE i_uom->get_in( ) ).
    ASSIGN alternatives[ alternative_unit = alternative_unit ] TO FIELD-SYMBOL(<alternative>).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_value_object MESSAGE e004(z_value_object) WITH i_uom->to_string( ) |{ material ALPHA = OUT }|.
    ENDIF.
    IF alternative_unit = uom->get_in( ). "from ALTME to MEINS
      r_result = <alternative>-numerator / <alternative>-denominator * qty.
    ELSE. "from MEINS to ALTME
      r_result = <alternative>-denominator / <alternative>-numerator * qty.
    ENDIF.
  ENDMETHOD.

  METHOD create_base_unit.
    SELECT SINGLE baseunit FROM i_product
      WHERE Product = @material
      INTO @FINAL(base_unit).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_value_object MESSAGE e005(z_value_object) WITH |{ material ALPHA = OUT }|.
    ENDIF.
    base_uom = NEW #( base_unit ).
  ENDMETHOD.

  METHOD class_constructor.
    uom_conversion = NEW #( ).
  ENDMETHOD.

  METHOD create_base_quantity.
    SELECT AlternativeUnit, QuantityNumerator, QuantityDenominator
      FROM I_ProductAlternativeUoM
      WHERE Product = @material
      INTO TABLE @alternatives.
    ASSERT sy-subrc = 0.
    TRY.
        base_quantity = get_quantity( base_uom ).
      CATCH zcx_value_object.
        RAISE SHORTDUMP NEW cx_sy_create_object_error( ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
