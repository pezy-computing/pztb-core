//========================================
//
// Copyright (c) 2023 PEZY Computing, K.K.
//                    All Rights Reserved.
//
//========================================
interface pztb_reset;
  timeunit  1ns;

  bit rst = 1;
  bit rst_n;

  assign  rst_n = ~rst;

  function automatic void assert_reset();
    rst = 1;
  endfunction

  function automatic void deassert_reset();
    rst = 0;
  endfunction

  task automatic initiate(realtime duration_ns);
    assert_reset();
    #(duration_ns);
    deassert_reset();
  endtask
endinterface
