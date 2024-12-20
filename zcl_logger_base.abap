class zcl_logger_base definition
  public
  abstract
  create public .

  public section.

    methods:

      warn
        importing
          !ip_message type string,
      err
        importing
          !ip_message type string,
      info
        importing
          !ip_message type string .

  protected section.
  private section.

endclass.


class zcl_logger_base implementation.

  method err.

  endmethod.


  method info.
  endmethod.


  method warn.
  endmethod.

endclass.