`ifndef PZVIP_COMMON_ITEM_SVH
`define PZVIP_COMMON_ITEM_SVH
class pzvip_common_item #(
  type  CONFIGURATION = tue_configuration_dummy,
  type  STATUS        = tue_status_dummy
) extends tue_sequence_item #(CONFIGURATION, STATUS);
  rand  int ipg;

  constraint c_valid_ipg {
    ipg >= -1;
  }

  constraint c_default_ipg {
    soft ipg == -1;
  }

  function int get_ipg();
    return (ipg >= 0) ? ipg : 0;
  endfunction

  `tue_object_default_constructor(pzvip_common_item)
endclass
`endif
