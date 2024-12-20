interface zif_ext_rest_sys_hb_exec
  public .

  methods:
    execute
      importing
        ip_ext_rest_sys type ac_reaction_id optional
      raising
        zcx_ext_rest_sys_exc.

endinterface.