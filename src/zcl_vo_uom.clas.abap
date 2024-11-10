"! immutable value object representing unit of measurement
"! sap differentiates between internal and external uom (e.g. st and pc). zcl_vo_uom does not care what you put in,
"! you only need to know what you want when you get it out.
CLASS zcl_vo_uom DEFINITION PUBLIC INHERITING FROM zcl_value_object CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS class_constructor.

    METHODS get_in
      RETURNING VALUE(r_result) TYPE msehi.

    METHODS get_out
      RETURNING VALUE(r_result) TYPE msehi.

    METHODS get_dimension
      RETURNING VALUE(r_result) TYPE dimid.

    METHODS get_si_unit
      RETURNING VALUE(r_result) TYPE mssie.

    "! the uom needs to be unique within a language. if there is an input, which uses the output of another one, it no longer works.
    "! this is not the case in the sap standard. for this reason, no distinction is made
    "! between in and out when instantiating. check unit test integrity to be sure, that your system is ok
    "!
    "! @parameter i_msehi          | internal or external unit of measurement
    "! @raising   zcx_value_object | raised when given uom is not valid
    METHODS constructor
      IMPORTING i_msehi TYPE msehi
      RAISING   zcx_value_object.

    METHODS to_string REDEFINITION.

  PROTECTED SECTION.
    METHODS create_hash REDEFINITION.
    METHODS is_valid    REDEFINITION.

  PRIVATE SECTION.
    CLASS-METHODS create_in
      IMPORTING i_uom           TYPE msehi
      RETURNING VALUE(r_result) TYPE msehi.

    CLASS-METHODS create_out
      IMPORTING i_uom           TYPE msehi
      RETURNING VALUE(r_result) TYPE msehi.

    METHODS set_if_still_intitial
      IMPORTING i_uom TYPE msehi.

    CLASS-DATA unitofmeasurecommercialname TYPE SORTED TABLE OF I_UnitOfMeasureCommercialName
      WITH UNIQUE KEY Language UnitOfMeasureCommercialName
      WITH UNIQUE SORTED KEY secondary_key COMPONENTS Language UnitOfMeasure.
    CLASS-DATA unitofmeasuredimension      TYPE SORTED TABLE OF I_UnitOfMeasureDimension WITH UNIQUE KEY UnitOfMeasureDimension.
    CLASS-DATA UnitOfMeasure               TYPE SORTED TABLE OF I_UnitOfMeasure WITH UNIQUE KEY UnitOfMeasure.

    DATA in  TYPE msehi.
    DATA out TYPE msehi.

ENDCLASS.


CLASS zcl_vo_uom IMPLEMENTATION.
  METHOD create_hash.
    add_to_hash( REF #( in ) ).
    r_result = build_hash( ).
  ENDMETHOD.

  METHOD constructor.
    super->constructor( ).
    IF i_msehi IS INITIAL.
      RAISE EXCEPTION TYPE zcx_value_object MESSAGE e002(z_value_object).
    ENDIF.
    FINAL(uom) = CONV msehi( to_upper( i_msehi ) ).
    in = create_in( uom ).
    out = create_out( uom ).
    set_if_still_intitial( uom ).
    IF NOT is_valid( ).
      RAISE EXCEPTION TYPE zcx_value_object MESSAGE e003(z_value_object) WITH CONV string( i_msehi ).
    ENDIF.
  ENDMETHOD.

  METHOD create_in.
    r_result = VALUE #( unitofmeasurecommercialname[ KEY primary_key
                                                     Language                    = sy-langu
                                                     UnitOfMeasureCommercialName = i_uom ]-UnitOfMeasure OPTIONAL ).
  ENDMETHOD.

  METHOD create_out.
    r_result = VALUE #( unitofmeasurecommercialname[ KEY secondary_key
                                                     Language      = sy-langu
                                                     UnitOfMeasure = i_uom ]-UnitOfMeasureCommercialName OPTIONAL ).
  ENDMETHOD.

  METHOD set_if_still_intitial.
    " in was given
    IF in IS INITIAL AND out IS NOT INITIAL AND out <> i_uom.
      in = to_upper( i_uom ).
    ENDIF.
    " out was given
    IF out IS INITIAL AND in IS NOT INITIAL AND in <> i_uom.
      out = to_upper( i_uom ).
    ENDIF.
    IF in IS INITIAL AND out IS INITIAL.
      in = to_upper( i_uom ).
      out = to_upper( i_uom ).
    ENDIF.
  ENDMETHOD.

  METHOD get_in.
    r_result = in.
  ENDMETHOD.

  METHOD get_out.
    r_result = out.
  ENDMETHOD.

  METHOD is_valid.
    r_result = xsdbool( line_exists( unitofmeasure[ UnitOfMeasure = in ] ) ).
  ENDMETHOD.

  METHOD to_string.
    r_result = out.
  ENDMETHOD.

  METHOD get_si_unit.
    r_result = VALUE #( unitofmeasuredimension[ UnitOfMeasureDimension = get_dimension( ) ]-UnitOFMeasureSiUnit ).
  ENDMETHOD.

  METHOD get_dimension.
    r_result = VALUE #( unitofmeasure[ UnitOfMeasure = in ]-UnitOfMeasureDimension ).
  ENDMETHOD.

  METHOD class_constructor.
    " Is it possible to read all information with one select only?
    SELECT Language, UnitOfMeasureCommercialName, UnitOfMeasure
      FROM I_UnitOfMeasureCommercialName
      INTO CORRESPONDING FIELDS OF TABLE @unitofmeasurecommercialname.
    SELECT UnitOfMeasureDimension, UnitOFMeasureSiUnit
      FROM I_UnitOfMeasureDimension
      INTO CORRESPONDING FIELDS OF TABLE @unitofmeasuredimension.
    SELECT UnitOfMeasure, UnitOfMeasureDimension
      FROM I_UnitOfMeasure
      INTO CORRESPONDING FIELDS OF TABLE @unitofmeasure.
  ENDMETHOD.
ENDCLASS.
