interface zif_ext_rest_sys_int_factory
  public .


  methods create
    importing
      !ip_ext_rest_system_name   type ac_reaction_id
      ip_ext_rest_system_mode    type char10 optional
    returning
      value(ro_ext_rest_sys_int) type ref to zif_ext_rest_sys_int
    raising
      zcx_ext_rest_sys_exc .
endinterface.