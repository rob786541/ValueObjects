CLASS zcl_vo_money DEFINITION PUBLIC INHERITING FROM zcl_value_object FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING i_amount   TYPE decfloat34
                i_currency TYPE REF TO zcl_vo_currency
      RAISING   zcx_value_object.

    METHODS as_string REDEFINITION.

    METHODS as_string_with_currency
      RETURNING VALUE(r_result) TYPE string.

    METHODS as_string_empty_for_zero
      RETURNING VALUE(r_result) TYPE string.

    METHODS add
      IMPORTING i_amount        TYPE REF TO zcl_vo_money
      RETURNING VALUE(r_result) TYPE REF TO zcl_vo_money
      RAISING   zcx_value_object.

    METHODS get_amount
      RETURNING VALUE(r_result) TYPE decfloat34
      RAISING   zcx_value_object.

    METHODS get_amount_rounded
      IMPORTING i_precision     TYPE i DEFAULT 0
                i_decimals      TYPE i DEFAULT 2
      RETURNING VALUE(r_result) TYPE decfloat34
      RAISING   zcx_value_object.

    METHODS get_currency
      RETURNING VALUE(r_result) TYPE REF TO zcl_vo_currency.

  PROTECTED SECTION.
    METHODS create_hash REDEFINITION.
    METHODS is_valid    REDEFINITION.

  PRIVATE SECTION.
    DATA amount   TYPE decfloat34.
    DATA currency TYPE REF TO zcl_vo_currency.

    METHODS check_currency_is_equal
      IMPORTING i_currency TYPE REF TO zcl_vo_currency
      RAISING   zcx_value_object.
ENDCLASS.


CLASS zcl_vo_money IMPLEMENTATION.
  METHOD constructor.
    super->constructor( ).
    currency = i_currency.
    amount = i_amount.
  ENDMETHOD.

  METHOD get_currency.
    r_result = currency.
  ENDMETHOD.

  METHOD get_amount.
    r_result = amount.
  ENDMETHOD.

  METHOD get_amount_rounded.
    ASSERT i_decimals >= 0 AND i_precision >= 0.

    IF i_precision IS SUPPLIED.
      r_result = round( val  = amount
                        prec = i_precision ).
    ELSE.
      r_result = round( val = amount
                        dec = i_decimals ).
    ENDIF.
  ENDMETHOD.

  METHOD add.
    ASSERT i_amount IS BOUND.
    check_currency_is_equal( i_amount->get_currency( ) ).
    TRY.
        r_result = NEW #( i_amount   = amount + i_amount->get_amount( )
                          i_currency = currency ).
      CATCH zcx_value_object.
        RAISE SHORTDUMP NEW cx_sy_create_object_error( ).
    ENDTRY.
  ENDMETHOD.

  METHOD check_currency_is_equal.
    IF NOT currency->is_equal( i_currency ).
      RAISE EXCEPTION TYPE zcx_value_object MESSAGE e008(z_value_object) WITH i_currency->as_string( ) currency->as_string( ).
    ENDIF.
  ENDMETHOD.

  METHOD as_string.
    r_result = conv_to_string( amount ).
  ENDMETHOD.

  METHOD as_string_empty_for_zero.
    r_result = conv_to_string( i_value                 = amount
                               i_return_empty_for_zero = abap_true ).
  ENDMETHOD.

  METHOD as_string_with_currency.
    r_result = |{ conv_to_string( amount ) } { currency->as_string( ) }|.
  ENDMETHOD.

  METHOD create_hash.
    DATA(wears) = currency->get_currency( ).
    add_to_hash( REF #( wears ) ).
    add_to_hash( REF #( amount ) ).
    r_result = build_hash( ).
  ENDMETHOD.

  METHOD is_valid.
    " positive, negative and zero are valid values for amount
    r_result = abap_true.
  ENDMETHOD.
ENDCLASS.
