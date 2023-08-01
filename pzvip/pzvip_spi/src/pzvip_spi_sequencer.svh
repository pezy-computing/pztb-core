typedef tue_sequencer #(
  .CONFIGURATION  (pzvip_spi_configuration  ),
  .STATUS         (pzvip_spi_status         ),
  .REQ            (tue_sequence_item_dummy  )
) pzvip_spi_sequencer_base;

class pzvip_spi_master_sequencer extends pzvip_spi_sequencer_base;
  `tue_component_default_constructor(pzvip_spi_master_sequencer)
  `uvm_component_utils(pzvip_spi_master_sequencer)
endclass

class pzvip_spi_slave_sequencer extends pzvip_spi_sequencer_base;
  `tue_component_default_constructor(pzvip_spi_slave_sequencer)
  `uvm_component_utils(pzvip_spi_slave_sequencer)
endclass
