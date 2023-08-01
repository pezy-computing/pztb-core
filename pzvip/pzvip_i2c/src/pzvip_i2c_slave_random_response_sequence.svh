class pzvip_i2c_slave_random_response_sequence extends pzvip_i2c_slave_sequence_base;
  task body();
    bit read_access;

    forever begin
      wait_for_start(read_access);
      fork
        if (read_access) begin
          send_data();
        end
        else begin
          receive_data();
        end
        @(vif.start_condition, vif.stop_condition);
      join_any
      disable fork;
    end
  endtask

  protected task wait_for_start(ref bit read_access);
    bit [7:0] sda_byte;
    bit       sda_bit;

    forever begin
      vif.wait_for_start_condition();

      vif.sample_byte(sda_byte);
      if (!configuration.support_10bits_address) begin
        if (sda_byte[1+:7] == configuration.address[0+:7]) begin
          read_access = sda_byte[0];
          vif.drive_i2c_slave(0, 0, sda_bit);
          return;
        end
        else begin
          continue;
        end
      end
      else begin
        if (sda_byte[1+:7] == {5'b1111_0, configuration.address[8+:2]}) begin
          read_access = sda_byte[0];
          vif.drive_i2c_slave(0, 0, sda_bit);
        end
        else begin
          continue;
        end
      end

      vif.sample_byte(sda_byte);
      if (sda_byte == configuration.address[0+:8]) begin
        vif.drive_i2c_slave(0, 0, sda_bit);
        return;
      end
      else begin
        continue;
      end
    end
  endtask

  protected task send_data();
    bit [7:0] data;
    bit       acknack;
    bit       dummy;
    forever begin
      data  = $urandom_range(0, 255);
      for (int i = 7;i >= 0;--i) begin
        vif.drive_i2c_slave(0, data[i], dummy);
      end
      vif.sample_bit(acknack);
    end
  endtask

  protected task receive_data();
    bit       sda_bit;
    bit [7:0] data;
    bit       acknack;
    forever begin
      for (int i = 7;i >= 0;--i) begin
        vif.sample_bit(sda_bit);
        data[i] = sda_bit;
      end
      vif.drive_i2c_slave(0, $urandom_range(0, 1), acknack);
    end
  endtask

  `tue_object_default_constructor(pzvip_i2c_slave_random_response_sequence)
  `uvm_object_utils(pzvip_i2c_slave_random_response_sequence)
endclass
