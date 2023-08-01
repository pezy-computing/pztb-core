class pzvip_i2c_agent_base #(
  type  SEQUENCER = uvm_sequencer
) extends tue_param_agent #(
  .CONFIGURATION  (pzvip_i2c_configuration  ),
  .STATUS         (pzvip_i2c_status         ),
  .SEQUENCER      (SEQUENCER                )
);
  `tue_component_default_constructor(pzvip_i2c_agent_base)
endclass

class pzvip_i2c_master_agent extends pzvip_i2c_agent_base #(
  .SEQUENCER  (pzvip_i2c_master_sequencer )
);
  `tue_component_default_constructor(pzvip_i2c_master_agent)
  `uvm_component_utils(pzvip_i2c_master_agent)
endclass

class pzvip_i2c_slave_agent extends pzvip_i2c_agent_base #(
  .SEQUENCER  (pzvip_i2c_slave_sequencer  )
);
  `tue_component_default_constructor(pzvip_i2c_slave_agent)
  `uvm_component_utils(pzvip_i2c_slave_agent)
endclass
