`ifndef PZVIP_COREBUS_MASTER_SEQUENCE_SVH
`define PZVIP_COREBUS_MASTER_SEQUENCE_SVH
typedef tue_sequence #(
  .CONFIGURATION  (pzvip_corebus_configuration  ),
  .STATUS         (pzvip_corebus_status         ),
  .REQ            (pzvip_corebus_master_item    )
) pzvip_corebus_master_sequence_base;

class pzvip_corebus_master_sequence extends pzvip_corebus_sequence_base #(
  .BASE       (pzvip_corebus_master_sequence_base ),
  .SEQUENCER  (pzvip_corebus_master_sequencer     ),
  .ITEM       (pzvip_corebus_master_item          )
);
  `tue_object_default_constructor(pzvip_corebus_master_sequence)
endclass
`endif
