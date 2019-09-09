class ZCL_MOCKUP_LOADER_DEMO definition
  public
  final
  create public .

public section.

  class-methods sum_of_doc_lines
    importing
      !it_tab type zdoc_line_tab
    returning
      value(rv_sum) type dmbtr .
  protected section.
  private section.
ENDCLASS.



CLASS ZCL_MOCKUP_LOADER_DEMO IMPLEMENTATION.


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
