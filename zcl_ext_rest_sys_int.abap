class zcl_ext_rest_sys_int definition
  public
  create public .

  public section.

    interfaces zif_ext_rest_sys_int.

    methods constructor
      importing
        ip_ext_rest_system_name type ac_reaction_id
        ip_ext_rest_system_mode type char10 optional
      raising
        zcx_ext_rest_sys_exc .
  protected section.

    data:
      mt_request_headers type bbpt_http_param,
      mv_hb_payload      type string.

    methods:

      prepare_request_headers
        raising
          cx_abap_message_digest,

      set_heartbeat_payload
        raising
          zcx_ext_rest_sys_exc.

  private section.

    data:
      mv_ext_rest_system_name      type ac_reaction_id,
      mv_rest_api_rfc_dest_name    type rfcdest,
      mv_hb_rest_api_rfc_dest_name type rfcdest,
      mv_rest_api_payload_json     type string,
      mv_ai_app_log_object         type balobj_d,
      mv_ai_app_log_subobject      type balsubobj,
      mv_hb_app_log_object         type balobj_d,
      mv_hb_app_log_subobject      type balsubobj,
      mv_rfc_dest_path_prefix      type string,
      mo_log                       type ref to zcl_logger_to_app_log,
      mv_hb_rfc_dest_path_prefix   type string,
      mv_hb_active                 type char1,
      mv_hb_method                 type string,
      mo_http_client               type ref to if_http_client,
      mo_rest_client               type ref to cl_rest_http_client,
      mo_request                   type ref to if_rest_entity,
      mo_rest_client_response      type ref to if_rest_entity,
      mo_ext_rest_sys_conf         type ref to zif_ext_rest_sys_conf.

    methods:

      set_runtime_parameters
        raising
          zcx_ext_rest_sys_exc,

      set_hb_runtime_parameters
        raising
          zcx_ext_rest_sys_exc,

      get_rest_client_response_code
        returning
          value(rp_http_status_code) type string,

      execute_post
        raising
          zcx_ext_rest_sys_exc,

      execute_get
        raising
          zcx_ext_rest_sys_exc,

      set_http_client
        raising
          zcx_ext_rest_sys_exc,

      set_request,

      set_request_headers,

      set_request_uri,

      set_rest_client,

      set_rest_client_response .
ENDCLASS.



CLASS ZCL_EXT_REST_SYS_INT IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_EXT_REST_SYS_INT->CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* | [--->] IP_EXT_REST_SYSTEM_NAME        TYPE        AC_REACTION_ID
* | [--->] IP_EXT_REST_SYSTEM_MODE        TYPE        CHAR10(optional)
* | [!CX!] ZCX_EXT_REST_SYS_EXC
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method constructor.

    " System name

    mv_ext_rest_system_name = ip_ext_rest_system_name.

    " Setting configuration

    mo_ext_rest_sys_conf = new zcl_ext_rest_sys_conf( ip_ext_rest_system_name ).

    " Runtime parameters

    set_runtime_parameters( ).

    " Preparing log

    mo_log = zcl_logger_to_app_log=>get_instance( ).

    case ip_ext_rest_system_mode.

      when 'HB'.

        " HB - heartbeat mode

        mo_log->set_object_and_subobject(
          exporting
            ip_object    =     mv_hb_app_log_object
            ip_subobject =     mv_hb_app_log_subobject ).


      when 'AI'.

        " AI - alert integration mode

        mo_log->set_object_and_subobject(
          exporting
            ip_object    =     mv_ai_app_log_object
            ip_subobject =     mv_ai_app_log_subobject ).


      when others.

        mo_log->set_object_and_subobject(
          exporting
           ip_object    =     mv_ai_app_log_object
           ip_subobject =     mv_ai_app_log_subobject ).

    endcase.


  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_EXT_REST_SYS_INT->EXECUTE_GET
