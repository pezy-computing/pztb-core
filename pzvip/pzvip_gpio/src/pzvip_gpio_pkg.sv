//========================================
//
// Copyright (c) 2023 PEZY Computing, K.K.
//                    All Rights Reserved.
//
//========================================
`ifndef PZVIP_GPIO_PKG_SV
`define PZVIP_GPIO_PKG_SV
package pzvip_gpio_pkg;
  import  uvm_pkg::*;
  import  tue_pkg::*;
  import  pzvip_common_pkg::*;

  `include  "uvm_macros.svh"
  `include  "tue_macros.svh"

  `include  "pzvip_gpio_types.svh"

  `include  "pzvip_gpio_configuration.svh"
  `include  "pzvip_gpio_sequencer.svh"
  `include  "pzvip_gpio_agent.svh"

  `include  "pzvip_gpio_sequence.svh"
endpackage
`endif
