class zcl_alert_base definition
  public
  create public .

  public section.

    interfaces zif_alert_base.

    methods constructor
      importing
        !it_alert type e2ea_t_alert_consm_object .

  protected section.

    types:
      begin of ty_sub_object,
        name             type string,
        event_id         type string,
        obj_type         type string,
        alert_id         type string,
        parent_id        type string,
        rating           type string,
        text             type string,
        visited          type string,
        value            type string,
        timestamp        type string,
        metricpath       type string,
        reasonforclosure type string,
      end of ty_sub_object .

    types:
      tt_sub_objects type standard table of ty_sub_object .

    types:
      begin of ty_alert_serialized_to_json,
        name                type string,
        managed_object_name type string,
        managed_object_type type string,
        managed_object_id   type string,
        category            type string,
        severity            type string,
        utc_timestamp       type string,
        rating              type string,
        status              type string,
        guid                type string,
        technical_name      type string,
        description         type string,
        custom_description  type string,
        technical_scenario  type string,
        epoch_utc_timestamp type string,
      end of ty_alert_serialized_to_json .

    data:
      mt_events               type tt_sub_objects,
      mv_enhanced_description type string,
      mv_category_text        type string,
      mv_status_text          type string.

  private section.

    data:

      mv_managed_object_name type string,
      mv_managed_object_type type string,
      mv_managed_object_id   type string,
      mv_category            type ac_category,
      mv_severity            type ac_severity,
      mv_timestamp           type string,
      mv_rating              type string,
      mv_status              type string,
      mv_guid                type string,
      mv_technical_name      type ac_name,
      mv_description         type string,
      mv_custom_description  type string,
      mv_name                type string,
      mv_technical_scenario  type ac_technical_scenario.

    methods:

      set_category_text ,

      set_status_text ,

      set_sub_objects
        importing
          !ipo_object    type ref to if_alert_consm_object
          !ipv_alert_id  type string
          !ipv_parent_id type string ,

      convert_timestamp_to_epoch
        importing
          ip_timestamp              type timestamp
        returning
          value(rp_epoch_timestamp) type string.

ENDCLASS.



