"! Immutable value object representing unit of measurement
"! SAP differentiates between internal and external UOM (e.g. ST and PC). ZCL_VO_UOM does not care what you put in,
"! you only need to know what you want when you get it out.
CLASS zcl_vo_uom DEFINITION PUBLIC INHERITING FROM zcl_value_object CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS get_in
      RETURNING VALUE(r_result) TYPE msehi.

    METHODS get_out
      RETURNING VALUE(r_result) TYPE msehi.

    "! The UOM needs to be unique within a language. If there is an input, which uses the output of another one, it no longer works.
    "! This is not the case in the SAP standard. For this reason, no distinction is made
    "! between IN and OUT when instantiating. Check unit test integrity to be sure, that your system is ok
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

    DATA(uom) = CONV msehi( to_upper( i_msehi ) ).
    in = create_in( uom ).
    out = create_out( uom ).
    set_if_still_intitial( uom ).

    IF NOT is_valid( ).
      RAISE EXCEPTION TYPE zcx_value_object MESSAGE e003(z_value_object) WITH CONV string( i_msehi ).
    ENDIF.
  ENDMETHOD.

  METHOD create_in.
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING  input         = i_uom
      IMPORTING  output        = r_result
      EXCEPTIONS error_message = 98
                 OTHERS        = 99.
    IF sy-subrc <> 0.
      " FM does not work for all UOM. There will be also an exception, if we try to conv in to in.
      " we check in is_valid
    ENDIF.
  ENDMETHOD.

  METHOD create_out.
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
      EXPORTING  input         = i_uom
      IMPORTING  output        = r_result
      EXCEPTIONS error_message = 98
                 OTHERS        = 99.
    IF sy-subrc <> 0.
      " see method create_in
    ENDIF.
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
    " conversion exit not valid for that unit
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
    SELECT SINGLE @abap_true FROM t006 WHERE msehi = @in INTO @r_result.
  ENDMETHOD.

  METHOD to_string.
    r_result = out.
  ENDMETHOD.
ENDCLASS.
