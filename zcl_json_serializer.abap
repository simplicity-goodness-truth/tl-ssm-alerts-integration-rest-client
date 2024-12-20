class zcl_json_serializer definition
  public
  create public .

  public section.

    class-methods class_constructor .

    methods:

      constructor
        importing
          !data type data,

      serialize,

      get_data
        returning
          value(rval) type string .

  protected section.

  private section.

    data:
      fragments type trext_string,
      data_ref  type ref to data.

    class-data:
      c_colon type string,
      c_comma type string.

    methods recurse
      importing
        !data type data .
endclass.

class zcl_json_serializer implementation.


  method class_constructor.
    cl_abap_string_utilities=>c2str_preserving_blanks(
        exporting source = ': '
        importing dest   = c_colon ) .
    cl_abap_string_utilities=>c2str_preserving_blanks(
        exporting source = ', '
        importing dest   = c_comma ) .
  endmethod.

  method constructor.
    get reference of data into me->data_ref .
  endmethod.

  method get_data.
    concatenate lines of me->fragments into rval .
  endmethod.

  method recurse.
    data:
      l_type  type c,
      l_comps type i,
      l_lines type i,
      l_index type i,
      l_value type string.
    field-symbols:
      <itab> type any table,
      <comp> type any.

    describe field data type l_type components l_comps .

    if l_type = cl_abap_typedescr=>typekind_table .

      append '[' to me->fragments .
      assign data to <itab> .
      l_lines = lines( <itab> ) .
      loop at <itab> assigning <comp> .
        add 1 to l_index .
        recurse( <comp> ) .
        if l_index < l_lines .
          append c_comma to me->fragments .
        endif .
      endloop .
      append ']' to fragments .
    else .
      if l_comps is initial .

        l_value = data .
        replace all occurrences of '\' in l_value with '\\' .
        replace all occurrences of '''' in l_value with '\''' .
        replace all occurrences of '"' in l_value with '\"' .
        " replace all occurrences of '&' in l_value with '\&' .
        replace all occurrences of cl_abap_char_utilities=>cr_lf in l_value with '\r\n' .
        replace all occurrences of cl_abap_char_utilities=>newline in l_value with '\n' .
        replace all occurrences of cl_abap_char_utilities=>horizontal_tab in l_value with '\t' .
        replace all occurrences of cl_abap_char_utilities=>backspace in l_value with '\b' .
        replace all occurrences of cl_abap_char_utilities=>form_feed in l_value with '\f' .
        concatenate '"' l_value '"' into l_value .
        append l_value to me->fragments .
      else .

        data l_typedescr type ref to cl_abap_structdescr .
        field-symbols <abapcomp> type abap_compdescr .

        append '{' to me->fragments .
        l_typedescr ?= cl_abap_typedescr=>describe_by_data( data ) .
        loop at l_typedescr->components assigning <abapcomp> .
          l_index = sy-tabix .

          " Custom development: adding double quotes into attribute

          concatenate '"' <abapcomp>-name '"' c_colon into l_value .

          translate l_value to lower case .
          append l_value to me->fragments .
          assign component <abapcomp>-name of structure data to <comp> .
          recurse( <comp> ) .
          if l_index < l_comps .
            append c_comma to me->fragments .
          endif .
        endloop .
        append '}' to me->fragments .
      endif .
    endif .
  endmethod.


  method serialize.
    field-symbols <data> type data .

    assign me->data_ref->* to <data> .
    recurse( <data> ) .
  endmethod.
endclass.