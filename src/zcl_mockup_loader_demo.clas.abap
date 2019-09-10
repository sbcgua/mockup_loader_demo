class ZCL_MOCKUP_LOADER_DEMO definition
  public
  final
  create public .

  public section.

    class-methods sum_of_doc_lines
      importing
        it_tab type zdoc_line_tab
      returning
        value(rv_sum) type dmbtr .

    class-methods select_and_sum_doc_lines
      importing
        i_belnr type belnr_d
      returning
        value(rv_sum) type dmbtr .

    methods constructor
      importing
        ii_data_accessor type ref to zif_mockup_loader_demo_daccess.

    methods select_and_sum_with_da
      importing
        i_belnr type belnr_d
      returning
        value(rv_sum) type dmbtr .

  protected section.
  private section.
    data mi_data_accessor type ref to zif_mockup_loader_demo_daccess.

ENDCLASS.



CLASS ZCL_MOCKUP_LOADER_DEMO IMPLEMENTATION.


  method constructor.
    mi_data_accessor = ii_data_accessor.
  endmethod.


  method select_and_sum_doc_lines.

    data doc_lines type zdoc_line_tab.
    select * from zdoc_line
      into table doc_lines
      where belnr = i_belnr.

    if sy-subrc = 0.
      rv_sum = sum_of_doc_lines( doc_lines ).
    endif.

  endmethod.


  method select_and_sum_with_da.

    data doc_lines type zdoc_line_tab.
    doc_lines = mi_data_accessor->select_doc_lines( i_belnr ).

    if sy-subrc = 0.
      rv_sum = sum_of_doc_lines( doc_lines ).
    endif.

  endmethod.


  method sum_of_doc_lines.

    loop at it_tab assigning field-symbol(<i>).
      if <i>-shkzg = 'S'.             " Debit (positive)
        rv_sum = rv_sum + <i>-dmbtr.
      elseif <i>-shkzg = 'H'.         " Credit (negative)
        rv_sum = rv_sum - <i>-dmbtr.
      endif.
    endloop.

  endmethod.
ENDCLASS.
