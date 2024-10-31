"! Immutable value object representing date and time
CLASS zcl_vo_date DEFINITION PUBLIC INHERITING FROM zcl_value_object CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING i_date TYPE d OPTIONAL
                i_time TYPE t OPTIONAL
      RAISING   zcx_value_object.

    METHODS get_date
      RETURNING VALUE(r_result) TYPE d.

    METHODS get_time
      RETURNING VALUE(r_result) TYPE t.

  PROTECTED SECTION.
    METHODS create_hash REDEFINITION.
    METHODS is_valid    REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS initial_date TYPE d VALUE '00000000'.

    DATA date TYPE d.
    DATA time TYPE t.

ENDCLASS.


CLASS zcl_vo_date IMPLEMENTATION.
  METHOD constructor.
    super->constructor( ).
    IF i_date = initial_date.
      date = cl_abap_context_info=>get_system_date( ).
    ELSE.
      date = i_date.
    ENDIF.
    time = i_time.

    IF NOT is_valid( ).
      RAISE EXCEPTION TYPE zcx_value_object MESSAGE e001(z_value_object) WITH i_date i_time.
    ENDIF.
  ENDMETHOD.

  METHOD get_date.
    r_result = date.
  ENDMETHOD.

  METHOD get_time.
    r_result = time.
  ENDMETHOD.

  METHOD create_hash.
    add_to_hash( REF #( date ) ).
    add_to_hash( REF #( time ) ).
    r_result = build_hash( ).
  ENDMETHOD.

  METHOD is_valid.
    TRY.
        cl_abap_tstmp=>make_valid_time( EXPORTING date_in    = date
                                                  time_in    = time
                                                  time_zone  = cl_abap_context_info=>get_user_time_zone( )
                                        IMPORTING date_valid = date
                                                  time_valid = time ).
        r_result = abap_true.
      CATCH cx_parameter_invalid_range cx_tstmp_internal_error cx_abap_context_info_error.
        r_result = abap_false.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
