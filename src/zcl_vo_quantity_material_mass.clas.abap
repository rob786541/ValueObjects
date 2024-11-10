"! Immutable value object representing quantity of material
"! All informatoin from database are read in the class_constructor
"! These can be long selects, depending on how many materials are in mara/marm.
"! If only a few objects need to be created, ZCL_VO_QUANTITY_MATERIAL is probably faster
CLASS zcl_vo_quantity_material_mass DEFINITION PUBLIC INHERITING FROM zcl_vo_quantity_material CREATE PUBLIC.
  PUBLIC SECTION.
    CLASS-METHODS class_constructor.

  PROTECTED SECTION.
    METHODS create_base_unit     REDEFINITION.
    METHODS create_base_quantity REDEFINITION.

  PRIVATE SECTION.
    CLASS-DATA base_units TYPE SORTED TABLE OF i_product WITH UNIQUE KEY Product.

ENDCLASS.


CLASS zcl_vo_quantity_material_mass IMPLEMENTATION.
  METHOD class_constructor.
    SELECT baseunit FROM i_product
      INTO CORRESPONDING FIELDS OF TABLE @base_units.
    SELECT Product, AlternativeUnit, QuantityNumerator, QuantityDenominator
      FROM I_ProductAlternativeUoM
      INTO CORRESPONDING FIELDS OF TABLE @alternatives.
  ENDMETHOD.

  METHOD create_base_quantity.
    TRY.
        r_result = get_quantity( i_uom ).
      CATCH zcx_value_object.
        RAISE SHORTDUMP NEW cx_sy_create_object_error( ).
    ENDTRY.
  ENDMETHOD.

  METHOD create_base_unit.
    ASSIGN base_units[ Product = i_material ]-baseunit TO FIELD-SYMBOL(<base_unit>).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_value_object MESSAGE e005(z_value_object) WITH |{ i_material ALPHA = OUT }|.
    ENDIF.
    r_result = NEW #( <base_unit> ).
  ENDMETHOD.
ENDCLASS.
