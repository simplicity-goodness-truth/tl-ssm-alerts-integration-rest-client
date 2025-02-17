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

    methods:
      get_ke_path
        importing
          ip_sid                 type ac_string
          ip_ke                  type zesm_ke
          ip_technical_scenario  type ac_technical_scenario
          ip_managed_object_name type string
          ip_metric_name         type string
        returning
          value(rp_ke_path)      type string.

ENDCLASS.



CLASS ZCL_ALERT_FOR_OUTB_INT IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_ALERT_FOR_OUTB_INT->GET_KE_PATH
* +-------------------------------------------------------------------------------------------------+
* | [--->] IP_SID                         TYPE        AC_STRING
* | [--->] IP_KE                          TYPE        ZESM_KE
* | [--->] IP_TECHNICAL_SCENARIO          TYPE        AC_TECHNICAL_SCENARIO
* | [--->] IP_MANAGED_OBJECT_NAME         TYPE        STRING
* | [--->] IP_METRIC_NAME                 TYPE        STRING
* | [<-()] RP_KE_PATH                     TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method get_ke_path.

    rp_ke_path = |{ ip_ke }| && |/| && |{ ip_sid }| && |/| && |{ ip_technical_scenario }| && |/| && |{ ip_managed_object_name }| && |/| && |{ ip_metric_name }| .

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ALERT_FOR_OUTB_INT->ZIF_ALERT_BASE~GET_ALERT_SERIALIZED_IN_JSON
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RP_ALERT_SERIALIZED_IN_JSON    TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
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
      lv_custom_fields_count      type int4,
      lt_metrics_data             type zalroutint_tt_metrics,
      lr_metrics_data             type ref to data,
      lr_sid                      type ref to data,
      lr_ke_path                  type ref to data,
      lr_ke                       type ref to data,
      lv_ke                       type zesm_ke,
      lv_sid                      type string,
      lo_ci_mgr                   type ref to zif_alert_ci_mgr,
      lv_class_name               type ddobjname,
      lv_context_id               type ac_guid.

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

    " Adding extra custom fields to output JSON structure

    lv_custom_fields_count = lines( mt_json_custom_fields ).

    loop at mt_json_custom_fields assigning <ls_custom_json_fields>.

      ls_component-name = <ls_custom_json_fields>-name.
      ls_component-type = cl_abap_elemdescr=>get_string( ).
      append ls_component to lt_structure_components.

    endloop. " loop at mt_json_custom_fields assigning <ls_custom_json_fields>

    clear ls_component.

    " Adding metrics data structure to output JSON structure

    ls_component-name = 'metrics_data'.
    ls_component-type = cast #( cl_abap_elemdescr=>describe_by_name( 'ZALROUTINT_TT_METRICS' ) ).
    append ls_component to lt_structure_components.

    " Adding SID data structure to output JSON structure

    ls_component-name = 'sid'.
    ls_component-type = cl_abap_elemdescr=>get_string( ).
    append ls_component to lt_structure_components.

    " Adding KE data structure to output JSON structure

    ls_component-name = 'ci'.
    ls_component-type = cast #( cl_abap_elemdescr=>describe_by_name( 'ZESM_KE' ) ).
    append ls_component to lt_structure_components.

    " Adding KE path to output JSON structure

    ls_component-name = 'ci_path'.
    ls_component-type = cl_abap_elemdescr=>get_string( ).
    append ls_component to lt_structure_components.

    " Updating output JSON structure with added components

    lo_updated_structure = cl_abap_structdescr=>create( lt_structure_components ).

    create data lr_updated_structure    type handle lo_updated_structure.
    assign lr_updated_structure->* to <fs_structure>.

    " Filling JSON standard fields

    loop at lt_structure_components assigning field-symbol(<ls_component>).

      " Skipping custom fields and metrics data in the end of the structure to avoid dynamic method call execution dump

      if sy-tabix ge ( lines( lt_structure_components ) - lv_custom_fields_count + 2 ).

        exit.

      endif.

      if  <fs_field> is assigned.
        unassign  <fs_field>.
      endif.

      assign component <ls_component>-name of structure <fs_structure> to <fs_field>.

      lv_method_name = |ZIF_ALERT_BASE~GET_| && |{ <ls_component>-name }|.

      translate lv_method_name to upper case.

      lv_param_name = |RP_| && |{ <ls_component>-name }|.

      clear lv_param_value.

      ptab = value #( ( name = lv_param_name
          value = ref #( lv_param_value )
           kind = cl_abap_objectdescr=>returning
           ) ).

      translate lv_param_name to upper case.

      try.
          call method me->(lv_method_name)
            parameter-table
            ptab.

          condense lv_param_value.

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

    " Filling metrics data structure

    lt_metrics_data = me->zif_alert_base~get_metrics_data(  ).

    assign component 'metrics_data' of structure <fs_structure> to <fs_field>.

    if <fs_value> is assigned.
      unassign <fs_value>.
    endif.

    create data lr_metrics_data type zalroutint_tt_metrics.

    assign lr_metrics_data->* to <fs_value>.

    <fs_value> = lt_metrics_data.

    <fs_field> = <fs_value>.

    " Filling SID data field

    lv_context_id = me->zif_alert_base~get_managed_object_id( ).

    assign component 'sid' of structure <fs_structure> to <fs_field>.

    if <fs_value> is assigned.
      unassign <fs_value>.
    endif.

    create data lr_sid type string.

    assign lr_sid->* to <fs_value>.

    lv_class_name = |ZCL_| && |{ me->zif_alert_base~get_technical_scenario( ) }| && |_CI_MGR|.

    try.
        create object lo_ci_mgr type (lv_class_name)
         exporting
           ip_context_id = lv_context_id.

      catch cx_sy_ref_is_initial cx_sy_dyn_call_error cx_sy_create_object_error into data(lcx_sid_search_class_exception).

        lv_exception_text = lcx_process_exception->get_longtext( ).

    endtry.

    if lo_ci_mgr is bound.

      lv_sid = lo_ci_mgr->get_alert_sid( ).

      <fs_value> = lv_sid.

    endif.


    <fs_field> = <fs_value>.


    " Filling KE data field

    assign component 'ci' of structure <fs_structure> to <fs_field>.

    if <fs_value> is assigned.
      unassign <fs_value>.
    endif.

    create data lr_ke type zesm_ke.

    assign lr_ke->* to <fs_value>.

    try.

        lv_ke = lo_ci_mgr->get_ke_by_alert_sid( ).

        <fs_value> = lv_ke.

      catch cx_sy_ref_is_initial cx_sy_dyn_call_error cx_sy_create_object_error into data(lcx_ke_search_class_exception).

        lv_exception_text = lcx_process_exception->get_longtext( ).

    endtry.

    <fs_field> = <fs_value>.

    " Filling KE path data field

    if lv_ke is not initial.

      assign component 'ci_path' of structure <fs_structure> to <fs_field>.

      if <fs_value> is assigned.
        unassign <fs_value>.
      endif.

      create data lr_ke_path type string.

      assign lr_ke_path->* to <fs_value>.

      <fs_value> = me->get_ke_path(
        ip_ke = lv_ke
         ip_sid = lv_sid
         ip_managed_object_name = me->zif_alert_base~get_managed_object_name( )
         ip_technical_scenario = me->zif_alert_base~get_technical_scenario( )
         ip_metric_name = me->zif_alert_base~get_first_non_green_metric( )-name

      ).

      <fs_field> = <fs_value>.

    endif.

    " Preparing output JSON string from output JSON structure

    create object lr_json_serializer
      exporting
        data = <fs_structure>.

    lr_json_serializer->serialize( ).
    rp_alert_serialized_in_json = lr_json_serializer->get_data( ).


  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ALERT_FOR_OUTB_INT->ZIF_ALERT_FOR_OUTB_INT~SET_CUSTOM_PAYLOAD_FIELDS
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_CUSTOM_JSON_FIELDS          TYPE        ZALROUTINT_TT_CUSTOM_JSON_FLDS
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method zif_alert_for_outb_int~set_custom_payload_fields.

    move-corresponding it_custom_json_fields to mt_json_custom_fields.

  endmethod.
ENDCLASS.