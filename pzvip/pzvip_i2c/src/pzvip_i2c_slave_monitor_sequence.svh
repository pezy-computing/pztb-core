class pzvip_i2c_slave_monitor_sequence extends pzvip_i2c_slave_sequence_base;
  bit [9:0]           address;
  bit                 read_access;
  pzvip_i2c_byte_item data[];

  task body();
    wait_for_start();
    sample_data();
  endtask

  protected task wait_for_start();
    bit [7:0] sda_byte;
    bit       acknack;

    forever begin
      vif.wait_for_start_condition();

      vif.sample_byte_acknack(sda_byte, acknack);
      if (acknack) begin
        continue;
      end
      else begin
        read_access = sda_byte[0];
        if (configuration.support_10bits_address && (sda_byte[3+:5] == 5'b1111_0)) begin
          address[8+:2] = sda_byte[1+:2];
        end
        else begin
          address = sda_byte[1+:7];
          return;
        end
      end

      vif.sample_byte_acknack(sda_byte, acknack);
      if (acknack) begin
        continue;
      end
      else begin
        address[0+:8] = sda_byte;
        return;
      end
    end
  endtask

  protected task sample_data();
    pzvip_i2c_byte_item items[$];

    forever begin
      fork
        sample_i2c_item(items);
        @(vif.start_condition, vif.stop_condition);
      join_any
      disable fork;

      if (vif.start_condition.triggered || vif.stop_condition.triggered) begin
        data  = new[items.size()](items);
        return;
      end
    end
  endtask

  protected task sample_i2c_item(ref pzvip_i2c_byte_item items[$]);
    bit [7:0]           sda_byte;
    bit                 sda_acknack;
    pzvip_i2c_byte_item item;
    while (1) begin
      vif.sample_byte_acknack(sda_byte, sda_acknack);
      item      = pzvip_i2c_byte_item::type_id::create("monitor_item");
      item.data = sda_byte;
      item.nack = sda_acknack;
      items.push_back(item);
    end
  endtask

  `tue_object_default_constructor(pzvip_i2c_slave_monitor_sequence)
  `uvm_object_utils_begin(pzvip_i2c_slave_monitor_sequence)
    `uvm_field_int(address, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(read_access, UVM_DEFAULT | UVM_BIN)
    `uvm_field_array_object(data, UVM_DEFAULT)
  `uvm_object_utils_end
endclass
