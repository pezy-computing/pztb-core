//========================================
//
// Copyright (c) 2023 PEZY Computing, K.K.
//                    All Rights Reserved.
//
//========================================
`ifndef PZVIP_GPIO_IF_SV
`define PZVIP_GPIO_IF_SV

`include  "pzvip_gpio_macros.svh"

interface pzvip_gpio_if (
  input logic clk,
  input logic reset_n
);
  localparam  int WIDTH = `PZVIP_GPIO_MAX_WIDTH;

  logic [WIDTH-1:0] value_out;
  logic [WIDTH-1:0] value_in;
  logic [WIDTH-1:0] output_enable;

  logic [WIDTH-1:0] reset_value_out     = '0;
  logic [WIDTH-1:0] reset_output_enable = '0;

  clocking master_cb @(posedge clk);
    output  value_out;
    input   value_in;
    output  output_enable;
  endclocking

  clocking monitor_cb @(posedge clk);
    input value_out;
    input value_in;
    input output_enable;
  endclocking

  event at_clock_posedge;

  always @(monitor_cb) begin
    ->at_clock_posedge;
  end

  task automatic wait_for_clock_posedge();
    if (!at_clock_posedge.triggered) begin
      @(monitor_cb);
    end
  endtask

  task automatic wait_cycles(int cycles);
    repeat (cycles) begin
      @(monitor_cb);
    end
  endtask

  task automatic reset();
    value_out     = reset_value_out;
    output_enable = reset_output_enable;
  endtask
endinterface
`endif
