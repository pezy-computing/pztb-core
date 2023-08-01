//========================================
//
// Copyright (c) 2023 PEZY Computing, K.K.
//                    All Rights Reserved.
//
//========================================
`ifndef PZVIP_COMMON_PKG_SV
`define PZVIP_COMMON_PKG_SV

`ifdef _PZ_PZVIP_ENABLE_PA_WRITER_
  `ifndef ENABLE_VERDI_PA_WRITER
    `define ENABLE_VERDI_PA_WRITER
  `endif
  `include  "verdi_pa_writer.sv"
`endif

package pzvip_common_pkg;
  import  uvm_pkg::*;
  import  tue_pkg::*;

  `include  "uvm_macros.svh"
  `include  "tue_macros.svh"

  `include  "pzvip_common_item.svh"
  `include  "pzvip_delay_configuration.svh"
  `include  "pzvip_hdl_backdoor.svh"
  `include  "pzvip_pa_writer_base.svh"
  `include  "pzvip_memory.svh"
  `include  "pzvip_sequence_base.svh"
endpackage
`endif
