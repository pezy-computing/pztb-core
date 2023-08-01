//========================================
//
// Copyright (c) 2023 PEZY Computing, K.K.
//                    All Rights Reserved.
//
//========================================
`ifndef PZVIP_STREAM_IF_SV
`define PZVIP_STREAM_IF_SV

`include  "pzvip_stream_defines.svh"

interface pzvip_stream_if (
  input var i_clk,
  input var i_rst_n
);
  typedef logic [`PZVIP_STREAM_MAX_DATA_WIDTH-1:0]    pzvip_stream_data;
  typedef logic [`PZVIP_STREAM_MAX_DATA_WIDTH/8-1:0]  pzvip_stream_byte_enable;

  logic                     valid;
  logic                     ready;
  pzvip_stream_data         data;
  pzvip_stream_byte_enable  byte_enable;
  logic                     last;
  logic                     ack;

  logic default_valid = 0;
  logic default_ready = 1;

  always_comb begin
    ack = valid && ready;
  end

  clocking master_cb @(posedge i_clk);
    output  valid;
    input   ready;
    output  data;
    output  byte_enable;
    output  last;
    input   ack;
  endclocking

  clocking slave_cb @(posedge i_clk);
    input   valid;
    output  ready;
    input   data;
    input   byte_enable;
    input   last;
    input   ack;
  endclocking

  clocking monitor_cb @(posedge i_clk);
    input valid;
    input ready;
    input data;
    input byte_enable;
    input last;
    input ack;
  endclocking

  function automatic void reset_master();
    valid = default_valid;
  endfunction

  function automatic void reset_slave();
    ready = default_ready;
  endfunction
endinterface

`endif
