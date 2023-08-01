class pzvip_uart_agent extends tue_param_agent #(
  .CONFIGURATION  (pzvip_uart_configuration ),
  .STATUS         (pzvip_uart_status        ),
  .SEQUENCER      (pzvip_uart_sequencer     )
);
  `tue_component_default_constructor(pzvip_uart_agent)
  `uvm_component_utils(pzvip_uart_agent)
endclass