CLASS ZCL_ALERT_BASE IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ALERT_BASE->CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_ALERT                       TYPE        E2EA_T_ALERT_CONSM_OBJECT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method constructor.

    data: lv_object_type type char10,
          lv_field_value type string,
          lt_sub_objects type e2ea_t_alert_consm_object,
          lo_sub_object  type ref to if_alert_consm_object.

    loop at it_alert assigning field-symbol(<lfs_alert>).

      lv_object_type = <lfs_alert>->get_object_type( ).

      " Focusing on Alert (A) type

      if lv_object_type = 'A'.

        mv_name = <lfs_alert>->get_name( ).

        mv_technical_name = <lfs_alert>->get_technical_name( ).

        mv_managed_object_name = <lfs_alert>->get_managed_object_name( ).

        mv_managed_object_type = <lfs_alert>->get_managed_object_type( ).

        mv_category = <lfs_alert>->get_category( ).

        set_category_text( ).

        mv_severity = <lfs_alert>->get_severity( ).

        mv_guid = <lfs_alert>->get_id( ).

        mv_status = <lfs_alert>->get_status( ).

        set_status_text( ).

        mv_timestamp = <lfs_alert>->get_timestamp( ).

        mv_description = <lfs_alert>->get_description( ).

        mv_custom_description = <lfs_alert>->get_custom_description( ).

        mv_managed_object_id = <lfs_alert>->get_managed_object_id( ).

        mv_technical_scenario = <lfs_alert>->get_technical_scenario( ).

        lv_field_value = <lfs_alert>->get_rating( ).

        mv_rating = cl_alert_consm_utility=>get_domain_value_text(
          i_domain_name = cl_alert_consm_constants=>ac_domname_rating
          i_value = lv_field_value ).

        " Setting all subobjects

        if ( <lfs_alert>->has_sub_objects( ) = abap_true ).

          lt_sub_objects = <lfs_alert>->get_sub_objects( ).

          loop at lt_sub_objects into lo_sub_object.

            set_sub_objects( ipo_object = lo_sub_object

            ipv_parent_id = <lfs_alert>->get_id( )

            ipv_alert_id = <lfs_alert>->get_id( ) ).

          endloop. " LOOP AT lt_sub_objects INTO lo_sub_object

        endif. " if <lfs_alert>->has_sub_objects( ) = abap_true

      endif. " IF lv_object_type = 'A'

    endloop. " loop at it_alert assigning FIELD-SYMBOL(<lfs_alert>)

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_ALERT_BASE->CONVERT_TIMESTAMP_TO_EPOCH
* +-------------------------------------------------------------------------------------------------+
* | [--->] IP_TIMESTAMP                   TYPE        TIMESTAMP
* | [<-()] RP_EPOCH_TIMESTAMP             TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method convert_timestamp_to_epoch.

    data:
      lv_date type datum,
      lv_time type uzeit.

    convert time stamp ip_timestamp time zone 'UTC'
        into date lv_date time lv_time.

    cl_pco_utility=>convert_abap_timestamp_to_java(
       exporting

    iv_date      = lv_date
          iv_time      = lv_time

              importing
              ev_timestamp = rp_epoch_timestamp

      ).

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_ALERT_BASE->SET_CATEGORY_TEXT
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method set_category_text.

    data lv_category type string.

    lv_category = mv_category.

    mv_category_text = cl_alert_consm_utility=>get_domain_value_text(
    i_domain_name = cl_alert_consm_constants=>ac_domname_category
    i_value =  lv_category ).

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_ALERT_BASE->SET_STATUS_TEXT
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method set_status_text.

    mv_status_text = cl_alert_consm_utility=>get_domain_value_text(
    i_domain_name = cl_alert_consm_constants=>ac_domname_status
    i_value =  mv_status ).

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_ALERT_BASE->SET_SUB_OBJECTS
* +-------------------------------------------------------------------------------------------------+
* | [--->] IPO_OBJECT                     TYPE REF TO IF_ALERT_CONSM_OBJECT
* | [--->] IPV_ALERT_ID                   TYPE        STRING
* | [--->] IPV_PARENT_ID                  TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method set_sub_objects.

    data:
      ls_extracted_sub_object type class_app_metric=>st_my_sub_object_data,
      ls_sub_object_temp      type  class_app_metric=>st_my_sub_object_data,
      lt_sub_objects          type e2ea_t_alert_consm_object,
      lo_sub_object           type ref to if_alert_consm_object.

    "Code for cycle detection in event hierarchy

    read table mt_events into ls_sub_object_temp with key event_id = ipo_object->get_id( ).

    if sy-subrc = 0.
      if ls_sub_object_temp-visited = 'TRUE'.
        " we have a cycle in the event hierarchy
        " handle it according to your convenience.
        "This is an error or exception case.
      endif.
    endif. " if sy-subrc = 0

    ls_extracted_sub_object-alert_id = ipv_alert_id.
    ls_extracted_sub_object-event_id = ipo_object->get_id( ).
    ls_extracted_sub_object-obj_type = ipo_object->get_object_type( ).
    ls_extracted_sub_object-parent_id = ipv_parent_id.
    ls_extracted_sub_object-visited = 'TRUE'.
    ls_extracted_sub_object-value = ipo_object->get_value( ).
    ls_extracted_sub_object-timestamp = ipo_object->get_timestamp( ).
    ls_extracted_sub_object-metricpath = ipo_object->get_metric_path( ).
    ls_extracted_sub_object-reasonforclosure = ipo_object->get_reason_for_closure( ).
    ls_extracted_sub_object-name = ipo_object->get_name( ).

    ls_extracted_sub_object-rating = cl_alert_consm_utility=>get_domain_value_text(
      i_domain_name = cl_alert_consm_constants=>ac_domname_rating
      i_value = ipo_object->get_rating( )
      ).

    ls_extracted_sub_object-text = ipo_object->get_text_value( ).

    append ls_extracted_sub_object to mt_events.

    if ipo_object->get_object_type( ) = cl_alert_consm_constants=>ac_metric_consm_object.
      return.
    elseif ipo_object->get_object_type( ) = cl_alert_consm_constants=>ac_event_consm_object
      or ipo_object->get_object_type( ) = cl_alert_consm_constants=>ac_metricgrp_consm_object.

      if ipo_object->has_sub_objects( ) = abap_true.

        lt_sub_objects = ipo_object->get_sub_objects( ).

        loop at lt_sub_objects into lo_sub_object.
          set_sub_objects( ipo_object = lo_sub_object
                               ipv_parent_id = ls_extracted_sub_object-event_id
                               ipv_alert_id = ipv_alert_id ).
        endloop. " loop at lt_sub_objects into lo_sub_object

      endif. " if ipo_object->has_sub_objects( ) = abap_true

    endif. " if ipo_object->get_object_type( ) = cl_alert_consm_constants=>ac_metric_consm_object


  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ALERT_BASE->ZIF_ALERT_BASE~GET_ALERT_SERIALIZED_IN_JSON
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
      lr_structure_ref            type ref to data.

    field-symbols: <fs_structure> type any,
                   <fs_value>     type any,
                   <fs_field>     type any.


    " Creating dynamic structure based on alert data type

    create data lr_structure_ref like ls_alert_serialized_in_json.
    assign lr_structure_ref->* to <fs_structure>.

    " Preparing structure description

    lo_structure_desc   ?= cl_abap_structdescr=>describe_by_data_ref( lr_structure_ref ).
    lt_structure_components = lo_structure_desc->get_components( ).

    lo_updated_structure = cl_abap_structdescr=>create( lt_structure_components ).

    create data lr_updated_structure    type handle lo_updated_structure.
    assign lr_updated_structure->* to <fs_structure>.

    " Filling JSON standard fields

    loop at lt_structure_components assigning field-symbol(<ls_component>).

      if  <fs_field> is assigned.
        unassign  <fs_field>.
      endif.

      assign component <ls_component>-name of structure <fs_structure> to <fs_field>.

      " Searching for corresponding attribute name

      clear lv_attr_name.

      lv_attr_name = |mv_| && |{ <ls_component>-name }|.

      translate lv_attr_name to upper case.

      assign me->(lv_attr_name) to <fs_value>.

      if <fs_value> is assigned.
        <fs_field> = <fs_value>.
        unassign <fs_value>.
      endif.

    endloop.

    " Filling custom fields

    if  <fs_field> is assigned.
      unassign <fs_field>.
    endif.

    lr_json_serializer = new #( data = <fs_structure> ).

    lr_json_serializer->serialize( ).
    rp_alert_serialized_in_json = lr_json_serializer->get_data( ).


  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ALERT_BASE->ZIF_ALERT_BASE~GET_CATEGORY
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RP_CATEGORY                    TYPE        AC_CATEGORY
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method zif_alert_base~get_category.

    rp_category = mv_category.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ALERT_BASE->ZIF_ALERT_BASE~GET_CUSTOM_DESCRIPTION
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RP_CUSTOM_DESCRIPTION          TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method zif_alert_base~get_custom_description.

    rp_custom_description = mv_custom_description.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ALERT_BASE->ZIF_ALERT_BASE~GET_DESCRIPTION
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RP_DESCRIPTION                 TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method zif_alert_base~get_description.

    rp_description = mv_description.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ALERT_BASE->ZIF_ALERT_BASE~GET_EPOCH_UTC_TIMESTAMP
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RP_EPOCH_UTC_TIMESTAMP         TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method zif_alert_base~get_epoch_utc_timestamp.

    data: lv_timestamp_string type string,
          lv_timestamp_tstamp type timestamp.

    lv_timestamp_string = me->zif_alert_base~get_utc_timestamp( ).

    lv_timestamp_tstamp = lv_timestamp_string.

    rp_epoch_utc_timestamp = me->convert_timestamp_to_epoch( lv_timestamp_tstamp ).

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ALERT_BASE->ZIF_ALERT_BASE~GET_FIRST_NON_GREEN_METRIC
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RS_METRIC                      TYPE        ZALROUTINT_TS_METRIC
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method zif_alert_base~get_first_non_green_metric.

    data:
      lv_green_rating_text type string,
      lv_gray_rating_text  type string,
      lv_timestamp_tstamp  type timestamp.

