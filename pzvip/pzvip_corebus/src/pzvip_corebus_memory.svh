`ifndef PZVIP_COREBUS_MEMORY_SVH
`define PZVIP_COREBUS_MEMORY_SVH
typedef pzvip_common_pkg::pzvip_memory #(
  .CONFIGURATION  (pzvip_corebus_configuration  ),
  .STATUS         (pzvip_corebus_status         ),
  .ADDRESS        (pzvip_corebus_address        ),
  .DATA           (pzvip_corebus_data           ),
  .BYTE_ENABLE    (pzvip_corebus_byte_enable    )
) pzvip_corebus_memory_base;

class pzvip_corebus_memory extends pzvip_corebus_memory_base;
  protected function int get_default_word_width();
    return configuration.data_width / 8;
  endfunction
  `tue_object_default_constructor(pzvip_corebus_memory)
  `uvm_object_utils(pzvip_corebus_memory)
endclass
`endif
