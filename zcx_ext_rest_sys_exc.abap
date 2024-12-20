class zcx_ext_rest_sys_exc definition
  public
  inheriting from cx_static_check
  final
  create public .

  public section.

    interfaces if_t100_message .

    constants:
      begin of ext_sys_param_not_found,
        msgid type symsgid value 'ZEXTRSTSYS',
        msgno type symsgno value '001',
        attr1 type scx_attrname value 'IM_TEXT_TOKEN_1',
        attr2 type scx_attrname value 'IM_TEXT_TOKEN_2',
        attr3 type scx_attrname value '',
        attr4 type scx_attrname value '',
      end of ext_sys_param_not_found .
    constants:
      begin of cannot_execute_post_method,
        msgid type symsgid value 'ZEXTRSTSYS',
        msgno type symsgno value '002',
        attr1 type scx_attrname value 'IM_TEXT_TOKEN_1',
        attr2 type scx_attrname value '',
        attr3 type scx_attrname value '',
        attr4 type scx_attrname value '',
      end of cannot_execute_post_method .
    constants:
      begin of cannot_set_http_client,
        msgid type symsgid value 'ZEXTRSTSYS',
        msgno type symsgno value '003',
        attr1 type scx_attrname value 'IM_TEXT_TOKEN_1',
        attr2 type scx_attrname value '',
        attr3 type scx_attrname value '',
        attr4 type scx_attrname value '',
      end of cannot_set_http_client .
    constants:
      begin of rfc_destination_not_set,
        msgid type symsgid value 'ZEXTRSTSYS',
        msgno type symsgno value '004',
        attr1 type scx_attrname value '',
        attr2 type scx_attrname value '',
        attr3 type scx_attrname value '',
        attr4 type scx_attrname value '',
      end of rfc_destination_not_set .
    constants:
      begin of class_name_too_long,
        msgid type symsgid value 'ZEXTRSTSYS',
        msgno type symsgno value '005',
        attr1 type scx_attrname value 'IM_TEXT_TOKEN_1',
        attr2 type scx_attrname value 'IM_TEXT_TOKEN_2',
        attr3 type scx_attrname value '',
        attr4 type scx_attrname value '',
      end of class_name_too_long .
    constants:
      begin of heartbeat_failure,
        msgid type symsgid value 'ZEXTRSTSYS',
        msgno type symsgno value '006',
        attr1 type scx_attrname value 'IM_TEXT_TOKEN_1',
        attr2 type scx_attrname value '',
        attr3 type scx_attrname value '',
        attr4 type scx_attrname value '',
      end of heartbeat_failure .
    data im_text_token_1 type string .
    data im_text_token_2 type string .

    methods constructor
      importing
        !textid          like if_t100_message=>t100key optional
        !previous        like previous optional
        !ip_text_token_1 type string optional
        !ip_text_token_2 type string optional .
  protected section.
  private section.
endclass.



class zcx_ext_rest_sys_exc implementation.


  method constructor ##ADT_SUPPRESS_GENERATION.
    call method super->constructor
      exporting
        previous = previous.
    me->im_text_token_1 = ip_text_token_1 .
    me->im_text_token_2 = ip_text_token_2 .
    clear me->textid.
    if textid is initial.
      if_t100_message~t100key = if_t100_message=>default_textid.
    else.
      if_t100_message~t100key = textid.
    endif.
  endmethod.
endclass.