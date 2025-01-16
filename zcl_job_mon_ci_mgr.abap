class zcl_job_mon_ci_mgr definition
  public
  inheriting from zcl_alert_ci_mgr
  final
  create public .

  public section.

    methods:
      zif_alert_ci_mgr~get_alert_sid redefinition.

  protected section.
  private section.


ENDCLASS.



CLASS ZCL_JOB_MON_CI_MGR IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_JOB_MON_CI_MGR->ZIF_ALERT_CI_MGR~GET_ALERT_SID
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RP_SID                         TYPE        AC_STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method zif_alert_ci_mgr~get_alert_sid.

    data lv_context_id type ac_guid.

    lv_context_id = me->zif_alert_ci_mgr~get_context_id( ).

    select single value_low into rp_sid from mai_monobjparam
       where context_id = lv_context_id
        and parameter_id = 'SID'.

  endmethod.
ENDCLASS.