class pzvip_uart_sequencer extends tue_sequencer #(
  .CONFIGURATION  (pzvip_uart_configuration ),
  .STATUS         (pzvip_uart_status        ),
  .REQ            (tue_sequence_item_dummy  )
);
  `tue_component_default_constructor(pzvip_uart_sequencer)
  `uvm_component_utils(pzvip_uart_sequencer)
endclass
