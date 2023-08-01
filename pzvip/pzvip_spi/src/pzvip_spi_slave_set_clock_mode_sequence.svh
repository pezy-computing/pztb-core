class pzvip_spi_slave_set_clock_mode_sequence extends pzvip_spi_slave_sequence_base;
  rand  bit cpha;
  rand  bit cpol;

  task body();
    vif.cpha  = cpha;
    vif.cpol  = cpol;
  endtask

  `tue_object_default_constructor(pzvip_spi_slave_set_clock_mode_sequence)
  `uvm_object_utils_begin(pzvip_spi_slave_set_clock_mode_sequence)
    `uvm_field_int(cpha, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(cpol, UVM_DEFAULT | UVM_BIN)
  `uvm_object_utils_end
endclass
