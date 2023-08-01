`ifndef PZVIP_COREBUS_MASTER_SEQUENCER_SVH
`define PZVIP_COREBUS_MASTER_SEQUENCER_SVH
typedef tue_sequencer #(
  .CONFIGURATION  (pzvip_corebus_configuration  ),
  .STATUS         (pzvip_corebus_status         ),
  .REQ            (pzvip_corebus_master_item    )
) pzvip_corebus_master_sequencer_base;

class pzvip_corebus_master_sequencer extends pzvip_corebus_sequencer_base #(
  .BASE (pzvip_corebus_master_sequencer_base  ),
  .ITEM (pzvip_corebus_master_item            )
);
  `tue_component_default_constructor(pzvip_corebus_master_sequencer)
  `uvm_component_utils(pzvip_corebus_master_sequencer)
endclass
`endif
