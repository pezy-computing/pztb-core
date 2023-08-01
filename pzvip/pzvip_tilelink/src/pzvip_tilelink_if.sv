//========================================
//
// Copyright (c) 2023 PEZY Computing, K.K.
//                    All Rights Reserved.
//
//========================================
`ifndef PZVIP_TILELINK_IF_SV
`define PZVIP_TILELINK_IF_SV
interface pzvip_tilelink_channel_if #(
  type  PAYLOAD = pzvip_tilelink_types_pkg::pzvip_tilelink_a_payload
)(
  input clock,
  input reset //  active high
);
  logic   valid;
  logic   ready;
  PAYLOAD payload;

  clocking sender_cb @(posedge clock);
    output  valid;
    input   ready;
    output  payload;
  endclocking

  clocking receiver_cb @(posedge clock);
    input   valid;
    output  ready;
    input   payload;
  endclocking

  clocking monitor_cb @(posedge clock);
    input valid;
    input ready;
    input payload;
  endclocking

  bit default_ready;

  function automatic void reset_sender();
    valid <= 0;
  endfunction

  function automatic void reset_receiver();
    ready <= default_ready;
  endfunction
endinterface

interface pzvip_tilelink_if (
  input clock,
  input reset //  active high
);
  import  pzvip_tilelink_types_pkg::pzvip_tilelink_a_payload;
  import  pzvip_tilelink_types_pkg::pzvip_tilelink_b_payload;
  import  pzvip_tilelink_types_pkg::pzvip_tilelink_c_payload;
  import  pzvip_tilelink_types_pkg::pzvip_tilelink_d_payload;
  import  pzvip_tilelink_types_pkg::pzvip_tilelink_e_payload;

  pzvip_tilelink_channel_if #(pzvip_tilelink_a_payload) a(clock, reset);
  pzvip_tilelink_channel_if #(pzvip_tilelink_b_payload) b(clock, reset);
  pzvip_tilelink_channel_if #(pzvip_tilelink_c_payload) c(clock, reset);
  pzvip_tilelink_channel_if #(pzvip_tilelink_d_payload) d(clock, reset);
  pzvip_tilelink_channel_if #(pzvip_tilelink_e_payload) e(clock, reset);

  function automatic void set_default_ready(
    int a_default_ready = -1,
    int b_default_ready = -1,
    int c_default_ready = -1,
    int d_default_ready = -1,
    int e_default_ready = -1
  );
    if (a_default_ready inside {0, 1}) begin
      a.default_ready = a_default_ready;
    end
    if (b_default_ready inside {0, 1}) begin
      b.default_ready = b_default_ready;
    end
    if (c_default_ready inside {0, 1}) begin
      c.default_ready = c_default_ready;
    end
    if (d_default_ready inside {0, 1}) begin
      d.default_ready = d_default_ready;
    end
    if (e_default_ready inside {0, 1}) begin
      e.default_ready = e_default_ready;
    end
  endfunction
endinterface
`endif
