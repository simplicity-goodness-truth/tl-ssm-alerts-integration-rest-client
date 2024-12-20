class zcx_alerts_outb_int_exc definition
  public
  inheriting from cx_static_check
  final
  create public .

  public section.

    interfaces if_t100_message .

    constants:
      begin of alr_out_int_param_not_found,
        msgid type symsgid value 'ZALROUTINT',
        msgno type symsgno value '001',
        attr1 type scx_attrname value 'IM_TEXT_TOKEN_1',
        attr2 type scx_attrname value '',
        attr3 type scx_attrname value '',
        attr4 type scx_attrname value '',
      end of alr_out_int_param_not_found .
    data im_text_token_1 type string .
    data im_text_token_2 type string .

    methods constructor
      importing
        !textid          like if_t100_message=>t100key optional
        !previous        like previous optional
        !im_text_token_1 type string optional
        !im_text_token_2 type string optional .
  protected section.
  private section.
endclass.



class zcx_alerts_outb_int_exc implementation.


  method constructor ##ADT_SUPPRESS_GENERATION.
    call method super->constructor
      exporting
        previous = previous.
    me->im_text_token_1 = im_text_token_1 .
    me->im_text_token_2 = im_text_token_2 .
    clear me->textid.
    if textid is initial.
      if_t100_message~t100key = if_t100_message=>default_textid.
    else.
      if_t100_message~t100key = textid.
    endif.
  endmethod.
endclass.