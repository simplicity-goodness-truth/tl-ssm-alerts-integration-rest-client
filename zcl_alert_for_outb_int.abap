class zcl_alert_for_outb_int definition
  public
  inheriting from zcl_alert_base
  create public .

  public section.

    interfaces zif_alert_for_outb_int .

    methods zif_alert_base~get_alert_serialized_in_json
        redefinition .
  protected section.
  private section.

    data mt_json_custom_fields type zalroutint_tt_custom_json_flds .

endclass.



class zcl_alert_for_outb_int implementation.


  method zif_alert_base~get_alert_serialized_in_json.

    data:
      ls_alert_serialized_in_json type ty_alert_serialized_to_json,
      lr_json_serializer          type ref to zcl_json_serializer,
      lt_structure_components     type cl_abap_structdescr=>component_table,
      ls_component_tab            type cl_abap_structdescr=>component_table,
      ls_component                type cl_abap_structdescr=>component,
      lo_structure_desc           type ref to cl_abap_structdescr,
      lo_updated_structure        type ref to cl_abap_structdescr,
      lr_updated_structure        type ref to data,
      lv_attr_name                type seocpdname,
      lr_structure_ref            type ref to data,
      lv_method_name              type string,
      lv_param_name               type abap_parmname,
      lv_param_value              type string,
      ptab                        type abap_parmbind_tab,
      lv_custom_fields_count      type int4.

    field-symbols: <fs_structure>          type any,
                   <fs_value>              type any,
                   <fs_field>              type any,
                   <ls_custom_json_fields> type zalroutint_ts_custom_json_fld.

    " Creating dynamic structure based on alert data type

    create data lr_structure_ref like ls_alert_serialized_in_json.
    assign lr_structure_ref->* to <fs_structure>.

    " Preparing structure description

    lo_structure_desc   ?= cl_abap_structdescr=>describe_by_data_ref( lr_structure_ref ).
    lt_structure_components = lo_structure_desc->get_components( ).

    " Adding extra custom fields to structure

    lv_custom_fields_count = lines( mt_json_custom_fields ).

    loop at mt_json_custom_fields assigning <ls_custom_json_fields>.

      ls_component-name = <ls_custom_json_fields>-name.
      ls_component-type = cl_abap_elemdescr=>get_string( ).
      append ls_component to lt_structure_components.

    endloop. " loop at mt_json_custom_fields assigning <ls_custom_json_fields>

    clear ls_component.

    lo_updated_structure = cl_abap_structdescr=>create( lt_structure_components ).

    create data lr_updated_structure    type handle lo_updated_structure.
    assign lr_updated_structure->* to <fs_structure>.

    " Filling JSON standard fields

    loop at lt_structure_components assigning field-symbol(<ls_component>).

      " Skipping custom fields in the end of the structure to avoid dynamic method call execution dump

      if sy-tabix ge ( lines( lt_structure_components ) - lv_custom_fields_count + 1 ).

        exit.

      endif.

      if  <fs_field> is assigned.
        unassign  <fs_field>.
      endif.

      assign component <ls_component>-name of structure <fs_structure> to <fs_field>.

      lv_method_name = |ZIF_ALERT_BASE~GET_| && |{ <ls_component>-name }|.

      translate lv_method_name to upper case.

      lv_param_name = |RP_| && |{ <ls_component>-name }|.

      ptab = value #( ( name = lv_param_name
          value = ref #( lv_param_value )
           kind = cl_abap_objectdescr=>returning
           ) ).

      translate lv_param_name to upper case.

      try.
          call method me->(lv_method_name)
            parameter-table
            ptab.

          assign lv_param_value to <fs_value>.


        catch cx_sy_dyn_call_error into data(lcx_process_exception).

          data(lv_exception_text) = lcx_process_exception->get_longtext( ).

      endtry.

      if <fs_value> is assigned.
        <fs_field> = <fs_value>.
        unassign <fs_value>.
      endif.

    endloop.

    " Filling extra custom fields

    if <ls_custom_json_fields> is assigned.
      unassign <ls_custom_json_fields>.
    endif.

    loop at mt_json_custom_fields assigning <ls_custom_json_fields>.

      if  <fs_field> is assigned.
        unassign <fs_field>.
      endif.

      assign component <ls_custom_json_fields>-name of structure <fs_structure> to <fs_field>.

      <fs_field> = <ls_custom_json_fields>-value.

    endloop. " loop at mt_json_custom_fields assigning <ls_custom_json_fields>

    " Preparing JSON string

    create object lr_json_serializer
      exporting
        data = <fs_structure>.

    lr_json_serializer->serialize( ).
    rp_alert_serialized_in_json = lr_json_serializer->get_data( ).


  endmethod.


  method zif_alert_for_outb_int~set_custom_payload_fields.

    move-corresponding it_custom_json_fields to mt_json_custom_fields.

  endmethod.
endclass.