*    Constants of E2EA_RATING
*
*    0  Grey
*    1  Green
*    2  Yellow
*    3  Red

    lv_green_rating_text = cl_alert_consm_utility=>get_domain_value_text(
       i_domain_name = cl_alert_consm_constants=>ac_domname_rating
       i_value = '1'
       ).

    lv_gray_rating_text = cl_alert_consm_utility=>get_domain_value_text(
       i_domain_name = cl_alert_consm_constants=>ac_domname_rating
       i_value = '0'
       ).

    loop at mt_events assigning field-symbol(<fs_event>)
        where obj_type eq 'M'.

      if ( <fs_event>-rating ne lv_green_rating_text ) and
        ( <fs_event>-rating ne lv_gray_rating_text ).

        rs_metric-name = <fs_event>-name.
        rs_metric-rating = <fs_event>-rating.
        rs_metric-text = <fs_event>-text.
        rs_metric-utc_timestamp = <fs_event>-timestamp.
        rs_metric-value = <fs_event>-value.

        lv_timestamp_tstamp = <fs_event>-timestamp.
        rs_metric-epoch_utc_timestamp = me->convert_timestamp_to_epoch( lv_timestamp_tstamp ).

        exit.

      endif.

    endloop.


  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ALERT_BASE->ZIF_ALERT_BASE~GET_GUID
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RP_GUID                        TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method zif_alert_base~get_guid.

    rp_guid = mv_guid.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ALERT_BASE->ZIF_ALERT_BASE~GET_MANAGED_OBJECT_ID
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RP_MANAGED_OBJECT_ID           TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method zif_alert_base~get_managed_object_id.

    rp_managed_object_id = mv_managed_object_id.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ALERT_BASE->ZIF_ALERT_BASE~GET_MANAGED_OBJECT_NAME
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RP_MANAGED_OBJECT_NAME         TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method zif_alert_base~get_managed_object_name.

    rp_managed_object_name = mv_managed_object_name.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ALERT_BASE->ZIF_ALERT_BASE~GET_MANAGED_OBJECT_TYPE
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RP_MANAGED_OBJECT_TYPE         TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method zif_alert_base~get_managed_object_type.

    rp_managed_object_type = mv_managed_object_type.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ALERT_BASE->ZIF_ALERT_BASE~GET_METRICS_DATA
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RT_METRICS_DATA                TYPE        ZALROUTINT_TT_METRICS
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method zif_alert_base~get_metrics_data.


    data: wa_metric           type zalroutint_ts_metric,
          lv_timestamp_tstamp type timestamp.



    loop at mt_events assigning field-symbol(<fs_event>)
        where obj_type eq 'M'.

      wa_metric-name = <fs_event>-name.
      wa_metric-rating = <fs_event>-rating.
      wa_metric-text = <fs_event>-text.
      wa_metric-utc_timestamp = <fs_event>-timestamp.
      wa_metric-value = <fs_event>-value.

      lv_timestamp_tstamp = <fs_event>-timestamp.
      wa_metric-epoch_utc_timestamp = me->convert_timestamp_to_epoch( lv_timestamp_tstamp ).

      condense: wa_metric-name, wa_metric-rating, wa_metric-text,
        wa_metric-utc_timestamp, wa_metric-value, wa_metric-epoch_utc_timestamp.

      append wa_metric to rt_metrics_data.

    endloop.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ALERT_BASE->ZIF_ALERT_BASE~GET_NAME
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RP_NAME                        TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method zif_alert_base~get_name.

    rp_name = mv_name.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ALERT_BASE->ZIF_ALERT_BASE~GET_RATING
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RP_RATING                      TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method zif_alert_base~get_rating.

    rp_rating = mv_rating.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ALERT_BASE->ZIF_ALERT_BASE~GET_SEVERITY
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RP_SEVERITY                    TYPE        AC_SEVERITY
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method zif_alert_base~get_severity.

    rp_severity = mv_severity.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ALERT_BASE->ZIF_ALERT_BASE~GET_STATUS
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RP_STATUS                      TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method zif_alert_base~get_status.

    rp_status = mv_status.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ALERT_BASE->ZIF_ALERT_BASE~GET_TECHNICAL_NAME
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RP_TECHNICAL_NAME              TYPE        AC_NAME
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method zif_alert_base~get_technical_name.

    rp_technical_name = mv_technical_name.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ALERT_BASE->ZIF_ALERT_BASE~GET_TECHNICAL_SCENARIO
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RP_TECHNICAL_SCENARIO          TYPE        AC_TECHNICAL_SCENARIO
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method zif_alert_base~get_technical_scenario.

    rp_technical_scenario = mv_technical_scenario.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ALERT_BASE->ZIF_ALERT_BASE~GET_UTC_TIMESTAMP
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RP_UTC_TIMESTAMP               TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method zif_alert_base~get_utc_timestamp.

    rp_utc_timestamp = mv_timestamp.

  endmethod.
ENDCLASS.