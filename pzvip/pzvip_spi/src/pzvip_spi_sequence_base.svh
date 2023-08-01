class pzvip_spi_sequence_base extends tue_sequence #(
  .CONFIGURATION  (pzvip_spi_configuration  ),
  .STATUS         (pzvip_spi_status         )
);
  protected pzvip_spi_vif vif;

  function new(string name = "pzvip_spi_sequence_base");
    super.new(name);
    set_automatic_phase_objection(0);
  endfunction

  function void set_configuration(tue_configuration configuration);
    super.set_configuration(configuration);
    vif = this.configuration.vif;
  endfunction

  `uvm_declare_p_sequencer(pzvip_spi_sequencer_base)
endclass

class pzvip_spi_master_sequence_base extends pzvip_spi_sequence_base;
  `uvm_declare_p_sequencer(pzvip_spi_master_sequencer)
  `tue_object_default_constructor(pzvip_spi_master_sequence_base)
endclass

class pzvip_spi_slave_sequence_base extends pzvip_spi_sequence_base;
  `uvm_declare_p_sequencer(pzvip_spi_slave_sequencer)
  `tue_object_default_constructor(pzvip_spi_slave_sequence_base)
endclass
