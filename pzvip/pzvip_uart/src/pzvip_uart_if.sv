//========================================
//
// Copyright (c) 2023 PEZY Computing, K.K.
//                    All Rights Reserved.
//
//========================================
interface pzvip_uart_if;
  timeunit  1ns;

  bit tx  = '1;
  bit rx;

  task automatic drive_tx(
    input realtime  period_ns,
    ref   bit       tx_bits[$]
  );
    foreach (tx_bits[i]) begin
      tx  = tx_bits[i];
      #(period_ns);
    end
    tx  = 1;
  endtask

  task automatic monitor_rx(
    input realtime  period_ns,
    input int       bit_count,
    ref   bit       rx_bits[$]
  );
    @(negedge rx);
    repeat (bit_count) begin
      #(period_ns / 2);
      rx_bits.push_back(rx);
      #(period_ns / 2);
    end
  endtask
endinterface
