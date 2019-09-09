class ltcl_demo_test definition final
  for testing
  duration short
  risk level harmless.

  private section.

    methods test_sum_of_doc_lines for testing raising zcx_mockup_loader_error.

endclass.

class ltcl_demo_test implementation.

  method test_sum_of_doc_lines.

    data(ml) = zcl_mockup_loader=>create( 'ZMOCKUP_LOADER_DEMO' ).
    ml->set_params( i_encoding = conv #( cl_lxe_constants=>c_sap_codepage_utf16 ) ).

    data doc_lines type zdoc_line_tab. " container for loaded lines
    ml->load_data(
      exporting
        i_obj    = 'doc_lines'         " .txt is auto-appended
        i_strict = abap_false          " ignore field, missing in the dource data
      importing
        e_container = doc_lines ).

    data(sum_act) = zcl_mockup_loader_demo=>sum_of_doc_lines( doc_lines ).

    cl_abap_unit_assert=>assert_equals( act = sum_act exp = '1000' ).

  endmethod.

endclass.
