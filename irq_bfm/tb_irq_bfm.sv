//========================================
//
// Copyright (c) 2023 PEZY Computing, K.K.
//                    All Rights Reserved.
//
//========================================
interface tb_irq_bfm #(
  parameter bit MASTER  = 0,
  parameter int WIDTH   = 1,
  parameter bit USE_VIP = 1
)(
  input var i_clk,
  input var i_rst_n
);
  logic [WIDTH-1:0] irq;

  localparam  bit PZ_UVM  = `ifdef _PZ_UVM_ 1 `else 0 `endif;

  if (PZ_UVM && USE_VIP) begin : g
`ifdef _PZ_PZVIP_GPIO_ENABLED_
    pzvip_gpio_if vip_if (i_clk, i_rst_n);

    always_comb begin
      vip_if.value_in = irq;
    end

    if (MASTER) begin : g
      always begin
        vip_if.reset();
        @(negedge i_rst_n);
      end

      always_comb begin
        irq = vip_if.value_out;
      end
    end
`endif
  end
  else begin : g

  end
endinterface
