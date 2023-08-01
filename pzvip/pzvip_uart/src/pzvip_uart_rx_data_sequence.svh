class pzvip_uart_rx_data_sequence extends pzvip_uart_sequence_base;
  rand  int               bit_rate;
  rand  pzvip_uart_parity parity;
  rand  int               data_bits;
  rand  int               stop_bits;
        bit [8:0]         data;
        bit               parity_error;
        bit               framing_error;

  constraint c_valid_bit_rate {
    bit_rate > 0;
  }

  constraint c_valid_data_bits {
    data_bits inside {[5:9]};
  }

  constraint c_valid_stop_bits {
    stop_bits inside {1, 2};
  }

  task body();
    int       bit_count;
    realtime  period_ns;
    bit       rx_bits[$];
    bit       parity_bit;
    bit       stop_bit;

    bit_count += 1;
    bit_count += data_bits;
    bit_count += ((parity != PZVIP_UART_PARITY_NONE) ? 1 : 0);
    bit_count += stop_bits;

    period_ns = 1s / real'(bit_rate);
    vif.monitor_rx(period_ns, bit_count, rx_bits);

    void'(rx_bits.pop_front()); //  start bit
    for (int i = 0;i < data_bits;++i) begin
      data[i] = rx_bits.pop_front();
    end
    if (parity != PZVIP_UART_PARITY_NONE) begin
      parity_bit    = rx_bits.pop_front();
      parity_error  = parity_bit != calc_parity(parity, data_bits, data);
    end
    repeat (stop_bits) begin
      stop_bit  = rx_bits.pop_front();
      if (stop_bit == 0) begin
        framing_error = 1;
      end
    end
  endtask

  `tue_object_default_constructor(pzvip_uart_rx_data_sequence)
  `uvm_object_utils_begin(pzvip_uart_rx_data_sequence)
    `uvm_field_int(bit_rate, UVM_DEFAULT | UVM_DEC)
    `uvm_field_enum(pzvip_uart_parity, parity, UVM_DEFAULT)
    `uvm_field_int(data_bits, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(stop_bits, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(data, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(parity_error, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(framing_error, UVM_DEFAULT | UVM_BIN)
  `uvm_object_utils_end
endclass