* +-------------------------------------------------------------------------------------------------+
* | [!CX!] ZCX_EXT_REST_SYS_EXC
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method execute_get.

    data:
      lv_log_record_text       type string,
      lv_http_client_exception type string.

    " Executing HTTP POST

    try.

        mo_rest_client->if_rest_client~get( ).

      catch cx_rest_client_exception into data(lo_rest_client_error) .

        lv_http_client_exception = lo_rest_client_error->get_text( ).

        raise exception type zcx_ext_rest_sys_exc
          exporting
            textid          = zcx_ext_rest_sys_exc=>cannot_execute_post_method
            ip_text_token_1 = lv_http_client_exception.

    endtry.

    lv_log_record_text = |GET request executed|.

    mo_log->info( lv_log_record_text ).

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_EXT_REST_SYS_INT->EXECUTE_POST
* +-------------------------------------------------------------------------------------------------+
* | [!CX!] ZCX_EXT_REST_SYS_EXC
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method execute_post.

    data:
      lv_log_record_text       type string,
      lv_http_client_exception type string.

    " Executing HTTP POST

    try.

        mo_rest_client->if_rest_client~post( mo_request ).

      catch cx_rest_client_exception into data(lo_rest_client_error) .

        lv_http_client_exception = lo_rest_client_error->get_text( ).

        raise exception type zcx_ext_rest_sys_exc
          exporting
            textid          = zcx_ext_rest_sys_exc=>cannot_execute_post_method
            ip_text_token_1 = lv_http_client_exception.

    endtry.

    lv_log_record_text = |POST request executed|.

    mo_log->info( lv_log_record_text ).

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_EXT_REST_SYS_INT->GET_REST_CLIENT_RESPONSE_CODE
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RP_HTTP_STATUS_CODE            TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method get_rest_client_response_code.

    rp_http_status_code  = mo_rest_client_response->get_header_field( '~response_line' ).

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method ZCL_EXT_REST_SYS_INT->PREPARE_REQUEST_HEADERS
* +-------------------------------------------------------------------------------------------------+
* | [!CX!] CX_ABAP_MESSAGE_DIGEST
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method prepare_request_headers.


  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_EXT_REST_SYS_INT->SET_HB_RUNTIME_PARAMETERS
* +-------------------------------------------------------------------------------------------------+
* | [!CX!] ZCX_EXT_REST_SYS_EXC
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method set_hb_runtime_parameters.

    mv_hb_rest_api_rfc_dest_name = mo_ext_rest_sys_conf->get_parameter_value( 'HEARTBEAT.REST_API_RFC_DEST_NAME' ).
    mv_hb_rfc_dest_path_prefix = mo_ext_rest_sys_conf->get_parameter_value( 'HEARTBEAT.RFC_DEST_PATH_PREFIX' ).
    mv_hb_method = mo_ext_rest_sys_conf->get_parameter_value( 'HEARTBEAT.METHOD' ).
    mv_hb_app_log_object = mo_ext_rest_sys_conf->get_parameter_value( 'HEARTBEAT.APP_LOG_OBJECT' ).
    mv_hb_app_log_subobject = mo_ext_rest_sys_conf->get_parameter_value( 'HEARTBEAT.APP_LOG_SUBOBJECT' ).

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method ZCL_EXT_REST_SYS_INT->SET_HEARTBEAT_PAYLOAD
* +-------------------------------------------------------------------------------------------------+
* | [!CX!] ZCX_EXT_REST_SYS_EXC
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method set_heartbeat_payload.


  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_EXT_REST_SYS_INT->SET_HTTP_CLIENT
