//========================================
//
// Copyright (c) 2023 PEZY Computing, K.K.
//                    All Rights Reserved.
//
//========================================
module tb_pzaxi_slave_bfm
  import  pzaxi_pkg::*;
#(
  parameter pzaxi_config  BUS_CONFIG  = '0,
  parameter bit           USE_VIP     = 1
)(
  input var       i_clk,
  input var       i_rst_n,
  pzaxi_if.slave  slave_if
);
  localparam  bit PZ_UVM  = `ifdef  _PZ_UVM_  1
                            `else             0
                            `endif;

  if (PZ_UVM && USE_VIP) begin : g
`ifdef _PZ_UVM_
    tvip_axi_if vip_if (i_clk, i_rst_n);

    always @* begin
      slave_if.awready  = vip_if.awready;
      vip_if.awvalid    = slave_if.awvalid;
      vip_if.awid       = slave_if.awid;
      vip_if.awaddr     = slave_if.awaddr;
      vip_if.awlen      = slave_if.awlen;
      vip_if.awsize     = tvip_axi_types_pkg::tvip_axi_burst_size'(slave_if.awsize);
      vip_if.awburst    = tvip_axi_types_pkg::tvip_axi_burst_type'(slave_if.awburst);
      vip_if.awcache    = slave_if.awcache;
      vip_if.awprot     = slave_if.awprot;
      vip_if.awqos      = slave_if.awqos;
    end

    always @* begin
      slave_if.wready = vip_if.wready;
      vip_if.wvalid   = slave_if.wvalid;
      vip_if.wdata    = slave_if.wdata;
      vip_if.wstrb    = slave_if.wstrb;
      vip_if.wlast    = slave_if.wlast;
    end

    always @* begin
      vip_if.bready   = slave_if.bready;
      slave_if.bvalid = vip_if.bvalid;
      slave_if.bid    = vip_if.bid;
      slave_if.bresp  = vip_if.bresp;
      slave_if.buser  = '0;
    end

    always @* begin
      slave_if.arready  = vip_if.arready;
      vip_if.arvalid    = slave_if.arvalid;
      vip_if.arid       = slave_if.arid;
      vip_if.araddr     = slave_if.araddr;
      vip_if.arlen      = slave_if.arlen;
      vip_if.arsize     = tvip_axi_types_pkg::tvip_axi_burst_size'(slave_if.arsize);
      vip_if.arburst    = tvip_axi_types_pkg::tvip_axi_burst_type'(slave_if.arburst);
      vip_if.arcache    = slave_if.arcache;
      vip_if.arprot     = slave_if.arprot;
      vip_if.arqos      = slave_if.arqos;
    end

    always @* begin
      vip_if.rready   = slave_if.rready;
      slave_if.rvalid = vip_if.rvalid;
      slave_if.rid    = vip_if.rid;
      slave_if.rresp  = vip_if.rresp;
      slave_if.rdata  = vip_if.rdata;
      slave_if.rlast  = vip_if.rlast;
      slave_if.ruser  = '0;
    end
`endif
  end
  else begin : g
    initial begin
      $fatal("non vip mode is not supported yet");
    end
  end
endmodule
