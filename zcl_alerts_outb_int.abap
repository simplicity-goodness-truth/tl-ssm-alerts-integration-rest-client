class zcl_alerts_outb_int definition
  public
  final
  create public .

  public section.

    interfaces if_alert_reaction .
    interfaces if_badi_interface .
  protected section.
  private section.

    data:
      mv_list_of_restsys_to_save_hst type text200,
      mo_alert                       type ref to zif_alert_for_outb_int,
      mv_alert_payload               type string,
      mv_ext_rest_system_name        type ac_reaction_id,
      mv_log_record_text             type string,
      mt_json_custom_fields          type zalroutint_tt_custom_json_flds.

    methods:
      add_rest_sys_hstry_rec,

      is_rest_sys_set_for_hstry_rec
        importing
          !ip_ext_rest_system_name            type ac_reaction_id
        returning
          value(rp_set_for_history_recording) type abap_bool ,

      set_custom_payload_fields ,

      set_runtime_parameters
        raising
          zcx_alerts_outb_int_exc ,

      get_setup_parameter
        importing
          !ip_param_name  type char50
        returning
          value(ep_value) type text100
        raising
          zcx_alerts_outb_int_exc .
endclass.



class zcl_alerts_outb_int implementation.


  method add_rest_sys_hstry_rec.

    data lo_alerts_outbound_history type ref to zcl_alerts_outb_int_hstry.

    if ( is_rest_sys_set_for_hstry_rec( mv_ext_rest_system_name ) eq abap_true ).

      lo_alerts_outbound_history = zcl_alerts_outb_int_hstry=>get_instance( ).

      lo_alerts_outbound_history->add_record(
        exporting
          io_alert           = mo_alert
          ip_alert_payload   = mv_alert_payload
          ip_log_record_text = mv_log_record_text
          ip_ext_system_name = mv_ext_rest_system_name ).

    endif. " if ( is_rest_sys_set_for_hstry_rec( mv_ext_rest_system_name ) eq abap_true )


  endmethod.


  method get_setup_parameter.

    data:
      lv_param_name   type char50,
      lv_text_token_1 type string,
      lv_text_token_2 type string.

    select single value from zalroutint_setup
     into ep_value
       where param eq ip_param_name.

    if sy-subrc ne 0.

      lv_text_token_1  = ip_param_name.

      raise exception type zcx_alerts_outb_int_exc
        exporting
          textid = zcx_alerts_outb_int_exc=>alr_out_int_param_not_found.
    endif. " if sy-subrc ne 0

  endmethod.


  method if_alert_reaction~is_auto_reaction.
  endmethod.


  method if_alert_reaction~react_to_alerts.

    data:

      lo_ext_rest_system_interface type ref to zif_ext_rest_sys_int,
      lo_log                       type ref to zcl_logger_to_app_log,
      lr_zcx_ext_rest_system_exc   type ref to zcx_ext_rest_sys_exc,
      lo_ext_rest_sys_int_factory  type ref to zif_ext_rest_sys_int_factory.

    " Getting application logger instance
    lo_log = zcl_logger_to_app_log=>get_instance( ).

    try.

        " Setting runtime parameters
        set_runtime_parameters( ).

        " Setting system name
        mv_ext_rest_system_name = ip_filter_val.

        " Creating alert object
        mo_alert = new zcl_alert_for_outb_int( ipt_alerts ).

        " Preparing custom payload fields
        set_custom_payload_fields( ).

        if mt_json_custom_fields is not initial.

          mo_alert->set_custom_payload_fields( mt_json_custom_fields ).

        endif.

        " Setting alert payload JSON
        mv_alert_payload  = mo_alert->zif_alert_base~get_alert_serialized_in_json( ).

        if mv_alert_payload  is not initial.

          " Creating external ticketing system

          lo_ext_rest_sys_int_factory = new zcl_ext_rest_sys_int_factory( ).

          try.

              lo_ext_rest_system_interface = lo_ext_rest_sys_int_factory->create(
                  ip_ext_rest_system_name = mv_ext_rest_system_name
                  ip_ext_rest_system_mode = 'AI').

              if lo_ext_rest_system_interface is bound.

                lo_ext_rest_system_interface->set_payload_json( mv_alert_payload ).

                lo_ext_rest_system_interface->send_payload_json_as_post_req( ).

                add_rest_sys_hstry_rec( ).


              endif. "if lo_ext_rest_system_interface is bound.

            catch zcx_ext_rest_sys_exc into lr_zcx_ext_rest_system_exc.

              mv_log_record_text = lr_zcx_ext_rest_system_exc->get_text( ).

              mv_log_record_text = |Alerts Outbound Interface Failure: | && | | && |{ mv_log_record_text }|.

              lo_log->err( mv_log_record_text ).

              add_rest_sys_hstry_rec( ).

          endtry.


        endif. " if lv_alert_payload  is not initial

      catch zcx_alerts_outb_int_exc into data(lo_alert_out_interface_error) .

    endtry.


  endmethod.


  method if_alert_reaction~react_to_closed_alert.
  endmethod.


  method is_rest_sys_set_for_hstry_rec.

    if mv_list_of_restsys_to_save_hst  is initial.
      return.
    endif.

    search mv_list_of_restsys_to_save_hst for ip_ext_rest_system_name.

    if (  sy-subrc eq 0 ).

      rp_set_for_history_recording = abap_true.

    endif.

  endmethod.


  method set_custom_payload_fields.

    select name value into table
      mt_json_custom_fields from zalroutint_cjsnf
      where  ext_system_name = mv_ext_rest_system_name.

  endmethod.


  method set_runtime_parameters.

    mv_list_of_restsys_to_save_hst = get_setup_parameter('LIST_OF_EXT_REST_SYS_TO_SAVE_IN_HISTORY').

  endmethod.
endclass.