* +-------------------------------------------------------------------------------------------------+
* | [!CX!] ZCX_EXT_REST_SYS_EXC
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method set_http_client.

    data:
          lv_http_client_exception type string.

    if mv_rest_api_rfc_dest_name is initial.

      raise exception type zcx_ext_rest_sys_exc
        exporting
          textid = zcx_ext_rest_sys_exc=>rfc_destination_not_set.

    endif. " if mv_rest_api_rfc_dest_name is initial

    cl_http_client=>create_by_destination(
       exporting
         destination              = mv_rest_api_rfc_dest_name
       importing
         client                   = mo_http_client
       exceptions
         argument_not_found       = 1
         destination_not_found    = 2
         destination_no_authority = 3
         plugin_not_active        = 4
         internal_error           = 5
         others                   = 6
      ).

    if ( sy-subrc <> 0 ).

      case sy-subrc.
        when '1'.
          lv_http_client_exception = 'argument_not_found'.
        when '2'.
          lv_http_client_exception = 'destination_not_found'.
        when '3'.
          lv_http_client_exception = 'destination_no_authority'.
        when '4'.
          lv_http_client_exception = 'plugin_not_active'.
        when '5'.
          lv_http_client_exception = 'internal_error'.
        when others.
          lv_http_client_exception ='not_known_exception'.

      endcase.

      raise exception type zcx_ext_rest_sys_exc
        exporting
          textid          = zcx_ext_rest_sys_exc=>cannot_set_http_client
          ip_text_token_1 = lv_http_client_exception.

    endif. " IF ( sy_subrc <> 0 )


  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_EXT_REST_SYS_INT->SET_REQUEST
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method set_request.

    mo_request = mo_rest_client->if_rest_client~create_request_entity( ).

    mo_request->set_content_type( iv_media_type = if_rest_media_type=>gc_appl_json ).

    mo_request->set_string_data( mv_rest_api_payload_json ).

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_EXT_REST_SYS_INT->SET_REQUEST_HEADERS
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method set_request_headers.

    data lv_log_record_text type string.

    try.

        prepare_request_headers( ).

        loop at mt_request_headers assigning field-symbol(<ls_request_header>).

          call method mo_rest_client->if_rest_client~set_request_header
            exporting
              iv_name  = <ls_request_header>-name
              iv_value = <ls_request_header>-value.

          lv_log_record_text = |HTTP header record | && |{ sy-tabix }| && |: | && |{ <ls_request_header>-name }| && | = |
           && |{ <ls_request_header>-value }|.

          mo_log->info( lv_log_record_text ).

        endloop. " loop at mt_request_headers assigning field-symbol(<ls_request_header>)

      catch cx_abap_message_digest into data(lo_ext_rest_system_error) .

    endtry.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_EXT_REST_SYS_INT->SET_REQUEST_URI
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method set_request_uri.

    cl_http_utility=>set_request_uri(
        exporting
          request = mo_http_client->request    " HTTP Framework (iHTTP) HTTP Request
          uri     = mv_rfc_dest_path_prefix                     " URI String (in the Form of /path?query-string)
      ).

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_EXT_REST_SYS_INT->SET_REST_CLIENT
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method set_rest_client.

    " Create REST client instance

    mo_rest_client = new #( io_http_client = mo_http_client ).

    " Set HTTP version

    mo_http_client->request->set_version( if_http_request=>co_protocol_version_1_0 ).

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_EXT_REST_SYS_INT->SET_REST_CLIENT_RESPONSE
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method set_rest_client_response.

    mo_rest_client_response = mo_rest_client->if_rest_client~get_response_entity( ).

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_EXT_REST_SYS_INT->SET_RUNTIME_PARAMETERS
* +-------------------------------------------------------------------------------------------------+
* | [!CX!] ZCX_EXT_REST_SYS_EXC
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method set_runtime_parameters.

    mv_rest_api_rfc_dest_name = mo_ext_rest_sys_conf->get_parameter_value( 'REST_API_RFC_DEST_NAME' ).
    mv_ai_app_log_object = mo_ext_rest_sys_conf->get_parameter_value( 'APP_LOG_OBJECT' ).
    mv_ai_app_log_subobject = mo_ext_rest_sys_conf->get_parameter_value( 'APP_LOG_SUBOBJECT' ).
    mv_rfc_dest_path_prefix = mo_ext_rest_sys_conf->get_parameter_value( 'RFC_DEST_PATH_PREFIX' ).

    mv_hb_active = mo_ext_rest_sys_conf->get_parameter_value( 'HEARTBEAT.ACTIVE' ).

    if ( mv_hb_active eq abap_true ).

      set_hb_runtime_parameters( ).

    endif.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_EXT_REST_SYS_INT->ZIF_EXT_REST_SYS_INT~GET_RESPONSE_STRING
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RP_RESPONSE_STRING             TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method zif_ext_rest_sys_int~get_response_string.

    data: lv_http_status   type string,
          lv_response_text type string.

    lv_http_status = get_rest_client_response_code( ).

    lv_response_text = mo_rest_client_response->get_string_data( ).

    rp_response_string = |{ lv_http_status }| && | / | && |{ lv_response_text }|.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_EXT_REST_SYS_INT->ZIF_EXT_REST_SYS_INT~SEND_HB_PAYLOAD
