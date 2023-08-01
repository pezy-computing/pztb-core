class pzvip_i2c_slave_monitor_raw_data_sequence extends pzvip_i2c_slave_sequence_base;
  pzvip_i2c_byte_item data[];

  task body();
    vif.wait_for_start_condition();
    sample_data();
  endtask

  protected task sample_data();
    pzvip_i2c_byte_item items[$];

    fork
      sample_data_item(items);
      @(vif.start_condition, vif.stop_condition);
    join_any
    disable fork;

    data  = new[items.size()](items);
  endtask

  protected task sample_data_item(ref pzvip_i2c_byte_item items[$]);
    bit [7:0]           sda_byte;
    bit                 acknack;
    pzvip_i2c_byte_item item;
    while (1) begin
      vif.sample_byte_acknack(sda_byte, acknack);
      item      = pzvip_i2c_byte_item::type_id::create("monitor_item");
      item.data = sda_byte;
      item.nack = acknack;
      items.push_back(item);
    end
  endtask

  `tue_object_default_constructor(pzvip_i2c_slave_monitor_raw_data_sequence)
  `uvm_object_utils_begin(pzvip_i2c_slave_monitor_raw_data_sequence)
    `uvm_field_array_object(data, UVM_DEFAULT)
  `uvm_object_utils_end
endclass
