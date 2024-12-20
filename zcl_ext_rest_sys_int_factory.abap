class zcl_ext_rest_sys_int_factory definition
  public
  create public .

  public section.

    interfaces zif_ext_rest_sys_int_factory .

    aliases create
      for zif_ext_rest_sys_int_factory~create .
  protected section.
  private section.
endclass.



class zcl_ext_rest_sys_int_factory implementation.


  method zif_ext_rest_sys_int_factory~create.

    data:
      lo_ext_rest_system_interface  type ref to zif_ext_rest_sys_int,
      lv_ext_rest_system_class_name type string,
      lv_ext_rest_system_name       type string.

    " Creating external REST-compliant system object
    " Naming convention used:
    " ZCL_EXT_REST_SYS_INT_<system name from BADI_ALERT_REACTION filter>

    lv_ext_rest_system_class_name = |ZCL_EXT_REST_SYS_INT_| && |{ ip_ext_rest_system_name }|.

    if strlen( lv_ext_rest_system_class_name ) ge 30.

      lv_ext_rest_system_name = ip_ext_rest_system_name.

      raise exception type zcx_ext_rest_sys_exc
        exporting
          textid          = zcx_ext_rest_sys_exc=>class_name_too_long
          ip_text_token_1 = lv_ext_rest_system_class_name
          ip_text_token_2 = lv_ext_rest_system_name.

    endif.

    create object lo_ext_rest_system_interface type (lv_ext_rest_system_class_name)
      exporting
        ip_ext_rest_system_name = ip_ext_rest_system_name
        ip_ext_rest_system_mode = ip_ext_rest_system_mode.

    ro_ext_rest_sys_int = lo_ext_rest_system_interface.

  endmethod.
endclass.