* +-------------------------------------------------------------------------------------------------+
* | [!CX!] ZCX_EXT_REST_SYS_EXC
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method zif_ext_rest_sys_int~send_hb_payload.

    data:
      lv_log_record_text type string,
      lv_http_status     type string.

    if mv_hb_payload is initial.

      me->set_heartbeat_payload( ).

    endif.

    lv_log_record_text = |System| && | | && |{ mv_ext_rest_system_name }| && |: sending heartbeat payload via REST API| && | | && |{ mv_hb_method }| && | | && |request|.

    mo_log->info( lv_log_record_text ).

    lv_log_record_text = |Payload for heartbeat: | && | | && |{ mv_hb_payload }|.

    mo_log->info( lv_log_record_text ).

    lv_log_record_text = |RFC destination for heartbeat:| && | | && |{ mv_hb_rest_api_rfc_dest_name }|.

    mo_log->info( lv_log_record_text ).

    lv_log_record_text = |Path prefix for heartbeat: | && | | && |{ mv_hb_rfc_dest_path_prefix }|.

    mo_log->info( lv_log_record_text ).

    set_http_client( ).

    set_rest_client( ).

    if mo_http_client is bound and mo_rest_client is bound.

      mv_rest_api_payload_json = mv_hb_payload.

      set_request_uri( ).

      set_request( ).

      set_request_headers( ).

      case mv_hb_method.

        when 'POST'.

          execute_post( ).

        when 'GET'.

          execute_get( ).

        when others.

      endcase.


      set_rest_client_response( ).

      lv_http_status = get_rest_client_response_code( ).

      lv_log_record_text = |{ mv_hb_method }| && | | && |request response :| && | | && |{ lv_http_status }|.

      mo_log->info( lv_log_record_text ).

    endif. " IF lo_http_client IS BOUND AND lo_rest_client IS BOUND


  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_EXT_REST_SYS_INT->ZIF_EXT_REST_SYS_INT~SEND_PAYLOAD_JSON_AS_POST_REQ
* +-------------------------------------------------------------------------------------------------+
* | [!CX!] ZCX_EXT_REST_SYS_EXC
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method zif_ext_rest_sys_int~send_payload_json_as_post_req.

    data:
      lv_log_record_text type string,
      lv_http_status     type string.

    lv_log_record_text = |System| && | | && |{ mv_ext_rest_system_name }| && |: sending payload via REST API POST request|.

    mo_log->info( lv_log_record_text ).

    lv_log_record_text = |Payload: | && | | && |{ mv_rest_api_payload_json }|.

    mo_log->info( lv_log_record_text ).

    lv_log_record_text = |RFC destination:| && | | && |{ mv_rest_api_rfc_dest_name }|.

    mo_log->info( lv_log_record_text ).

    lv_log_record_text = |Path prefix: | && | | && |{ mv_rfc_dest_path_prefix }|.

    mo_log->info( lv_log_record_text ).

    set_http_client( ).

    set_rest_client( ).

    if mo_http_client is bound and mo_rest_client is bound.

      set_request_uri( ).

      set_request( ).

      set_request_headers( ).

     " execute_post( ).

      set_rest_client_response( ).

      lv_http_status = get_rest_client_response_code( ).

      lv_log_record_text = |POST request response :| && | | && |{ lv_http_status }|.

      mo_log->info( lv_log_record_text ).

    endif. " IF lo_http_client IS BOUND AND lo_rest_client IS BOUND



  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_EXT_REST_SYS_INT->ZIF_EXT_REST_SYS_INT~SET_PAYLOAD_JSON
* +-------------------------------------------------------------------------------------------------+
* | [--->] IP_REST_API_PAYLOAD_JSON       TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method zif_ext_rest_sys_int~set_payload_json.

    mv_rest_api_payload_json = ip_rest_api_payload_json.

  endmethod.
ENDCLASS.