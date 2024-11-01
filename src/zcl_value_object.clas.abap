"! Providing core functionality for immutable value objects
CLASS zcl_value_object DEFINITION PUBLIC ABSTRACT CREATE PUBLIC.

  PUBLIC SECTION.
    "! Compares two objects for value-based equality
    "!
    "! @parameter i_other |
    "! @parameter r_result |
    METHODS is_equal_to
      IMPORTING i_other         TYPE REF TO zcl_value_object
      RETURNING VALUE(r_result) TYPE abap_bool.

  PROTECTED SECTION.
    "! Abstract method to create a hash representing the object's state. When redefining this method,
    "! ensure that for each value relevant to the equality comparison, you call ADD_TO_HASH. After all values
    "! have been added, finalize the process by calling BUILD_HASH to construct the final hash value  and return
    "! the resulting hash value.
    "!
    "! @parameter r_result |
    METHODS create_hash ABSTRACT
      RETURNING VALUE(r_result) TYPE string.

    METHODS add_to_hash
      IMPORTING i_data TYPE REF TO data.

    METHODS build_hash
      RETURNING VALUE(r_result) TYPE string.

    METHODS is_valid ABSTRACT
      RETURNING VALUE(r_result) TYPE abap_bool.

    METHODS is_dimension
      IMPORTING i_dimid         TYPE dimid
                i_msehi         TYPE msehi
      RETURNING VALUE(r_result) TYPE abap_bool.

  PRIVATE SECTION.
    DATA hash_generator TYPE REF TO cl_abap_message_digest.

ENDCLASS.


CLASS zcl_value_object IMPLEMENTATION.
  METHOD is_dimension.
    ASSERT i_dimid IS NOT INITIAL.
    SELECT SINGLE @abap_true FROM t006 WHERE msehi = @i_msehi AND dimid = @i_dimid INTO @r_result.
  ENDMETHOD.

  METHOD is_equal_to.
    r_result = xsdbool( create_hash( ) = i_other->create_hash( ) ).
  ENDMETHOD.

  METHOD add_to_hash.
    TRY.
        IF hash_generator IS NOT BOUND.
          hash_generator = cl_abap_message_digest=>get_instance( ).
        ENDIF.
        CALL TRANSFORMATION id SOURCE root = i_data->* RESULT XML FINAL(xstring).
        hash_generator->update( if_data = xstring ).
      CATCH cx_abap_message_digest.
        RAISE SHORTDUMP NEW cx_sy_create_object_error( ).
    ENDTRY.
  ENDMETHOD.

  METHOD build_hash.
    TRY.
        hash_generator->digest( ).
        r_result = hash_generator->to_string( ).
        CLEAR hash_generator.
      CATCH cx_abap_message_digest.
        RAISE SHORTDUMP NEW cx_sy_create_object_error( ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
