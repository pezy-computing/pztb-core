class pzvip_uart_tx_data_sequence extends pzvip_uart_sequence_base;
  rand  int               bit_rate;
  rand  pzvip_uart_parity parity;
  rand  int               data_bits;
  rand  int               stop_bits;
  rand  bit [8:0]         data;
  rand  int               parity_error;
  rand  int               framing_error[2];

  constraint c_valid_bit_rate {
    bit_rate > 0;
  }

  constraint c_valid_data_bits {
    data_bits inside {[5:9]};
  }

  constraint c_valid_data {
    solve data_bits before data;
    (data >> data_bits) == 0;
  }

  constraint c_valid_stop_bits {
    stop_bits inside {1, 2};
  }

  constraint c_valid_parity_error {
    parity_error inside {-1, 0, 1};
  }

  constraint c_default_parity_error {
    soft parity_error == -1;
  }

  constraint c_valid_framing_error {
    solve stop_bits before framing_error;
    framing_error[0] inside {-1, 0, 1};
    framing_error[1] inside {-1, 0, 1};
    if (stop_bits == 1) {
      framing_error[1] != 1;
    }
  }

  constraint c_default_framing_error {
    soft framing_error[0] == -1;
    soft framing_error[1] == -1;
  }

  task body();
    bit       tx_bits[$];
    realtime  period_ns;

    tx_bits.push_back(0); //  start bit
    for (int i = 0;i < data_bits;++i) begin
      tx_bits.push_back(data[i]);
    end
    if (parity != PZVIP_UART_PARITY_NONE) begin
      if (parity_error == 1) begin
        tx_bits.push_back(calc_parity(parity, data_bits, data, 1));
      end
      else begin
        tx_bits.push_back(calc_parity(parity, data_bits, data, 0));
      end
    end
    for (int i = 0;i < stop_bits;++i) begin
      if (framing_error[i] == 1) begin
        tx_bits.push_back(0);
      end
      else begin
        tx_bits.push_back(1);
      end
    end

    period_ns = 1s / real'(bit_rate);
    vif.drive_tx(period_ns, tx_bits);
  endtask

  `tue_object_default_constructor(pzvip_uart_tx_data_sequence)
  `uvm_object_utils_begin(pzvip_uart_tx_data_sequence)
    `uvm_field_int(bit_rate, UVM_DEFAULT | UVM_DEC)
    `uvm_field_enum(pzvip_uart_parity, parity, UVM_DEFAULT)
    `uvm_field_int(data_bits, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(stop_bits, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(data, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(parity_error, UVM_DEFAULT | UVM_DEC)
    `uvm_field_sarray_int(framing_error, UVM_DEFAULT | UVM_DEC)
  `uvm_object_utils_end
endclass
