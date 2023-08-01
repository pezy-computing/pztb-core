//========================================
//
// Copyright (c) 2023 PEZY Computing, K.K.
//                    All Rights Reserved.
//
//========================================
package pzvip_i2c_pkg;
  import  uvm_pkg::*;
  import  tue_pkg::*;
  import  pzvip_common_pkg::*;

  `include  "uvm_macros.svh"
  `include  "tue_macros.svh"

  typedef virtual pzvip_i2c_if  pzvip_i2c_vif;

  `include  "pzvip_i2c_configuration.svh"
  `include  "pzvip_i2c_status.svh"
  `include  "pzvip_i2c_item.svh"
  `include  "pzvip_i2c_sequencer.svh"
  `include  "pzvip_i2c_agent.svh"
  `include  "pzvip_i2c_sequence_base.svh"
  `include  "pzvip_i2c_master_send_bytes_sequence.svh"
  `include  "pzvip_i2c_master_receive_bytes_sequence.svh"
  `include  "pzvip_i2c_slave_monitor_raw_data_sequence.svh"
  `include  "pzvip_i2c_slave_monitor_sequence.svh"
  `include  "pzvip_i2c_slave_random_response_sequence.svh"
endpackage
