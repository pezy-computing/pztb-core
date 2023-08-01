`ifndef PZVIP_COREBUS_STATUS_SVH
`define PZVIP_COREBUS_STATUS_SVH
typedef class pzvip_corebus_memory;
typedef class pzvip_corebus_access_count;

class pzvip_corebus_status extends tue_status;
  pzvip_corebus_memory        memory;
  pzvip_corebus_access_count  access_count;
  `tue_object_default_constructor(pzvip_corebus_status)
  `uvm_object_utils(pzvip_corebus_status)
endclass
`endif
