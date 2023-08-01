class pzvip_spi_agent_base #(
  type  SEQUENCER = uvm_sequencer
) extends tue_param_agent #(
  .CONFIGURATION  (pzvip_spi_configuration  ),
  .STATUS         (pzvip_spi_status         ),
  .SEQUENCER      (SEQUENCER                )
);
  `tue_component_default_constructor(pzvip_spi_agent_base)
endclass

class pzvip_spi_master_agent extends pzvip_spi_agent_base #(
  .SEQUENCER  (pzvip_spi_master_sequencer )
);
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    configuration.vif.ss_n  = '1;
  endfunction

  `tue_component_default_constructor(pzvip_spi_master_agent)
  `uvm_component_utils(pzvip_spi_master_agent)
endclass

class pzvip_spi_slave_agent extends pzvip_spi_agent_base #(
  .SEQUENCER  (pzvip_spi_slave_sequencer  )
);
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    configuration.vif.slave_devices = configuration.slave_devices;
  endfunction

  `tue_component_default_constructor(pzvip_spi_slave_agent)
  `uvm_component_utils(pzvip_spi_slave_agent)
endclass
