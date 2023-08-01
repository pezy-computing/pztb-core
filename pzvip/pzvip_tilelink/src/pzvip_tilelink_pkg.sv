//========================================
//
// Copyright (c) 2023 PEZY Computing, K.K.
//                    All Rights Reserved.
//
//========================================
`ifndef PZVIP_TILELINK_PKG_SV
`define PZVIP_TILELINK_PKG_SV
package pzvip_tilelink_pkg;
  import  uvm_pkg::*;
  import  tue_pkg::*;
  import  pzvip_tilelink_types_pkg::*;

  `include  "uvm_macros.svh"
  `include  "tue_macros.svh"

  typedef virtual pzvip_tilelink_if                                     pzvip_tilelink_vif;
  typedef virtual pzvip_tilelink_channel_if #(pzvip_tilelink_a_payload) pzvip_tilelink_a_vif;
  typedef virtual pzvip_tilelink_channel_if #(pzvip_tilelink_b_payload) pzvip_tilelink_b_vif;
  typedef virtual pzvip_tilelink_channel_if #(pzvip_tilelink_c_payload) pzvip_tilelink_c_vif;
  typedef virtual pzvip_tilelink_channel_if #(pzvip_tilelink_d_payload) pzvip_tilelink_d_vif;
  typedef virtual pzvip_tilelink_channel_if #(pzvip_tilelink_e_payload) pzvip_tilelink_e_vif;

  function automatic int get_number_of_beats(int size, int byte_width);
    return (size + byte_width - 1) / byte_width;
  endfunction

  function automatic pzvip_tilelink_mask get_mask(
    int                     size,
    pzvip_tilelink_address  address,
    int                     byte_width
  );
    if (size < byte_width) begin
      int shift;
      shift = address & (~(size - 1)) & (byte_width - 1);
      return ((1 << size) - 1) << shift;
    end
    else begin
      return (1 << byte_width) - 1;
    end
  endfunction

  `include  "pzvip_tilelink_internal_macros.svh"

  `include  "pzvip_tilelink_defines.svh"
  `include  "pzvip_tilelink_configuration.svh"
  `include  "pzvip_tilelink_status.svh"
  `include  "pzvip_tilelink_memory.svh"
  `include  "pzvip_tilelink_id_manager.svh"
  `include  "pzvip_tilelink_message_item.svh"

  `include  "pzvip_tilelink_monitor_base.svh"
  `include  "pzvip_tilelink_sender_driver_base.svh"
  `include  "pzvip_tilelink_receiver_driver_base.svh"
  `include  "pzvip_tilelink_agent_base.svh"

  `include  "pzvip_tilelink_a_monitor.svh"
  `include  "pzvip_tilelink_a_sender_driver.svh"
  `include  "pzvip_tilelink_a_receiver_driver.svh"
  `include  "pzvip_tilelink_a_agent.svh"

  `include  "pzvip_tilelink_b_monitor.svh"
  `include  "pzvip_tilelink_b_sender_driver.svh"
  `include  "pzvip_tilelink_b_receiver_driver.svh"
  `include  "pzvip_tilelink_b_agent.svh"

  `include  "pzvip_tilelink_c_monitor.svh"
  `include  "pzvip_tilelink_c_sender_driver.svh"
  `include  "pzvip_tilelink_c_receiver_driver.svh"
  `include  "pzvip_tilelink_c_agent.svh"

  `include  "pzvip_tilelink_d_monitor.svh"
  `include  "pzvip_tilelink_d_sender_driver.svh"
  `include  "pzvip_tilelink_d_receiver_driver.svh"
  `include  "pzvip_tilelink_d_agent.svh"

  `include  "pzvip_tilelink_e_monitor.svh"
  `include  "pzvip_tilelink_e_sender_driver.svh"
  `include  "pzvip_tilelink_e_receiver_driver.svh"
  `include  "pzvip_tilelink_e_agent.svh"

  `include  "pzvip_tilelink_data_monitor.svh"
  `include  "pzvip_tilelink_message_waiter.svh"
  `include  "pzvip_tilelink_master_sequencer.svh"
  `include  "pzvip_tilelink_slave_sequencer.svh"

  `include  "pzvip_tilelink_master_agent.svh"
  `include  "pzvip_tilelink_slave_agent.svh"

  `include  "pzvip_tilelink_master_sequence.svh"
  `include  "pzvip_tilelink_master_get_sequence.svh"
  `include  "pzvip_tilelink_master_put_sequence.svh"
  `include  "pzvip_tilelink_master_acquire_sequence.svh"
  `include  "pzvip_tilelink_master_release_sequence.svh"
  `include  "pzvip_tilelink_master_response_probe_sequence.svh"
  `include  "pzvip_tilelink_master_default_sequence.svh"

  `include  "pzvip_tilelink_slave_sequence.svh"
  `include  "pzvip_tilelink_slave_respond_get_put_sequence.svh"
  `include  "pzvip_tilelink_slave_respond_acquire_sequence.svh"
  `include  "pzvip_tilelink_slave_respond_release_sequence.svh"
  `include  "pzvip_tilelink_slave_probe_sequence.svh"
  `include  "pzvip_tilelink_slave_default_sequence.svh"
endpackage
`endif
