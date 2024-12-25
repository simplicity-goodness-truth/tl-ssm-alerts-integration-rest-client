interface zif_ext_rest_sys_conf
  public .

  methods: get_parameter_value
    importing
      ip_param_name   type char50
    returning
      value(rp_value) type text200
    raising
      zcx_ext_rest_sys_exc,

    get_parameters_values_by_mask
      importing
        ip_param_name_mask   type char50
      returning
        value(rt_parameters) type zextrstsys_tt_setup
      raising
        zcx_ext_rest_sys_exc.

endinterface.