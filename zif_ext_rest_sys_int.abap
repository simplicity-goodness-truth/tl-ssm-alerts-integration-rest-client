interface zif_ext_rest_sys_int
  public .


methods:
  send_payload_json_as_post_req
    raising
      zcx_ext_rest_sys_exc ,

  set_payload_json
    importing
      !ip_rest_api_payload_json type string,

  get_response_string
    returning
      value(rp_response_string) type string,

  send_hb_payload
    raising
      zcx_ext_rest_sys_exc.

  endinterface.