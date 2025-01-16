interface zif_alert_ci_mgr
  public .

  methods:
    get_alert_sid
      returning
        value(rp_sid) type ac_string ,

    get_ke_by_alert_sid
      returning
        value(rp_ke) type zesm_ke,

    get_context_id
      returning
        value(rp_context_id) type ac_guid.

endinterface.