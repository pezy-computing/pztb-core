`ifndef PZVIP_TILELINK_STATUS_SVH
`define PZVIP_TILELINK_STATUS_SVH
typedef class pzvip_tilelink_memory;

class pzvip_tilelink_status extends tue_status;
  pzvip_tilelink_memory memory;
  `tue_object_default_constructor(pzvip_tilelink_status)
  `uvm_object_utils(pzvip_tilelink_status)
endclass
`endif
