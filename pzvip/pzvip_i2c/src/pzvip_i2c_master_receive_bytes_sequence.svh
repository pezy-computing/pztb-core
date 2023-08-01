class pzvip_i2c_master_receive_bytes_sequence extends pzvip_i2c_master_access_sequence_base;
  bit [7:0] rx_bytes[];

  task body();
    bit [7:0] rx_queue[$];
    bit [7:0] rx_byte;
    bit       nack;
    bit       lost_arbitration;

    start_access(0, nack, lost_arbitration);
    if (lost_arbitration) begin
      return;
    end
    else if (nack) begin
      stop_access(1);
      return;
    end

    for (int i = 0;i < length;++i) begin
      if ((i + 1) == length) begin
        receive_byte(rx_byte, 1, lost_arbitration);
      end
      else begin
        receive_byte(rx_byte, 0, lost_arbitration);
      end

      if (lost_arbitration) begin
        return;
      end

      rx_queue.push_back(rx_byte);
    end

    stop_access();
    rx_bytes  = new[rx_queue.size()](rx_queue);
  endtask

  `tue_object_default_constructor(pzvip_i2c_master_receive_bytes_sequence)
  `uvm_object_utils_begin(pzvip_i2c_master_receive_bytes_sequence)
    `uvm_field_array_int(rx_bytes, UVM_DEFAULT | UVM_HEX)
  `uvm_object_utils_end
endclass
