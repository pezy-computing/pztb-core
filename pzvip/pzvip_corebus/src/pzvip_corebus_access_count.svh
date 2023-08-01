`ifndef PZVIP_COREBUS_ACCESS_COUNT_SVH
`define PZVIP_COREBUS_ACCESS_COUNT_SVH
class pzvip_corebus_access_count extends uvm_object;
  longint unsigned  command_count[pzvip_corebus_command_type];
  longint unsigned  ongoing_non_posted_access_count;
  `tue_object_default_constructor(pzvip_corebus_access_count)
  `uvm_object_utils_begin(pzvip_corebus_access_count)
    `uvm_field_aa_int_enumkey(pzvip_corebus_command_type, command_count, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(ongoing_non_posted_access_count, UVM_DEFAULT | UVM_DEC)
  `uvm_object_utils_end
endclass
`endif
