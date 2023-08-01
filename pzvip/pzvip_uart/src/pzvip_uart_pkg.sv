//========================================
//
// Copyright (c) 2023 PEZY Computing, K.K.
//                    All Rights Reserved.
//
//========================================
package pzvip_uart_pkg;
  timeunit  1ns;

  import  uvm_pkg::*;
  import  tue_pkg::*;
  import  pzvip_common_pkg::*;

  `include  "uvm_macros.svh"
  `include  "tue_macros.svh"

  typedef virtual pzvip_uart_if pzvip_uart_vif;

  typedef enum {
    PZVIP_UART_PARITY_NONE,
    PZVIP_UART_EVEN_PARITY,
    PZVIP_UART_ODD_PARITY
  } pzvip_uart_parity;

  `include  "pzvip_uart_configuration.svh"
  `include  "pzvip_uart_status.svh"
  `include  "pzvip_uart_sequencer.svh"
  `include  "pzvip_uart_agent.svh"
  `include  "pzvip_uart_sequence_base.svh"
  `include  "pzvip_uart_tx_data_sequence.svh"
  `include  "pzvip_uart_rx_data_sequence.svh"
endpackage
