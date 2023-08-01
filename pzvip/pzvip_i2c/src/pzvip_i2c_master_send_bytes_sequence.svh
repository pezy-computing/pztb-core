class pzvip_i2c_master_send_bytes_sequence extends pzvip_i2c_master_access_sequence_base;
  rand  bit [7:0] tx_bytes[];

  constraint c_valid_tx_bytes {
    solve length before tx_bytes;
    tx_bytes.size() == length;
  }

  task body();
    bit nack;
    bit lost_arbitration;

    start_access(1, nack, lost_arbitration);
    if (lost_arbitration) begin
      return;
    end
    else if (nack) begin
      stop_access(1);
      return;
    end

    foreach (tx_bytes[i]) begin
      send_byte(tx_bytes[i], nack, lost_arbitration);
      if (lost_arbitration) begin
        return;
      end
      else if (nack) begin
        break;
      end
    end

    stop_access();
  endtask

  `tue_object_default_constructor(pzvip_i2c_master_send_bytes_sequence)
  `uvm_object_utils_begin(pzvip_i2c_master_send_bytes_sequence)
    `uvm_field_array_int(tx_bytes, UVM_DEFAULT | UVM_HEX)
  `uvm_object_utils_end
endclass
