interface zif_mockup_loader_demo_daccess
  public .

  methods select_doc_lines
    importing
      i_belnr type belnr_d
    returning
      value(r_doc_lines) type zdoc_line_tab.

endinterface.
