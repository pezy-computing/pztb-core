class pzvip_i2c_configuration extends tue_configuration;
        pzvip_i2c_vif vif;
  rand  bit           support_10bits_address;
  rand  bit [9:0]     address;
  rand  int           wait_scl_timeout_ns;

  constraint c_valid_address {
    if (!support_10bits_address) {
      address[7+:3] == '0;
    }
  }

  constraint c_wait_scl_timeout_ns {
    wait_scl_timeout_ns >= 0;
    soft wait_scl_timeout_ns == 0;
  }

  `tue_object_default_constructor(pzvip_i2c_configuration)
  `uvm_object_utils_begin(pzvip_i2c_configuration)
    `uvm_field_int(support_10bits_address, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(address, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(wait_scl_timeout_ns, UVM_DEFAULT | UVM_DEC)
  `uvm_object_utils_end
endclass
