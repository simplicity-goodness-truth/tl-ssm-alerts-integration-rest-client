class zcl_alert_ci_mgr definition
  public
  create public .

  public section.

    interfaces zif_alert_ci_mgr .

    methods constructor
      importing
        !ip_context_id type ac_guid .

  protected section.

  private section.

    data:
           mv_context_id type ac_guid.


ENDCLASS.



CLASS ZCL_ALERT_CI_MGR IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ALERT_CI_MGR->CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* | [--->] IP_CONTEXT_ID                  TYPE        AC_GUID
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method constructor.

    mv_context_id = ip_context_id.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ALERT_CI_MGR->ZIF_ALERT_CI_MGR~GET_ALERT_SID
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RP_SID                         TYPE        AC_STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method zif_alert_ci_mgr~get_alert_sid.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ALERT_CI_MGR->ZIF_ALERT_CI_MGR~GET_CONTEXT_ID
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RP_CONTEXT_ID                  TYPE        AC_GUID
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method zif_alert_ci_mgr~get_context_id.

    rp_context_id =  mv_context_id.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ALERT_CI_MGR->ZIF_ALERT_CI_MGR~GET_KE_BY_ALERT_SID
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RP_KE                          TYPE        ZESM_KE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method zif_alert_ci_mgr~get_ke_by_alert_sid.

    data lv_alert_sid type ac_string.

    lv_alert_sid = me->zif_alert_ci_mgr~get_alert_sid( ).

    select single ke into rp_ke from zsm_logcomp_map
      where actor = lv_alert_sid.

  endmethod.
ENDCLASS.