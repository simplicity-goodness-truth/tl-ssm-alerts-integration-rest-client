class ZCL_T_SYS_MON_CI_MGR definition
  public
  inheriting from ZCL_ALERT_CI_MGR
  final
  create public .

public section.

  methods ZIF_ALERT_CI_MGR~GET_ALERT_SID
    redefinition .
  protected section.
  private section.


ENDCLASS.



CLASS ZCL_T_SYS_MON_CI_MGR IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_T_SYS_MON_CI_MGR->ZIF_ALERT_CI_MGR~GET_ALERT_SID
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RP_SID                         TYPE        AC_STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method ZIF_ALERT_CI_MGR~GET_ALERT_SID.

    data lv_context_id type ac_guid.

    lv_context_id = me->zif_alert_ci_mgr~get_context_id( ).

    select single value_low into rp_sid from accollseloptdir
       where context_id = lv_context_id
        and parameter_id = 'LONG_SID'.

  endmethod.
ENDCLASS.