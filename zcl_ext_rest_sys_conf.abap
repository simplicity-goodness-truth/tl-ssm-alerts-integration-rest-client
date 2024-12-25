class zcl_ext_rest_sys_conf definition
  public
  final
  create public .

  public section.

    interfaces zif_ext_rest_sys_conf .

    methods constructor
      importing
        ip_ext_rest_system_name type ac_reaction_id
      raising
        zcx_ext_rest_sys_exc.

  protected section.
  private section.

    data:
      mv_active_profile       type ac_reaction_id,
      mt_active_configuration type table of zextrstsys_setup.

    methods:

      set_active_profile
        importing
          ip_ext_rest_system_name type ac_reaction_id
        raising
          zcx_ext_rest_sys_exc,

      set_active_configuration
        raising
          zcx_ext_rest_sys_exc,

      get_values_from_db_by_mask
        importing
          ip_param_name_mask   type char50
        returning
          value(rt_parameters) type  zextrstsys_tt_setup
        raising
          zcx_ext_rest_sys_exc,

      get_value_from_active_config
        importing
          ip_param_name   type char50
        returning
          value(rp_value) type text200
        raising
          zcx_ext_rest_sys_exc.

endclass.



class zcl_ext_rest_sys_conf implementation.

  method zif_ext_rest_sys_conf~get_parameter_value.

    data: lv_param_name   type char50.

    lv_param_name = |{ mv_active_profile }| && |.| && |{ ip_param_name }|.

    rp_value = me->get_value_from_active_config( lv_param_name ).

  endmethod.

  method constructor.

    me->set_active_profile( ip_ext_rest_system_name ).
    me->set_active_configuration(  ).


  endmethod.

  method set_active_profile.

    mv_active_profile = ip_ext_rest_system_name.

  endmethod.

  method set_active_configuration.

    data lv_parameter_mask type char50.

    lv_parameter_mask = |{ mv_active_profile }| && |.| && |%|.

    select param value from zextrstsys_setup
        into corresponding fields of table mt_active_configuration
        where param like lv_parameter_mask.


  endmethod.

  method zif_ext_rest_sys_conf~get_parameters_values_by_mask.

    data: lv_param_mask   type char50.

    lv_param_mask = |{ mv_active_profile }| && |.| && |%| && |{ ip_param_name_mask }|  && |%|.

    rt_parameters = me->get_values_from_db_by_mask( lv_param_mask ).


  endmethod.

  method get_values_from_db_by_mask.

    select param value from zextrstsys_setup
        into table rt_parameters
            where param like ip_param_name_mask.

  endmethod.

  method get_value_from_active_config.

    data:
      ls_parameter_line type zextrstsys_setup,
      lv_param          type char50,
      lv_text_token_1   type string,
      lv_text_token_2   type string.

    try.
        lv_param = ip_param_name.

        translate lv_param to upper case.

        ls_parameter_line = mt_active_configuration[ param = lv_param ].

        rp_value = ls_parameter_line-value.

      catch cx_sy_itab_line_not_found.

        lv_text_token_1  = lv_param.
        lv_text_token_2  = mv_active_profile.

        raise exception type zcx_ext_rest_sys_exc
          exporting
            textid          = zcx_ext_rest_sys_exc=>ext_sys_param_not_found
            ip_text_token_1 = lv_text_token_1
            ip_text_token_2 = lv_text_token_2.

    endtry.


  endmethod.

endclass.