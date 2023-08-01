`ifndef PZVIP_COREBUS_SLAVE_BACKDOOR_PUT_SEQUENCE_SVH
`define PZVIP_COREBUS_SLAVE_BACKDOOR_PUT_SEQUENCE_SVH
class pzvip_corebus_slave_backdoor_put_sequence extends pzvip_corebus_slave_sequence;
  rand  pzvip_corebus_address     address;
  rand  int                       length;
  rand  int                       width;
  rand  pzvip_corebus_data        data[];
  rand  pzvip_corebus_byte_enable byte_enable[];

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
    soft width == this.configuration.data_width;
  }

  constraint c_valid_data {
    solve length, width before data;
    data.size() == length;
    foreach (data[i]) {
      (data[i] >> width) == 0;
    }
  }

  constraint c_valid_byte_enable {
    solve length before byte_enable;

    if (this.configuration.profile == PZVIP_COREBUS_CSR) {
      byte_enable.size() == 0;
    }
    else {
      byte_enable.size() == length;
    }

    foreach (byte_enable[i]) {
      (byte_enable[i] >> this.configuration.byte_enable_width) == 0;
    }
  }

  task body();
    int byte_width;

    if (width > 0) begin
      byte_width  = width / 8;
    end
    else begin
      byte_width  = configuration.data_width / 8;
    end

    foreach (data[i]) begin
      status.memory.put(data[i], get_byte_enable(i), address, i, byte_width);
    end
  endtask

  local function pzvip_corebus_byte_enable get_byte_enable(int index);
    if (configuration.profile == PZVIP_COREBUS_CSR) begin
      return '1;
    end
    else begin
      return byte_enable[index];
    end
  endfunction

  `tue_object_default_constructor(pzvip_corebus_slave_backdoor_put_sequence)
  `uvm_object_utils_begin(pzvip_corebus_slave_backdoor_put_sequence)
    `uvm_field_int(address, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(length, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(width, UVM_DEFAULT | UVM_DEC)
    `uvm_field_array_int(data, UVM_DEFAULT | UVM_HEX)
    `uvm_field_array_int(byte_enable, UVM_DEFAULT | UVM_HEX)
  `uvm_object_utils_end
endclass
`endif
