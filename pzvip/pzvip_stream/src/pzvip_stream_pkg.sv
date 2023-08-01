//========================================
//
// Copyright (c) 2023 PEZY Computing, K.K.
//                    All Rights Reserved.
//
//========================================
`ifndef PZVIP_STEAM_PKG_SV
`define PZVIP_STEAM_PKG_SV

`include  "pzvip_stream_defines.svh"

package pzvip_stream_pkg;
  import  uvm_pkg::*;
  import  tue_pkg::*;
  import  pzvip_common_pkg::*;

  `include  "uvm_macros.svh"
  `include  "tue_macros.svh"
  `include  "pzvip_common_macros.svh"

  typedef virtual pzvip_stream_if                   pzvip_stream_vif;
  typedef bit [`PZVIP_STREAM_MAX_DATA_WIDTH-1:0]    pzvip_stream_data;
  typedef bit [`PZVIP_STREAM_MAX_DATA_WIDTH/8-1:0]  pzvip_stream_byte_enable;

  `include  "pzvip_stream_configuration.svh"
  `include  "pzvip_stream_status.svh"
  `include  "pzvip_stream_item.svh"
  `include  "pzvip_stream_monitor.svh"
  `include  "pzvip_stream_driver.svh"
  `include  "pzvip_stream_ready_driver.svh"
  `include  "pzvip_stream_sequencer.svh"
  `include  "pzvip_stream_agent.svh"
  `include  "pzvip_stream_sequence.svh"
  `include  "pzvip_stream_send_byte_stream_sequence.svh"
  `include  "pzvip_stream_send_file_stream_sequence.svh"
endpackage

`endif
