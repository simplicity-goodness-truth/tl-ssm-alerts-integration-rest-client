interface zif_alert_base
  public .

  methods:

    get_alert_serialized_in_json
      returning
        value(rp_alert_serialized_in_json) type string ,

    get_name
      returning
        value(rp_name) type string,
    get_managed_object_name
      returning
        value(rp_managed_object_name) type string,

    get_managed_object_type
      returning
        value(rp_managed_object_type) type string,

    get_managed_object_id
      returning
        value(rp_managed_object_id) type string,

    get_category
      returning
        value(rp_category) type ac_category,

    get_severity
      returning
        value(rp_severity) type ac_severity,

    get_utc_timestamp
      returning
        value(rp_utc_timestamp) type string,

    get_rating
      returning
        value(rp_rating) type string,

    get_status
      returning
        value(rp_status) type string,

    get_guid
      returning
        value(rp_guid) type string,

    get_description
      returning
        value(rp_description) type string,

    get_custom_description
      returning
        value(rp_custom_description) type string,

    get_technical_scenario
      returning
        value(rp_technical_scenario) type  ac_technical_scenario,

    get_technical_name
      returning
        value(rp_technical_name) type ac_name,

    get_metrics_data
      returning
        value(rt_metrics_data) type zalroutint_tt_metrics,

    get_epoch_utc_timestamp
      returning
        value(rp_epoch_utc_timestamp) type string,

    get_first_non_green_metric
      returning
        value(rs_metric) type zalroutint_ts_metric.

endinterface.