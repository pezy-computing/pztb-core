`ifndef PZVIP_COREBUS_MEMORY_SVH
`define PZVIP_COREBUS_MEMORY_SVH
class pzvip_corebus_memory extends pzvip_common_pkg::pzvip_memory #(
  .CONFIGURATION  (pzvip_corebus_configuration  ),
  .STATUS         (pzvip_corebus_status         )
);
  virtual function void set_configuration(tue_configuration configuration);
    super.set_configuration(configuration);
    default_word_width  = this.configuration.data_width / 8;
  endfunction

  `tue_object_default_constructor(pzvip_corebus_memory)
  `uvm_object_utils(pzvip_corebus_memory)
endclass
`endif
