class zcl_ext_rest_sys_int_ums definition
  public
  inheriting from zcl_ext_rest_sys_int
  create public .

  public section.

    methods constructor
      importing
        ip_ext_rest_system_name type ac_reaction_id
        ip_ext_rest_system_mode type char10 optional
      raising
        zcx_ext_rest_sys_exc .
  protected section.

    methods:
      prepare_request_headers
        redefinition ,

      set_heartbeat_payload
        redefinition.

  private section.

endclass.



class zcl_ext_rest_sys_int_ums implementation.


  method constructor.

    super->constructor(
        ip_ext_rest_system_name = ip_ext_rest_system_name
        ip_ext_rest_system_mode = ip_ext_rest_system_mode
    ).

  endmethod.


  method prepare_request_headers.

    mt_request_headers = value bbpt_http_param(

    ( name = 'Content-Type' value = 'application/json' )

    ).

  endmethod.

  method set_heartbeat_payload.


    types: begin of ty_json,
             stream type string,
           end of ty_json.

    data:
      lr_json_serializer type ref to zcl_json_serializer,
      lr_structure_ref   type ref to data,
      ls_json_structure  type ty_json.

    field-symbols: <fs_structure> type any,
                   <fs_field>     type any.

    create data lr_structure_ref like ls_json_structure.
    assign lr_structure_ref->* to <fs_structure>.

    assign component 'stream' of structure <fs_structure> to <fs_field>.

    <fs_field> = 'stdout'.

    create object lr_json_serializer
      exporting
        data = <fs_structure>.

    lr_json_serializer->serialize( ).
    mv_hb_payload = lr_json_serializer->get_data( ).

  endmethod.

endclass.