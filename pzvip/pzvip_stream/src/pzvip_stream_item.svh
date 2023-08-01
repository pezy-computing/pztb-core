class pzvip_stream_unit_item extends tue_sequence_item #(
  .CONFIGURATION  (pzvip_stream_configuration ),
  .STATUS         (pzvip_stream_status        )
);
  rand  pzvip_stream_data         data;
  rand  pzvip_stream_byte_enable  byte_enable;
  rand  bit                       last;

  `tue_object_default_constructor(pzvip_stream_unit_item)
  `uvm_object_utils_begin(pzvip_stream_unit_item)
    `uvm_field_int(data, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(byte_enable, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(last, UVM_DEFAULT | UVM_BIN)
  `uvm_object_utils_end
endclass

class pzvip_stream_item extends tue_sequence_item #(
  .CONFIGURATION  (pzvip_stream_configuration ),
  .STATUS         (pzvip_stream_status        )
);
  rand  int                       length;
  rand  pzvip_stream_data         data[];
  rand  pzvip_stream_byte_enable  byte_enable[];
  rand  int                       delay[];

  constraint c_valid_length {
    length > 0;
  }

  constraint c_valid_data {
    solve length before data;
    data.size() == length;
    foreach (data[i]) {
      (data[i] >> this.configuration.data_width) == 0;
    }
  }

  constraint c_valid_byte_enable {
    solve length before byte_enable;
    byte_enable.size() == length;
    foreach (byte_enable[i]) {
      (byte_enable[i] >> this.configuration.byte_enable_width) == 0;
    }
  }

  constraint c_valid_delay {
    solve length before delay;
    delay.size() == length;
    `pzvip_array_delay_constraint(delay, this.configuration.data_delay)
  }

  function void put(const ref pzvip_stream_unit_item units[$]);
    data        = new[units.size()];
    byte_enable = new[units.size()];
    foreach (units[i]) begin
      data[i]         = units[i].data;
      byte_enable[i]  = units[i].byte_enable;
    end
  endfunction

  `tue_object_default_constructor(pzvip_stream_item)
  `uvm_object_utils_begin(pzvip_stream_item)
    `uvm_field_int(length, UVM_DEFAULT | UVM_DEC)
    `uvm_field_array_int(data, UVM_DEFAULT | UVM_HEX)
    `uvm_field_array_int(byte_enable, UVM_DEFAULT | UVM_HEX)
    `uvm_field_array_int(delay, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
  `uvm_object_utils_end
endclass
