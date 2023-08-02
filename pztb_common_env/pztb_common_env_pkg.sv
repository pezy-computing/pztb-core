//========================================
//
// Copyright (c) 2023 PEZY Computing, K.K.
//                    All Rights Reserved.
//
//========================================
package pztb_common_env_pkg;
  import  uvm_pkg::*;
  import  tue_pkg::*;

  `include  "uvm_macros.svh"
  `include  "tue_macros.svh"

  typedef virtual pztb_clock  pztb_clock_vif;
  typedef virtual pztb_reset  pztb_reset_vif;

  `include  "pztb_common_env_macros.svh"
  `include  "pztb_common_env_context_base.svh"
  `include  "pztb_common_env_configuration_base.svh"
  `include  "pztb_common_env_status_base.svh"
  `include  "pztb_common_env_bfm_sequencer_base.svh"
  `include  "pztb_common_env_bfm_env_base.svh"
  `include  "pztb_common_env_sequencer_base.svh"
  `include  "pztb_common_env_base.svh"
  `include  "pztb_common_env_sequence_base.svh"
  `include  "pztb_common_env_test_base.svh"
endpackage
