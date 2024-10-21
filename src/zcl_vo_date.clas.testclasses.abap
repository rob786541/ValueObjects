CLASS ltc_unit_test DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    DATA cut TYPE REF TO zcl_vo_date.

    CONSTANTS initial_date TYPE d VALUE '00000000'.

    METHODS constructor1      FOR TESTING.
    METHODS constructor2      FOR TESTING.
    METHODS constructor3      FOR TESTING.
    METHODS input_validation1 FOR TESTING.
    METHODS input_validation2 FOR TESTING.
    METHODS input_validation3 FOR TESTING.
    METHODS input_validation4 FOR TESTING.
    METHODS input_validation5 FOR TESTING.
    METHODS equals1           FOR TESTING.
    METHODS equals2           FOR TESTING.
    METHODS equals3           FOR TESTING.

ENDCLASS.


CLASS ltc_unit_test IMPLEMENTATION.
  METHOD constructor1.
    " Arrange
    cut = NEW #( ).
    " Act
    IF cut IS NOT BOUND.
      " Assert
      cl_abap_unit_assert=>fail( ).
    ENDIF.
  ENDMETHOD.

  METHOD constructor2.
    " Arrange
    cut = NEW #( ).
    " Act
    FINAL(date) = cut->get_date( ).
    " Assert
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_context_info=>get_system_date( )
                                        act = date ).
  ENDMETHOD.

  METHOD constructor3.
    " Arrange
    cut = NEW #( i_date = '19951005' ).
    " Act
    FINAL(date) = cut->get_date( ).
    " Assert
    cl_abap_unit_assert=>assert_equals( exp = '19951005'
                                        act = date ).
  ENDMETHOD.

  METHOD input_validation1.
    " Arrange
    cut = NEW #( i_date = '20203131' ).
    " Act
    FINAL(date) = cut->get_date( ).
    " Assert
    cl_abap_unit_assert=>assert_equals( exp = initial_date
                                        act = date ).
  ENDMETHOD.

  METHOD input_validation2.
    " Arrange
    cut = NEW #( i_time = '115999' ).
    " Act
    FINAL(date) = cut->get_date( ).
    " Assert
    cl_abap_unit_assert=>assert_equals( exp = initial_date
                                        act = date ).
  ENDMETHOD.

  METHOD input_validation3.
    " Arrange
    cut = NEW #( i_date = '20203131'
                 i_time = '115999' ).
    " Act
    FINAL(date) = cut->get_date( ).
    " Assert
    cl_abap_unit_assert=>assert_equals( exp = initial_date
                                        act = date ).
  ENDMETHOD.

  METHOD input_validation4.
    " Arrange
    cut = NEW #( i_date = '202AC131'
                 i_time = '115959' ).
    " Act
    FINAL(date) = cut->get_date( ).
    " Assert
    cl_abap_unit_assert=>assert_equals( exp = initial_date
                                        act = date ).
  ENDMETHOD.

  METHOD input_validation5.
    " Arrange
    cut = NEW #( i_date = '20200504'
                 i_time = '11CD99' ).
    " Act
    FINAL(date) = cut->get_date( ).
    " Assert
    cl_abap_unit_assert=>assert_equals( exp = initial_date
                                        act = date ).
  ENDMETHOD.

  METHOD equals1.
    " Arrange
    cut = NEW #( i_date = '20200504'
                 i_time = '111235' ).
    FINAL(second_obj) = NEW zcl_vo_date( i_date = '20200504'
                                         i_time = '111235' ).
    " Act
    FINAL(act) = cut->is_equal_to( second_obj ).
    " Assert
    cl_abap_unit_assert=>assert_true( act ).
  ENDMETHOD.

  METHOD equals2.
    " Arrange
    cut = NEW #( i_date = '20200504'
                 i_time = '111235' ).
    FINAL(second_obj) = NEW zcl_vo_date( i_date = '20200504'
                                         i_time = '111235' ).
    " Act
    FINAL(act) = second_obj->is_equal_to( cut ).
    " Assert
    cl_abap_unit_assert=>assert_true( act ).
  ENDMETHOD.

  METHOD equals3.
    " Arrange
    cut = NEW #( i_date = '20200504'
                 i_time = '111235' ).
    FINAL(second_obj) = NEW zcl_vo_date( i_date = '20200504'
                                         i_time = '111236' ).
    " Act
    FINAL(act) = second_obj->is_equal_to( cut ).
    " Assert
    cl_abap_unit_assert=>assert_false( act ).
  ENDMETHOD.
ENDCLASS.
