class pzvip_spi_master_access_sequence extends pzvip_spi_master_sequence_base;
  rand  int sclk_period_ns;
  rand  bit cpol;
  rand  bit cpha;
  rand  int slave_index;
  rand  int length;
  rand  bit mosi_bits[];
        bit miso_bits[];

  constraint c_valid_sclk_period_ns {
    sclk_period_ns > 0;
  }

  constraint c_valid_slave_index {
    slave_index inside {[0:this.configuration.slave_devices-1]};
  }

  constraint c_valid_length {
    length > 0;
  }

  constraint c_valid_mosi_bits {
    solve length before mosi_bits;
    mosi_bits.size() == length;
  }

  task body();
    miso_bits = new[length];
    vif.do_spi_master_access(
      sclk_period_ns, cpol, cpha, slave_index, mosi_bits, miso_bits
    );
  endtask

  `tue_object_default_constructor(pzvip_spi_master_access_sequence)
  `uvm_object_utils_begin(pzvip_spi_master_access_sequence)
    `uvm_field_int(sclk_period_ns, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(cpol, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(cpha, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(slave_index, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(length, UVM_DEFAULT | UVM_DEC)
    `uvm_field_array_int(mosi_bits, UVM_DEFAULT | UVM_BIN)
    `uvm_field_array_int(miso_bits, UVM_DEFAULT | UVM_BIN)
  `uvm_object_utils_end
endclass
