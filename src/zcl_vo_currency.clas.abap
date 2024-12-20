"! Immutable value object representing currency
CLASS zcl_vo_currency DEFINITION PUBLIC INHERITING FROM zcl_value_object CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS class_constructor.

    METHODS get_currency
      RETURNING VALUE(r_result) TYPE waers_curc.

    METHODS constructor
      IMPORTING i_waers TYPE waers_curc
      RAISING   zcx_value_object.

    METHODS to_string REDEFINITION.

  PROTECTED SECTION.
    METHODS create_hash REDEFINITION.
    METHODS is_valid    REDEFINITION.

  PRIVATE SECTION.
    CLASS-DATA currencies TYPE SORTED TABLE OF i_currency WITH UNIQUE KEY currency.

    DATA currency TYPE waers_curc.

ENDCLASS.


CLASS zcl_vo_currency IMPLEMENTATION.
  METHOD create_hash.
    add_to_hash( REF #( currency ) ).
    r_result = build_hash( ).
  ENDMETHOD.

  METHOD constructor.
    super->constructor( ).
    IF i_waers IS INITIAL.
      RAISE EXCEPTION TYPE zcx_value_object MESSAGE e006(z_value_object).
    ENDIF.
    currency = to_upper( i_waers ).
    IF NOT is_valid( ).
      RAISE EXCEPTION TYPE zcx_value_object MESSAGE e007(z_value_object) WITH i_waers.
    ENDIF.
  ENDMETHOD.

  METHOD get_currency.
    r_result = currency.
  ENDMETHOD.

  METHOD is_valid.
    r_result = xsdbool( line_exists( currencies[ Currency = currency ] ) ).
  ENDMETHOD.

  METHOD to_string.
    r_result = currency.
  ENDMETHOD.

  METHOD class_constructor.
    " There is the field gdatu in the database tcurc but not in the CDS-View. Is this field deprecated?
    SELECT Currency FROM I_Currency INTO TABLE @currencies.
  ENDMETHOD.
ENDCLASS.
