class ltcl_demo_test definition final
  for testing
  duration short
  risk level harmless.

  public section.

    types:
      begin of ty_test_index,
        testid     type i,
        belnr      type belnr_d,
        sum        type dmbtr,
        test_title type string,
      end of ty_test_index,
      tt_test_index type standard table of ty_test_index with key testid.

  private section.
    class-data g_ml type ref to zcl_mockup_loader.
    class-methods class_setup raising zcx_mockup_loader_error.

    methods get_test_index
      returning
        value(r_test_index) type tt_test_index
      raising
        zcx_mockup_loader_error.

    methods test_sum_of_doc_lines for testing raising zcx_mockup_loader_error.
    methods test_sum_multiple for testing raising zcx_mockup_loader_error.
    methods test_with_store for testing raising zcx_mockup_loader_error.
    methods test_with_double for testing raising zcx_mockup_loader_error.

endclass.

class ltcl_demo_test implementation.

  method class_setup.
    g_ml = zcl_mockup_loader=>create( 'ZMOCKUP_LOADER_DEMO' ).
    g_ml->set_params( i_encoding = conv #( cl_lxe_constants=>c_sap_codepage_utf8 ) ).
  endmethod.

  method get_test_index.

    g_ml->load_data(
      exporting
        i_obj    = 'TEST-SUITE1/_index'
        i_strict = abap_true
      importing
        e_container = r_test_index ).

  endmethod.

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

    data test_index type table of ty_test_index.
    ml->load_data(
      exporting
        i_obj    = 'TEST-SUITE1/_index'
        i_strict = abap_true
      importing
        e_container = test_index ).

    loop at test_index assigning field-symbol(<i>).
      data doc_lines type zdoc_line_tab. " container for loaded lines
*      ml->load_data(
*        exporting
*          i_obj    = 'TEST-SUITE1/doc_lines_suite2'
*          i_strict = abap_false
*          i_where  = zcl_mockup_loader_utils=>conv_single_val_to_filter(
*            i_where = 'BELNR'
*            i_value = <i>-belnr )
*        importing
*          e_container = doc_lines ).

*      ml->load_data(
*        exporting
*          i_obj    = 'TEST-SUITE1/doc_lines_suite2'
*          i_strict = abap_false
*          i_where  = value zcl_mockup_loader_utils=>tt_filter(
*            ( type   = zcl_mockup_loader_utils=>c_filter_type-value
*              name   = 'BELNR'
*              valref = ref #( <i>-belnr )
*             ) )
*        importing
*          e_container = doc_lines ).

      ml->load_data(
        exporting
          i_obj    = 'TEST-SUITE1/doc_lines_suite2'
          i_strict = abap_false
          i_where  = |BELNR = { <i>-belnr }|
        importing
          e_container = doc_lines ).

      data(sum_act) = zcl_mockup_loader_demo=>sum_of_doc_lines( doc_lines ).
      cl_abap_unit_assert=>assert_equals(
        act = sum_act
        exp = <i>-sum
        msg = <i>-test_title ).

    endloop.

  endmethod.

  method test_with_store.

    data(test_index) = get_test_index( ).

    data doc_lines type zdoc_line_tab.
    g_ml->load_data(
      exporting
        i_obj    = 'TEST-SUITE1/doc_lines_suite2'
        i_strict = abap_false
      importing
        e_container = doc_lines ).

    data(ml_store) = zcl_mockup_loader_store=>get_instance( ). " SINGLETON !!!
    ml_store->store(
      i_name   = 'DOC_LINES'
      i_tabkey = 'BELNR'
      i_data   = doc_lines ).

    g_ml->load_and_store(
      i_obj    = 'TEST-SUITE1/doc_lines_suite2'
      i_strict = abap_false
      i_type   = 'ZDOC_LINE_TAB'                              " The type must be public
*      i_type_desc = cl_abap_typedescr=>describe_by_name( 'ZDOC_LINE_TAB' )
      i_name   = 'DOC_LINES'
      i_tabkey = 'BELNR' ).

    loop at test_index assigning field-symbol(<i>).

      data(sum_act) = zcl_mockup_loader_demo=>select_and_sum_doc_lines( <i>-belnr ).

      cl_abap_unit_assert=>assert_equals(
        act = sum_act
        exp = <i>-sum
        msg = <i>-test_title ).

    endloop.

  endmethod.

  method test_with_double.

    data(stub_factory) = new zcl_mockup_loader_stub_factory(
      io_ml_instance   = g_ml
      i_interface_name = 'ZIF_MOCKUP_LOADER_DEMO_DACCESS' ).

    stub_factory->connect_method(
      i_method_name     = 'SELECT_DOC_LINES'
      i_mock_name       = 'TEST-SUITE1/doc_lines_suite2'
      i_sift_param      = 'I_BELNR'
      i_mock_tab_key    = 'BELNR' ).

    data(test_index) = get_test_index( ).

    data(ifstub) = cast zif_mockup_loader_demo_daccess( stub_factory->generate_stub( ) ).

    data(cut) = new zcl_mockup_loader_demo( ifstub ).

    loop at test_index assigning field-symbol(<i>).
      data(sum_act) = cut->select_and_sum_with_da( <i>-belnr ).
      cl_abap_unit_assert=>assert_equals(
        act = sum_act
        exp = <i>-sum
        msg = <i>-test_title ).
    endloop.

  endmethod.

endclass.
