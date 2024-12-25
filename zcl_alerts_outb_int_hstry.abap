class zcl_alerts_outb_int_hstry definition
  public
  create public .

  public section.

    class-methods get_instance
      returning
        value(rr_alerts_outbound_history) type ref to zcl_alerts_outb_int_hstry .
    methods add_record
      importing
        !io_alert           type ref to zif_alert_for_outb_int
        !ip_alert_payload   type string
        !ip_log_record_text type string optional
        !ip_ext_system_name type ac_reaction_id .
  protected section.
  private section.

    class-data mo_alerts_outbound_history type ref to zcl_alerts_outb_int_hstry .
    data: ms_history_record      type zalroutint_hstry,
          mo_alert               type ref to zif_alert_base,
          mv_alert_payload       type string,
          mv_log_record_text     type string,
          mv_ext_system_name     type ac_reaction_id,
          mv_ext_system_response type string.

    methods:
      insert_history_record_to_db,

      set_alert_attributes
        importing
          !io_alert           type ref to zif_alert_base
          !ip_alert_payload   type string
          !ip_log_record_text type string optional
          !ip_ext_system_name type ac_reaction_id,

      set_history_record,

      generate_x16_guid
        returning
          value(rp_sysuuid_x16_guid) type sysuuid_x16 .

ENDCLASS.



CLASS ZCL_ALERTS_OUTB_INT_HSTRY IMPLEMENTATION.


  method add_record.

    set_alert_attributes(
      exporting
        io_alert           = io_alert
        ip_alert_payload   = ip_alert_payload
        ip_log_record_text = ip_log_record_text
        ip_ext_system_name = ip_ext_system_name
    ).

    set_history_record( ).

    insert_history_record_to_db( ).

  endmethod.


  method generate_x16_guid.

    " Standard generation of X16 GUID

    try.
        rp_sysuuid_x16_guid = cl_system_uuid=>create_uuid_x16_static( ).

      catch cx_uuid_error.
        rp_sysuuid_x16_guid = '0'.
    endtry.

  endmethod.


  method get_instance.

    if mo_alerts_outbound_history is initial.

      mo_alerts_outbound_history = new #( ).

    endif.

    rr_alerts_outbound_history = mo_alerts_outbound_history.

  endmethod.


  method insert_history_record_to_db.

    insert zalroutint_hstry from ms_history_record.

  endmethod.


  method set_alert_attributes.

    mo_alert = io_alert.
    mv_alert_payload = ip_alert_payload.
    mv_log_record_text = ip_log_record_text.
    mv_ext_system_name = ip_ext_system_name.

  endmethod.


  method set_history_record.

    data: lv_sysuuid_x16_guid type sysuuid_x16.

    lv_sysuuid_x16_guid = generate_x16_guid( ).

    ms_history_record-ext_system_name = mv_ext_system_name.
    ms_history_record-alert_guid = mo_alert->get_guid( ).
    ms_history_record-alert_name = mo_alert->get_name(  ).
    ms_history_record-alert_technical_name = mo_alert->get_technical_name(  ).
    ms_history_record-description = mo_alert->get_description( ).
    ms_history_record-managed_object_name = mo_alert->get_managed_object_name( ).
    ms_history_record-payload = mv_alert_payload.
    ms_history_record-record_guid = lv_sysuuid_x16_guid.
    ms_history_record-technical_scenario = mo_alert->get_technical_scenario( ).
    ms_history_record-utc_timestamp = mo_alert->get_utc_timestamp(  ).

    if ( mv_log_record_text is not initial ).
      ms_history_record-error_text = mv_log_record_text.
      ms_history_record-failed = 'X'.
    endif.

  endmethod.
ENDCLASS.