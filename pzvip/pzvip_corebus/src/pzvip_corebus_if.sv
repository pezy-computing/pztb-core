//========================================
//
// Copyright (c) 2023 PEZY Computing, K.K.
//                    All Rights Reserved.
//
//========================================
`ifndef PZVIP_COREBUS_IF_SV
`define PZVIP_COREBUS_IF_SV
interface pzvip_corebus_if (
  input var bit i_clk,
  input var bit i_rst_n
);
  import  pzvip_corebus_types_pkg::*;

  bit                           mcmd_valid;
  bit                           scmd_accept;
  pzvip_corebus_command_type    mcmd;
  pzvip_corebus_id              mid;
  pzvip_corebus_address         maddr;
  pzvip_corebus_length          mlength;
  pzvip_corebus_request_param   mparam;
  pzvip_corebus_request_info    minfo;
  bit                           mdata_valid;
  bit                           sdata_accept;
  pzvip_corebus_data            mdata;
  pzvip_corebus_byte_enable     mdata_byteen;
  bit                           mdata_last;
  bit                           sresp_valid;
  bit                           mresp_accept;
  pzvip_corebus_response_type   sresp;
  pzvip_corebus_id              sid;
  bit                           serror;
  pzvip_corebus_data            sdata;
  pzvip_corebus_response_info   sinfo;
  pzvip_corebus_unit_enable     sresp_uniten;
  pzvip_corebus_response_last   sresp_last;
  bit                           reset_n;

  bit default_command_valid   = 0;
  bit default_command_accept  = 1;
  bit default_data_valid      = 0;
  bit default_data_accept     = 1;
  bit default_response_valid  = 0;
  bit default_response_accept = 1;

  always_comb begin
    reset_n = i_rst_n;
  end

  clocking master_cb @(posedge i_clk, negedge i_rst_n);
    output  mcmd_valid;
    input   scmd_accept;
    output  mcmd;
    output  mid;
    output  maddr;
    output  mlength;
    output  mparam;
    output  minfo;
    output  mdata_valid;
    input   sdata_accept;
    output  mdata;
    output  mdata_byteen;
    output  mdata_last;
    input   sresp_valid;
    inout   mresp_accept;
    input   sresp;
    input   sid;
    input   serror;
    input   sdata;
    input   sinfo;
    input   sresp_uniten;
    input   sresp_last;
  endclocking

  clocking slave_cb @(posedge i_clk, negedge i_rst_n);
    input   mcmd_valid;
    inout   scmd_accept;
    input   mcmd;
    input   mid;
    input   maddr;
    input   mlength;
    input   mparam;
    input   minfo;
    input   mdata_valid;
    inout   sdata_accept;
    input   mdata;
    input   mdata_byteen;
    input   mdata_last;
    output  sresp_valid;
    input   mresp_accept;
    output  sresp;
    output  sid;
    output  serror;
    output  sdata;
    output  sinfo;
    output  sresp_uniten;
    output  sresp_last;
  endclocking

  clocking monitor_cb @(posedge i_clk);
    input mcmd_valid;
    input scmd_accept;
    input mcmd;
    input mid;
    input maddr;
    input mlength;
    input mparam;
    input minfo;
    input mdata_valid;
    input sdata_accept;
    input mdata;
    input mdata_byteen;
    input mdata_last;
    input sresp_valid;
    input mresp_accept;
    input sresp;
    input sid;
    input serror;
    input sdata;
    input sinfo;
    input sresp_uniten;
    input sresp_last;
    input reset_n;
  endclocking

  function automatic void reset_master();
    master_cb.mcmd_valid    <= default_command_valid;
    master_cb.mdata_valid   <= default_data_valid;
    master_cb.mresp_accept  <= default_response_accept;
  endfunction

  function automatic void reset_slave();
    slave_cb.scmd_accept  <= default_command_accept;
    slave_cb.sdata_accept <= default_data_accept;
    slave_cb.sresp_valid  <= default_response_valid;
  endfunction

  function automatic string get_hdl_path();
    string  path;
    string  function_name;
    path          = $sformatf("%m");
    function_name = ".get_hdl_path";
    return path.substr(0, path.len() - function_name.len() - 1);
  endfunction

  event at_master_cb;
  event at_slave_cb;
  event at_monitor_cb;

  always @(master_cb) begin
    ->at_master_cb;
  end

  always @(slave_cb) begin
    ->at_slave_cb;
  end

  always @(monitor_cb) begin
    ->at_monitor_cb;
  end
endinterface
`endif
