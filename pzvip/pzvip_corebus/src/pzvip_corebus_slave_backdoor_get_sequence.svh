`ifndef PZVIP_COREBUS_SLAVE_BACKDOOR_GET_SEQUENCE_SVH
`define PZVIP_COREBUS_SLAVE_BACKDOOR_GET_SEQUENCE_SVH
class pzvip_corebus_slave_backdoor_get_sequence extends pzvip_corebus_slave_sequence;
  rand  pzvip_corebus_address address;
  rand  int                   length;
  rand  int                   width;
        pzvip_corebus_data    data[];


  constraint c_valid_address {
    (address >> this.configuration.address_width) == 0;
  }

  constraint c_valid_length {
    length > 0;
  }

  constraint c_valid_width {
    width inside {[this.configuration.unit_data_width:this.configuration.max_data_width]};
    (width % this.configuration.unit_data_width) == 0;
  }

  constraint c_default_width {
    soft width == configuration.data_width;
  }

  task body();
    int byte_width;

    if (width > 0) begin
      byte_width  = width / 8;
    end
    else begin
      byte_width  = configuration.data_width / 8;
    end

    data  = new[length];
    foreach (data[i]) begin
      data[i] = status.memory.get(address, i, byte_width);
    end
  endtask

  `tue_object_default_constructor(pzvip_corebus_slave_backdoor_get_sequence)
  `uvm_object_utils_begin(pzvip_corebus_slave_backdoor_get_sequence)
    `uvm_field_int(address, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(length, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(width, UVM_DEFAULT | UVM_DEC)
    `uvm_field_array_int(data, UVM_DEFAULT | UVM_HEX)
  `uvm_object_utils_end
endclass
`endif
