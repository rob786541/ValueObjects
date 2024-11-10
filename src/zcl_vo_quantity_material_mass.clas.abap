"! Immutable value object representing quantity of material
"! All informatoin from database are read in the class_constructor
"! These can be long selects, depending on how many materials are in mara/marm.
"! If only a few objects need to be created, ZCL_VO_QUANTITY_MATERIAL is probably faster
CLASS zcl_vo_quantity_material_mass DEFINITION PUBLIC INHERITING FROM zcl_vo_quantity_material CREATE PUBLIC.
  PUBLIC SECTION.
    CLASS-METHODS class_constructor.

  PROTECTED SECTION.
    METHODS read_from_db REDEFINITION.

  PRIVATE SECTION.

ENDCLASS.


CLASS zcl_vo_quantity_material_mass IMPLEMENTATION.
  METHOD class_constructor.
    SELECT product, baseunit FROM i_product
      INTO CORRESPONDING FIELDS OF TABLE @base_units.
    SELECT Product, AlternativeUnit, QuantityNumerator, QuantityDenominator
      FROM I_ProductAlternativeUoM
      INTO CORRESPONDING FIELDS OF TABLE @alternatives.
  ENDMETHOD.

  METHOD read_from_db.
    super->read_from_db( ).
  ENDMETHOD.
ENDCLASS.
