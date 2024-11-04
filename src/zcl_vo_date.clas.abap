"! Immutable value object representing date and time
CLASS zcl_vo_date DEFINITION PUBLIC INHERITING FROM zcl_value_object CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING i_date      TYPE d       OPTIONAL
                i_time      TYPE t       OPTIONAL
                i_time_zone TYPE tznzone OPTIONAL
      RAISING   zcx_value_object.

    METHODS get_date
      RETURNING VALUE(r_result) TYPE d.

    METHODS get_time
      RETURNING VALUE(r_result) TYPE t.

    METHODS convert_to_time_zone
      IMPORTING i_time_zone     TYPE tznzone
      RETURNING VALUE(r_result) TYPE REF TO zcl_vo_date.

    METHODS to_string REDEFINITION.

  PROTECTED SECTION.
    METHODS create_hash REDEFINITION.
    METHODS is_valid    REDEFINITION.

  PRIVATE SECTION.
    DATA date      TYPE d.
    DATA time      TYPE t.
    DATA time_zone TYPE tznzone.

ENDCLASS.


CLASS zcl_vo_date IMPLEMENTATION.
  METHOD constructor.
    super->constructor( ).
    date = COND #( WHEN i_date IS SUPPLIED
                   THEN i_date
                   ELSE xco_cp=>sy->date( )->as( xco_cp_time=>format->abap )->value ).
    time = COND #( WHEN i_time IS SUPPLIED
                   THEN i_time
                   ELSE xco_cp=>sy->time( )->as( xco_cp_time=>format->abap )->value ).
    time_zone = COND #( WHEN i_time_zone IS SUPPLIED
                        THEN i_time_zone
                        ELSE xco_cp_time=>time_zone->user->value ).
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
                                                  time_zone  = time_zone
                                        IMPORTING date_valid = date
                                                  time_valid = time ).
        r_result = abap_true.
      CATCH cx_parameter_invalid_range cx_tstmp_internal_error cx_abap_context_info_error.
        r_result = abap_false.
    ENDTRY.
  ENDMETHOD.

  METHOD to_string.
    TRY.
        cl_abap_datfm=>conv_date_int_to_ext( EXPORTING im_datint = date
                                             IMPORTING ex_datext = r_result ).
        cl_abap_timefm=>conv_time_int_to_ext( EXPORTING time_int = time
                                              IMPORTING time_ext = FINAL(l_time) ).
        R_result = |{ r_result } { l_time }|.
      CATCH cx_abap_datfm_format_unknown.
        RAISE SHORTDUMP NEW cx_sy_create_object_error( ).
    ENDTRY.
  ENDMETHOD.

  METHOD convert_to_time_zone.
    ASSERT i_time_zone IS NOT INITIAL.
    " is there a way to do it with one convert?
    CONVERT DATE date TIME time
            INTO TIME STAMP FINAL(ts) TIME ZONE time_zone.
    ASSERT sy-subrc = 0.
    CONVERT TIME STAMP ts
            TIME ZONE i_time_zone
            INTO DATE FINAL(l_date)
            TIME FINAL(l_time).
    ASSERT sy-subrc = 0.
    TRY.
        r_result = NEW #( i_date      = l_date
                          i_time      = l_time
                          i_time_zone = i_time_zone ).
      CATCH zcx_value_object.
        RAISE SHORTDUMP NEW cx_sy_create_object_error( ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
