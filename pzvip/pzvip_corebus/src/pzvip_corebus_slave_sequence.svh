`ifndef PZVIP_COREBUS_SLAVE_SEQUENCE_SVH
`define PZVIP_COREBUS_SLAVE_SEQUENCE_SVH
typedef tue_reactive_sequence #(
  .CONFIGURATION  (pzvip_corebus_configuration  ),
  .STATUS         (pzvip_corebus_status         ),
  .ITEM           (pzvip_corebus_slave_item     )
) pzvip_corebus_slave_sequence_base;

class pzvip_corebus_slave_sequence extends pzvip_corebus_sequence_base #(
  .BASE       (pzvip_corebus_slave_sequence_base  ),
  .SEQUENCER  (pzvip_corebus_slave_sequencer      ),
  .ITEM       (pzvip_corebus_slave_item           )
);
  `tue_object_default_constructor(pzvip_corebus_slave_sequence)
endclass
`endif
