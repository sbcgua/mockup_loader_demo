class ltcl_demo_test definition final
  for testing
  duration short
  risk level harmless.

  private section.

    methods test_sum_of_doc_lines for testing raising zcx_mockup_loader_error.
    methods test_sum_multiple for testing raising zcx_mockup_loader_error.

endclass.

class ltcl_demo_test implementation.

  method test_sum_of_doc_lines.

    data(ml) = zcl_mockup_loader=>create( 'ZMOCKUP_LOADER_DEMO' ).
    ml->set_params( i_encoding = conv #( cl_lxe_constants=>c_sap_codepage_utf8 ) ).

    data doc_lines type zdoc_line_tab. " container for loaded lines
    ml->load_data(
      exporting
        i_obj    = 'TEST-SUITE1/doc_lines_suite1'   " .txt is auto-appended
        i_strict = abap_false                       " ignore field, missing in the dource data
      importing
        e_container = doc_lines ).

    data(sum_act) = zcl_mockup_loader_demo=>sum_of_doc_lines( doc_lines ).

    cl_abap_unit_assert=>assert_equals( act = sum_act exp = '1000' ).

  endmethod.

  method test_sum_multiple.

    data(ml) = zcl_mockup_loader=>create( 'ZMOCKUP_LOADER_DEMO' ).
    ml->set_params( i_encoding = conv #( cl_lxe_constants=>c_sap_codepage_utf8 ) ).

    types:
      begin of ty_test_index,
        testid     type i,
        belnr      type belnr_d,
        sum        type dmbtr,
        test_title type string,
      end of ty_test_index.

    data test_index type table of ty_test_index.
    ml->load_data(
      exporting
        i_obj    = 'TEST-SUITE1/_index'
        i_strict = abap_true
      importing
        e_container = test_index ).

    loop at test_index assigning field-symbol(<i>).
      data doc_lines type zdoc_line_tab. " container for loaded lines
      ml->load_data(
        exporting
          i_obj    = 'TEST-SUITE1/doc_lines_suite2'
          i_strict = abap_false
          i_where  = zcl_mockup_loader_utils=>conv_single_val_to_filter(
            i_where = 'BELNR'
            i_value = <i>-belnr )
        importing
          e_container = doc_lines ).

      data(sum_act) = zcl_mockup_loader_demo=>sum_of_doc_lines( doc_lines ).
      cl_abap_unit_assert=>assert_equals(
        act = sum_act
        exp = <i>-sum
        msg = <i>-test_title ).

    endloop.

  endmethod.

endclass.
