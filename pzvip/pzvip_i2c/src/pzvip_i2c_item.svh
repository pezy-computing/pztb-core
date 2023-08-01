typedef tue_sequence_item #(
  .CONFIGURATION  (pzvip_i2c_configuration  ),
  .STATUS         (pzvip_i2c_status         )
) pzvip_i2c_item_base;

class pzvip_i2c_byte_item extends pzvip_i2c_item_base;
  rand  bit [7:0] data;
  rand  bit       nack;
  `tue_object_default_constructor(pzvip_i2c_byte_item)
  `uvm_object_utils_begin(pzvip_i2c_byte_item)
    `uvm_field_int(data, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(nack, UVM_DEFAULT | UVM_BIN)
  `uvm_object_utils_end
endclass

class pzvip_i2c_item extends pzvip_i2c_item_base;
  rand  bit [9:0]           address;
  rand  bit                 read_access;
  rand  pzvip_i2c_byte_item data[];
        bit                 no_slave;
        bit                 lost_arbitration;

  `tue_object_default_constructor(pzvip_i2c_item)
  `uvm_object_utils_begin(pzvip_i2c_item)
    `uvm_field_int(address, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(read_access, UVM_DEFAULT | UVM_BIN)
    `uvm_field_array_object(data, UVM_DEFAULT)
    `uvm_field_int(no_slave, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(lost_arbitration, UVM_DEFAULT | UVM_BIN)
  `uvm_object_utils_end
endclass
