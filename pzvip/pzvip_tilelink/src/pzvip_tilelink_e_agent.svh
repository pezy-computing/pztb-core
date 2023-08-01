`ifndef PZVIP_TILELINK_E_AGENT_SVH
`define PZVIP_TILELINK_E_AGENT_SVH
typedef tue_sequencer #(
  .CONFIGURATION  (pzvip_tilelink_configuration ),
  .STATUS         (pzvip_tilelink_status        ),
  .REQ            (pzvip_tilelink_message_item  )
) pzvip_tilelink_e_sequencer;

class pzvip_tilelink_e_master_agent extends pzvip_tilelink_agent_base #(
  .MONITOR    (pzvip_tilelink_e_sender_monitor  ),
  .SEQUENCER  (pzvip_tilelink_e_sequencer       ),
  .DRIVER     (pzvip_tilelink_e_sender_driver   ),
  .IS_SENDER  (1                                )
);
  `tue_component_default_constructor(pzvip_tilelink_e_master_agent)
  `uvm_component_utils(pzvip_tilelink_e_master_agent)
endclass

class pzvip_tilelink_e_slave_agent extends pzvip_tilelink_agent_base #(
  .MONITOR    (pzvip_tilelink_e_receiver_monitor  ),
  .SEQUENCER  (pzvip_tilelink_e_sequencer         ),
  .DRIVER     (pzvip_tilelink_e_receiver_driver   ),
  .IS_SENDER  (0                                  )
);
  `tue_component_default_constructor(pzvip_tilelink_e_slave_agent)
  `uvm_component_utils(pzvip_tilelink_e_slave_agent)
endclass
`endif
