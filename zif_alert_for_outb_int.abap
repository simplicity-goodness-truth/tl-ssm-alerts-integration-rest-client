interface zif_alert_for_outb_int
  public .


  interfaces zif_alert_base .

  methods set_custom_payload_fields
    importing
      !it_custom_json_fields type zalroutint_tt_custom_json_flds .
endinterface.