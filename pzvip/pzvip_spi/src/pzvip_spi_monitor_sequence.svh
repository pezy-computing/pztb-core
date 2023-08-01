class pzvip_spi_monitor_sequence extends pzvip_spi_sequence_base;
  int slave_index;
  bit mosi_bits[];
  bit miso_bits[];

  task body();
    bit bits[2][$];
    vif.monitor_spi_access(slave_index, bits[0], bits[1]);
    mosi_bits = new[bits[0].size()];
    miso_bits = new[bits[1].size()];
    foreach (bits[0][i]) begin
      mosi_bits[i]  = bits[0][i];
      miso_bits[i]  = bits[1][i];
    end
  endtask

  `tue_object_default_constructor(pzvip_spi_monitor_sequence)
  `uvm_object_utils_begin(pzvip_spi_monitor_sequence)
    `uvm_field_int(slave_index, UVM_DEFAULT | UVM_DEC)
    `uvm_field_array_int(mosi_bits, UVM_DEFAULT | UVM_BIN)
    `uvm_field_array_int(miso_bits, UVM_DEFAULT | UVM_BIN)
  `uvm_object_utils_end
endclass
