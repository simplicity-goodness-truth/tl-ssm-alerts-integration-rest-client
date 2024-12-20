*&---------------------------------------------------------------------*
*& Report  zext_rest_sys_hb_exec
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
report zext_rest_sys_hb_exec.

data lo_ext_rest_sys_hb_exec type ref to zcl_ext_rest_sys_hb_exec.

lo_ext_rest_sys_hb_exec = new zcl_ext_rest_sys_hb_exec( ).

lo_ext_rest_sys_hb_exec->zif_ext_rest_sys_hb_exec~execute(  ).