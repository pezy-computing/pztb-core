//========================================
//
// Copyright (c) 2023 PEZY Computing, K.K.
//                    All Rights Reserved.
//
//========================================
interface pztb_clock;
  timeunit  1ns;

  bit       enable  = 0;
  realtime  period  = 0.0;
  bit       clk     = 0;
  bit       clk_p;
  bit       clk_n;

  assign  clk_p = clk;
  assign  clk_n = ~clk;

  function automatic void set_period(realtime period_ns);
    period  = period_ns / 2.0;
  endfunction

  function automatic void start(realtime period_ns);
    set_period(period_ns);
    enable  = 1;
  endfunction

  function automatic void stop();
    period  = 0.0;
    enable  = 0;
  endfunction

  task automatic sleep(int count);
    repeat(count) @(posedge clk);
  endtask

  always @(posedge enable) begin
    clk = 1;
    while (enable) #(period) begin
      clk = ~clk;
    end
    clk = 0;
  end
endinterface
