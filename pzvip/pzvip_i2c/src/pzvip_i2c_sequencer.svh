typedef tue_sequencer #(
  .CONFIGURATION  (pzvip_i2c_configuration  ),
  .STATUS         (pzvip_i2c_status         ),
  .REQ            (tue_sequence_item_dummy  )
) pzvip_i2c_sequencer_base;

class pzvip_i2c_master_sequencer extends pzvip_i2c_sequencer_base;
  `tue_component_default_constructor(pzvip_i2c_master_sequencer)
  `uvm_component_utils(pzvip_i2c_master_sequencer)
endclass

class pzvip_i2c_slave_sequencer extends pzvip_i2c_sequencer_base;
  `tue_component_default_constructor(pzvip_i2c_slave_sequencer)
  `uvm_component_utils(pzvip_i2c_slave_sequencer)
endclass
