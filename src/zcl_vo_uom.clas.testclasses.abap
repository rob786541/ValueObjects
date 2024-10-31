CLASS ltcl_uom DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    DATA cut TYPE REF TO zcl_vo_uom.
    DATA e   TYPE REF TO zcx_value_object.

    METHODS enter_out          FOR TESTING.
    METHODS enter_in           FOR TESTING.
    METHODS enter_lower        FOR TESTING.
    METHODS enter_non_existing FOR TESTING.
    METHODS enter_empty        FOR TESTING.
    METHODS enter_to_ton       FOR TESTING.
    METHODS integrity          FOR TESTING.
    METHODS performance        FOR TESTING.

ENDCLASS.


CLASS ltcl_uom IMPLEMENTATION.
  METHOD enter_out.
    TRY.
        cut = NEW #( 'PC' ).
        cl_abap_unit_assert=>assert_equals( exp = 'ST'
                                            act = cut->get_in( ) ).
        cl_abap_unit_assert=>assert_equals( exp = 'PC'
                                            act = cut->get_out( ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD enter_in.
    TRY.
        cut = NEW #( 'ST' ).
        cl_abap_unit_assert=>assert_equals( exp = 'ST'
                                            act = cut->get_in( ) ).
        cl_abap_unit_assert=>assert_equals( exp = 'PC'
                                            act = cut->get_out( ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD enter_non_existing.
    TRY.
        cut = NEW #( 'asd' ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_value_object INTO e.
        cl_abap_unit_assert=>assert_equals( exp = 'UOM asd is not valid'
                                            act = e->get_text( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD enter_empty.
    TRY.
        cut = NEW #( '' ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_value_object INTO e.
        cl_abap_unit_assert=>assert_equals( exp = 'Empty UOM is not allowed'
                                            act = e->get_text( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD enter_lower.
    TRY.
        cut = NEW #( 'kg' ).
        cl_abap_unit_assert=>assert_equals( exp = 'KG'
                                            act = cut->get_in( ) ).
        cl_abap_unit_assert=>assert_equals( exp = 'KG'
                                            act = cut->get_out( ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD enter_to_ton.
    TRY.
        cut = NEW #( 'to' ).
        cl_abap_unit_assert=>assert_equals( exp = 'TO'
                                            act = cut->get_in( ) ).
        cl_abap_unit_assert=>assert_equals( exp = 'TO'
                                            act = cut->get_out( ) ).

        cut = NEW #( 'ton' ).
        cl_abap_unit_assert=>assert_equals( exp = 'TON'
                                            act = cut->get_in( ) ).
        cl_abap_unit_assert=>assert_equals( exp = 'TON'
                                            act = cut->get_out( ) ).
        sy-langu = 'F'.
        cut = NEW #( 'to' ).
        cl_abap_unit_assert=>assert_equals( exp = 'TO'
                                            act = cut->get_in( ) ).
        cl_abap_unit_assert=>assert_equals( exp = 'TON'
                                            act = cut->get_out( ) ).
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD performance.
    DATA i TYPE i.

    TRY.
        SELECT msehi FROM t006 INTO TABLE @DATA(uoms) UP TO 100 ROWS.
        DO 50000 TIMES.
          i += 1.
          cut = NEW #( uoms[ i ]-msehi ).
          i = COND #( WHEN i = 100 THEN 0 ).
        ENDDO.
      CATCH zcx_value_object.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  ENDMETHOD.

  METHOD integrity.
    DATA uoms TYPE SORTED TABLE OF t006b WITH UNIQUE KEY mandt spras mseh3
        WITH UNIQUE SORTED KEY skey COMPONENTS mandt spras msehi.

    SELECT * FROM t006b INTO TABLE @uoms.
    LOOP AT uoms INTO DATA(wa)
         GROUP BY wa-spras
         INTO DATA(key).
      LOOP AT GROUP key ASSIGNING FIELD-SYMBOL(<members>).
        SELECT SINGLE @abap_true FROM @uoms AS uoms
          WHERE spras = @<members>-spras
            AND mseh3 = @<members>-msehi AND msehi <> @<members>-msehi
          INTO @DATA(found).
        IF found = abap_true.
          cl_abap_unit_assert=>fail(
              msg = |UOM is internal and external: spras { <members>-spras }, mseh3/msehi { <members>-msehi }| ).
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.