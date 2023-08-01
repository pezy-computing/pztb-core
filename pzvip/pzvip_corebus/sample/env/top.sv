module top;
  timeunit  1ns/1ps;

  import  uvm_pkg::*;
  import  tue_pkg::*;
  import  pzvip_common_pkg::*;
  import  pzvip_corebus_types_pkg::*;
  import  pzvip_corebus_pkg::*;
  import  pzvip_corebus_sample_pkg::*;

  bit clk = 1;
  always #(500ps) begin
    clk = ~clk;
  end

  bit rst_n = 0;
  initial begin
    repeat (10) @(posedge clk);
    rst_n = 1;
  end

  pzvip_corebus_if corebus_if (clk, rst_n);
  initial begin
    uvm_config_db #(pzvip_corebus_vif)::set(null, "", "vif", corebus_if);
    run_test("pzvip_corebus_sample_test");
  end
endmodule
