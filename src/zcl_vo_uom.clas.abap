"! Immutable value object representing unit of measurement
"! SAP differentiates between internal and external UOM (e.g. ST and PC). ZCL_VO_UOM does not care what you put in,
"! you only need to know what you want when you get it out.
CLASS zcl_vo_uom DEFINITION PUBLIC INHERITING FROM zcl_value_object CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS _get_in
      IMPORTING i_uom           TYPE msehi
      RETURNING VALUE(r_result) TYPE msehi.

    CLASS-METHODS _get_out
      IMPORTING i_uom           TYPE msehi
      RETURNING VALUE(r_result) TYPE msehi.

    METHODS get_in
      RETURNING VALUE(r_result) TYPE msehi.

    METHODS get_out
      RETURNING VALUE(r_result) TYPE msehi.

    "! The UOM needs to be unique within a language. If there is an input, which uses the output of another one, it no longer works.
    "! This is not the case in the SAP standard. For this reason, no distinction is made
    "! between IN and OUT when instantiating. Check unit test integrity to be sure, that your system is ok
    "!
    "! @parameter i_msehi | internal or external unit of measurement
    METHODS constructor
      IMPORTING i_msehi TYPE msehi.

    METHODS is_valid REDEFINITION.

  PROTECTED SECTION.
    METHODS create_hash REDEFINITION.

  PRIVATE SECTION.
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

    DATA(uom) = CONV msehi( to_upper( i_msehi ) ).
    in = _get_in( uom ).
    out = _get_out( uom ).
    set_if_still_intitial( uom ).
  ENDMETHOD.

  METHOD _get_in.
    IF i_uom IS INITIAL.
      RETURN.
    ENDIF.
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING  input         = i_uom
      IMPORTING  output        = r_result
      EXCEPTIONS error_message = 1
                 OTHERS        = 2.
  ENDMETHOD.

  METHOD _get_out.
    IF i_uom IS INITIAL.
      RETURN.
    ENDIF.
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
      EXPORTING  input         = i_uom
      IMPORTING  output        = r_result
      EXCEPTIONS error_message = 1
                 OTHERS        = 2.
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
  ENDMETHOD.

  METHOD get_in.
    r_result = in.
  ENDMETHOD.

  METHOD get_out.
    r_result = out.
  ENDMETHOD.

  METHOD is_valid.
    IF in IS INITIAL.
      r_result = abap_false.
      RETURN.
    ENDIF.
    SELECT SINGLE @abap_true FROM t006 WHERE msehi = @in INTO @DATA(found).
    IF found = abap_true.
      r_result = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
