CLASS ltc_unit_test DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    DATA cut TYPE REF TO zcl_vo_date.
    DATA e   TYPE REF TO zcx_value_object.

    METHODS constructor1      FOR TESTING.
    METHODS constructor2      FOR TESTING.
    METHODS constructor3      FOR TESTING.
    METHODS input_validation1 FOR TESTING.
    METHODS input_validation2 FOR TESTING.
    METHODS input_validation3 FOR TESTING.
    METHODS input_validation4 FOR TESTING.
    METHODS input_validation5 FOR TESTING.
    METHODS input_validation6 FOR TESTING.
    METHODS equals1           FOR TESTING.
    METHODS equals2           FOR TESTING.
    METHODS equals3           FOR TESTING.
    METHODS as_string1        FOR TESTING.
    METHODS as_string2        FOR TESTING.
    METHODS time_zone1        FOR TESTING.
    METHODS time_zone2        FOR TESTING.

ENDCLASS.


CLASS ltc_unit_test IMPLEMENTATION.
  METHOD constructor1.
    " Arrange
    TRY.
        cut = NEW #( ).
        " Act
        IF cut IS NOT BOUND.
          " Assert
          cl_abap_unit_assert=>fail( ).
        ENDIF.
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD constructor2.
    " Arrange
    TRY.
        cut = NEW #( ).
        " Act
        FINAL(date) = cut->get_date( ).
        " Assert
        cl_abap_unit_assert=>assert_equals( exp = cl_abap_context_info=>get_system_date( )
                                            act = date ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD constructor3.
    " Arrange
    TRY.
        cut = NEW #( i_date = '19951005' ).
        " Act
        FINAL(date) = cut->get_date( ).
        " Assert
        cl_abap_unit_assert=>assert_equals( exp = '19951005'
                                            act = date ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD input_validation1.
    TRY.
        cut = NEW #( i_date = '20203131' ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_value_object INTO e.
        cl_abap_unit_assert=>assert_equals( exp = 'Date 31.31.2020 or time 00:00:00 is not valid'
                                            act = e->get_text( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD input_validation2.
    TRY.
        cut = NEW #( i_time = '115999' ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_value_object INTO e.
        cl_abap_unit_assert=>assert_equals( exp = 'Date 00.00.0000 or time 11:59:99 is not valid'
                                            act = e->get_text( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD input_validation3.
    TRY.
        cut = NEW #( i_date = '20203131'
                     i_time = '115999' ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_value_object.
    ENDTRY.
  ENDMETHOD.

  METHOD input_validation4.
    TRY.
        cut = NEW #( i_date = '202AC131'
                     i_time = '115959' ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_value_object.
    ENDTRY.
  ENDMETHOD.

  METHOD input_validation5.
    TRY.
        cut = NEW #( i_date = '20200504'
                     i_time = '11CD99' ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_value_object.
    ENDTRY.
  ENDMETHOD.

  METHOD input_validation6. TRY.

        cut = NEW #( i_date = '20200504'
                     i_time = '115959' ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD equals1.
    " Arrange
    TRY.
        cut = NEW #( i_date = '20200504'
                     i_time = '111235' ).
        FINAL(second_obj) = NEW zcl_vo_date( i_date = '20200504'
                                             i_time = '111235' ).
        " Act
        FINAL(act) = cut->is_equal( second_obj ).
        " Assert
        cl_abap_unit_assert=>assert_true( act ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD equals2.
    TRY.
        cut = NEW #( i_date = '20200504'
                     i_time = '111235' ).
        FINAL(second_obj) = NEW zcl_vo_date( i_date = '20200504'
                                             i_time = '111235' ).
        " Act
        FINAL(act) = second_obj->is_equal( cut ).
        " Assert
        cl_abap_unit_assert=>assert_true( act ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD equals3.
    " Arrange
    TRY.
        cut = NEW #( i_date = '20200504'
                     i_time = '111235' ).
        FINAL(second_obj) = NEW zcl_vo_date( i_date = '20200504'
                                             i_time = '111236' ).
        " Act
        FINAL(act) = second_obj->is_equal( cut ).
        " Assert
        cl_abap_unit_assert=>assert_false( act ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD as_string1.
    " Arrange
    TRY.
        cut = NEW #( i_date = '20200504'
                     i_time = '111235' ).
        " Act
        FINAL(date_string) = cut->as_string( ).
        " Assert
        cl_abap_unit_assert=>assert_equals( exp = '04.05.2020 11:12:35'
                                            act = date_string ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD as_string2.
    TRY.
        cut = NEW #( i_date = '20200504'
                     i_time = '000000' ).
        " Act
        FINAL(date_string) = cut->as_string( ).
        " Assert
        cl_abap_unit_assert=>assert_equals( exp = '04.05.2020 00:00:00'
                                            act = date_string ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD time_zone1.
    " Arrange
    TRY.
        cut = NEW #( i_date      = '20200504'
                     i_time      = '111235'
                     i_time_zone = cl_abap_context_info=>get_user_time_zone( ) ).
        " Act
        FINAL(date_string) = cut->as_string( ).
        " Assert
        cl_abap_unit_assert=>assert_equals( exp = '04.05.2020 11:12:35'
                                            act = date_string ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD time_zone2.
    " Arrange
    TRY.
        cut = NEW #( i_date      = '20200504'
                     i_time      = '111235'
                     i_time_zone = 'UTC' ).
        " Act
        FINAL(user_time) = cut->convert_to_time_zone( 'UTC+1' ).
        FINAL(date_string) = user_time->as_string( ).
        " Assert
        cl_abap_unit_assert=>assert_equals( exp = '04.05.2020 12:12:35'
                                            act = date_string ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
