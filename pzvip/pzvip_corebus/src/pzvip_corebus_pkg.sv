//========================================
//
// Copyright (c) 2023 PEZY Computing, K.K.
//                    All Rights Reserved.
//
//========================================
`ifndef PZVIP_COREBUS_PKG_SV
`define PZVIP_COREBUS_PKG_SV
package pzvip_corebus_pkg;
  import  uvm_pkg::*;
  import  tue_pkg::*;
  import  pzvip_common_pkg::*;
  import  pzvip_corebus_types_pkg::*;

  `include  "uvm_macros.svh"
  `include  "tue_macros.svh"
  `include  "pzvip_common_macros.svh"

  typedef virtual pzvip_corebus_if  pzvip_corebus_vif;

  localparam  int PZVIP_COREBUS_MAX_ACCEPTABLE_REQUESTS =
    `ifdef  PZVIP_COREBUS_MAX_ACCEPTABLE_REQUESTS `PZVIP_COREBUS_MAX_ACCEPTABLE_REQUESTS
    `else                                         512
    `endif;

  `include  "pzvip_corebus_internal_macros.svh"
  `include  "pzvip_corebus_configuration.svh"
  `include  "pzvip_corebus_status.svh"
  `include  "pzvip_corebus_memory.svh"
  `include  "pzvip_corebus_access_count.svh"
  `include  "pzvip_corebus_utils.svh"
  `include  "pzvip_corebus_item.svh"
  `include  "pzvip_corebus_payload_storage.svh"
  `include  "pzvip_corebus_access_count_monitor.svh"
  `include  "pzvip_corebus_component_base.svh"
  `include  "pzvip_corebus_pa_writer.svh"
  `include  "pzvip_corebus_monitor_base.svh"
  `include  "pzvip_corebus_sequencer_base.svh"
  `include  "pzvip_corebus_agent_base.svh"
  `include  "pzvip_corebus_sequence_base.svh"
  `include  "pzvip_corebus_master_monitor.svh"
  `include  "pzvip_corebus_master_sequencer.svh"
  `include  "pzvip_corebus_master_driver.svh"
  `include  "pzvip_corebus_master_agent.svh"
  `include  "pzvip_corebus_master_sequence.svh"
  `include  "pzvip_corebus_master_access_sequence.svh"
  `include  "pzvip_corebus_slave_monitor.svh"
  `include  "pzvip_corebus_slave_sequencer.svh"
  `include  "pzvip_corebus_slave_driver.svh"
  `include  "pzvip_corebus_slave_data_monitor.svh"
  `include  "pzvip_corebus_slave_agent.svh"
  `include  "pzvip_corebus_slave_sequence.svh"
  `include  "pzvip_corebus_slave_default_sequence.svh"
  `include  "pzvip_corebus_slave_get_request_sequence.svh"
  `include  "pzvip_corebus_slave_backdoor_put_sequence.svh"
  `include  "pzvip_corebus_slave_backdoor_get_sequence.svh"
  `include  "pzvip_corebus_ral_adapter.svh"
  `include  "pzvip_corebus_ral_predictor.svh"
endpackage
`endif
