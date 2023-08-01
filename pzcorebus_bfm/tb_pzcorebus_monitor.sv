//========================================
//
// Copyright (c) 2023 PEZY Computing, K.K.
//                    All Rights Reserved.
//
//========================================
module tb_pzcorebus_monitor
  import  pzcorebus_pkg::*;
#(
  parameter pzcorebus_config  BUS_CONFIG  = '0,
  parameter bit               USE_VIP     = 1
)(
  input var             i_clk,
  input var             i_rst_n,
  pzcorebus_if.monitor  monitor_if
);
  localparam  bit PZ_UVM  =
    `ifdef  _PZ_UVM_  1
    `else             0
    `endif;

  if (PZ_UVM && USE_VIP) begin : g
`ifdef _PZ_PZVIP_COREBUS_ENABLED_
    pzvip_corebus_if  vip_if(i_clk, i_rst_n);

    always @* begin
      vip_if.scmd_accept  = monitor_if.scmd_accept;
      vip_if.mcmd_valid   = monitor_if.mcmd_valid;
      vip_if.mcmd         = pzvip_corebus_types_pkg::pzvip_corebus_command_type'(monitor_if.mcmd);
      vip_if.mid          = monitor_if.mid;
      vip_if.maddr        = monitor_if.maddr;
      vip_if.mlength      = monitor_if.mlength;
      vip_if.minfo        = monitor_if.minfo;
      vip_if.sdata_accept = monitor_if.sdata_accept;
      vip_if.mdata_valid  = monitor_if.mdata_valid;
      vip_if.mdata        = monitor_if.mdata;
      vip_if.mdata_byteen = monitor_if.mdata_byteen;
      vip_if.mdata_last   = monitor_if.mdata_last;
    end

    always @* begin
      vip_if.mresp_accept = monitor_if.mresp_accept;
      vip_if.sresp_valid  = monitor_if.sresp_valid;
      vip_if.sresp        = pzvip_corebus_types_pkg::pzvip_corebus_response_type'(monitor_if.sresp);
      vip_if.sid          = monitor_if.sid;
      vip_if.serror       = monitor_if.serror;
      vip_if.sdata        = monitor_if.sdata;
      vip_if.sinfo        = monitor_if.sinfo;
      vip_if.sresp_uniten = monitor_if.sresp_uniten;
      vip_if.sresp_last   = monitor_if.sresp_last;
    end
`endif
  end
endmodule
