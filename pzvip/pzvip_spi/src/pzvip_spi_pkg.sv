//========================================
//
// Copyright (c) 2023 PEZY Computing, K.K.
//                    All Rights Reserved.
//
//========================================
package pzvip_spi_pkg;
  import  uvm_pkg::*;
  import  tue_pkg::*;
  import  pzvip_common_pkg::*;

  `include  "uvm_macros.svh"
  `include  "tue_macros.svh"

  typedef virtual pzvip_spi_if  pzvip_spi_vif;

  `include  "pzvip_spi_configuration.svh"
  `include  "pzvip_spi_status.svh"
  `include  "pzvip_spi_sequencer.svh"
  `include  "pzvip_spi_agent.svh"
  `include  "pzvip_spi_sequence_base.svh"
  `include  "pzvip_spi_monitor_sequence.svh"
  `include  "pzvip_spi_master_access_sequence.svh"
  `include  "pzvip_spi_slave_set_clock_mode_sequence.svh"
  `include  "pzvip_spi_slave_random_response_sequence.svh"
endpackage
