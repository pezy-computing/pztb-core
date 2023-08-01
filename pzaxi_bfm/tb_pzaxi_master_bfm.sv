//========================================
//
// Copyright (c) 2023 PEZY Computing, K.K.
//                    All Rights Reserved.
//
//========================================
module tb_pzaxi_master_bfm
  import  pzaxi_pkg::*;
#(
  parameter pzaxi_config  BUS_CONFIG            = '0,
  parameter int           LOCAL_ID_WIDTH        = BUS_CONFIG.id_width,
  parameter int           PORT_ID_WIDTH         = BUS_CONFIG.id_width - LOCAL_ID_WIDTH,
  parameter bit           USE_VIP               = 1,
  parameter int           ACTUAL_PORT_ID_WIDTH  = (PORT_ID_WIDTH > 0) ? PORT_ID_WIDTH : 1
)(
  input var                             i_clk,
  input var                             i_rst_n,
  input var [ACTUAL_PORT_ID_WIDTH-1:0]  i_port_id,
  pzaxi_if.master                       master_if
);
  localparam  bit PZ_UVM  = `ifdef  _PZ_UVM_  1
                            `else             0
                            `endif;

  bit [BUS_CONFIG.id_width-1:0] id_base;
  bit [BUS_CONFIG.id_width-1:0] id_mask;

  always_comb begin
    if (BUS_CONFIG.id_width == LOCAL_ID_WIDTH) begin
      id_base = '0;
      id_mask = '1;
    end
    else begin
      id_base = {i_port_id, {LOCAL_ID_WIDTH{1'b0}}};
      id_mask = {LOCAL_ID_WIDTH{1'b1}};
    end
  end

  if (PZ_UVM && USE_VIP) begin : g
`ifdef _PZ_UVM_
    tvip_axi_if vip_if(i_clk, i_rst_n);

    always @* begin
      vip_if.awready    = master_if.awready;
      master_if.awvalid = vip_if.awvalid;
      master_if.awid    = id_base | vip_if.awid;
      master_if.awaddr  = vip_if.awaddr;
      master_if.awlen   = vip_if.awlen;
      master_if.awsize  = vip_if.awsize;
      master_if.awburst = vip_if.awburst;
      master_if.awcache = vip_if.awcache;
      master_if.awprot  = '0;
      master_if.awlock  = '0;
      master_if.awqos   = vip_if.awqos;
      master_if.awuser  = '0;
    end

    always @* begin
      vip_if.wready     = master_if.wready;
      master_if.wvalid  = vip_if.wvalid;
      master_if.wdata   = vip_if.wdata;
      master_if.wstrb   = vip_if.wstrb;
      master_if.wlast   = vip_if.wlast;
      master_if.wuser   = '0;
    end

    always @* begin
      master_if.bready  = vip_if.bready;
      vip_if.bvalid     = master_if.bvalid;
      vip_if.bid        = master_if.bid & id_mask;
      vip_if.bresp      = tvip_axi_types_pkg::tvip_axi_response'(master_if.bresp);
    end

    always @* begin
      vip_if.arready    = master_if.arready;
      master_if.arvalid = vip_if.arvalid;
      master_if.arid    = id_base | vip_if.arid;
      master_if.araddr  = vip_if.araddr;
      master_if.arlen   = vip_if.arlen;
      master_if.arsize  = vip_if.arsize;
      master_if.arburst = vip_if.arburst;
      master_if.arcache = vip_if.arcache;
      master_if.arprot  = '0;
      master_if.arlock  = '0;
      master_if.arqos   = vip_if.arqos;
      master_if.aruser  = '0;
    end

    always @* begin
      master_if.rready  = vip_if.rready;
      vip_if.rvalid     = master_if.rvalid;
      vip_if.rid        = master_if.rid & id_mask;
      vip_if.rdata      = master_if.rdata;
      vip_if.rresp      = tvip_axi_types_pkg::tvip_axi_response'(master_if.rresp);
      vip_if.rlast      = master_if.rlast;
    end
`endif
  end
  else begin : g
    initial begin
      $fatal("non-vip mode is not supported yet");
    end
  end
endmodule
