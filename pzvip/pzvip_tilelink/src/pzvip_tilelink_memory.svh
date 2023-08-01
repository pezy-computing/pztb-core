`ifndef PZVIP_TILELINK_MEMORY_SVH
`define PZVIP_TILELINK_MEMORY_SVH
class pzvip_tilelink_memory extends pzvip_common_pkg::pzvip_memory #(
  .CONFIGURATION  (pzvip_tilelink_configuration ),
  .STATUS         (pzvip_tilelink_status        ),
  .ADDRESS        (pzvip_tilelink_address       ),
  .DATA           (pzvip_tilelink_data          ),
  .BYTE_ENABLE    (pzvip_tilelink_mask          )
);
  protected virtual function int get_byte_size();
    return configuration.byte_width;
  endfunction
  protected function int get_default_word_width();
    return configuration.data_width / 8;
  endfunction
  `tue_object_default_constructor(pzvip_tilelink_memory)
  `uvm_object_utils(pzvip_tilelink_memory)
endclass
`endif
