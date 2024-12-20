class zcl_ext_rest_sys_hb_exec definition
  public
  final
  create public .

  public section.

    interfaces zif_ext_rest_sys_hb_exec.

    methods:
      constructor
        importing
          ip_use_case type char10 optional.

  protected section.
  private section.

    data mt_sys_list_for_hb_request type table of ac_reaction_id.

    methods:
      set_sys_list_for_hb_request.

endclass.



class zcl_ext_rest_sys_hb_exec implementation.

  method zif_ext_rest_sys_hb_exec~execute.

    data: lo_ext_rest_system_interface type ref to zif_ext_rest_sys_int,
          lr_zcx_ext_rest_system_exc   type ref to zcx_ext_rest_sys_exc,
          lo_ext_rest_sys_int_factory  type ref to zif_ext_rest_sys_int_factory.

    loop at mt_sys_list_for_hb_request assigning field-symbol(<fs_ext_rest_sys>).

      if ip_ext_rest_sys is not initial.

        if <fs_ext_rest_sys> ne ip_ext_rest_sys.

          continue.

        endif.

      endif.

      lo_ext_rest_sys_int_factory = new zcl_ext_rest_sys_int_factory( ).

      try.

          lo_ext_rest_system_interface = lo_ext_rest_sys_int_factory->create(
            ip_ext_rest_system_name = <fs_ext_rest_sys>
            ip_ext_rest_system_mode = 'HB'
            ).

          if lo_ext_rest_system_interface is bound.

            lo_ext_rest_system_interface->send_hb_payload( ).


          endif. "if lo_ext_rest_system_interface is bound.

        catch zcx_ext_rest_sys_exc into lr_zcx_ext_rest_system_exc.

        raise exception type zcx_ext_rest_sys_exc
          exporting
            textid          = zcx_ext_rest_sys_exc=>heartbeat_failure
            ip_text_token_1 = lr_zcx_ext_rest_system_exc->get_longtext( ).

      endtry.


    endloop.

  endmethod.

  method set_sys_list_for_hb_request.

    data: lt_ext_rest_sys_act_hb_params type table of char50,
          wa_sys_for_hb_request         type ac_reaction_id.

    select param from zextrstsys_setup
    into table lt_ext_rest_sys_act_hb_params
      where param like '%HEARTBEAT.ACTIVE'
      and value eq 'X'.

    loop at lt_ext_rest_sys_act_hb_params assigning field-symbol(<ls_ext_rest_sys_act_hb_param>).

      wa_sys_for_hb_request = substring_before( val = <ls_ext_rest_sys_act_hb_param> sub = '.' ).

      append wa_sys_for_hb_request to mt_sys_list_for_hb_request.

    endloop.

  endmethod.

  method constructor.

    me->set_sys_list_for_hb_request( ).

  endmethod.

endclass.