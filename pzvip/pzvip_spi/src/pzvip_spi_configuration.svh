class pzvip_spi_configuration extends tue_configuration;
        pzvip_spi_vif vif;
  rand  int           slave_devices;

  constraint c_valid_slave_devices {
    slave_devices inside {[0:`PZVIP_SPI_MAX_SS_WIDTH-1]};
  }

  `tue_object_default_constructor(pzvip_spi_configuration)
  `uvm_object_utils_begin(pzvip_spi_configuration)
    `uvm_field_int(slave_devices, UVM_DEFAULT | UVM_DEC)
  `uvm_object_utils_end
endclass
