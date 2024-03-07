//========================================
//
// Copyright (c) 2023 PEZY Computing, K.K.
//                    All Rights Reserved.
//
//========================================
module tb_pzcorebus_master_bfm
  import  pzcorebus_pkg::*;
#(
  parameter pzcorebus_config  BUS_CONFIG              = '0,
  parameter int               LOCAL_ID_WIDTH          = BUS_CONFIG.id_width,
  parameter int               PORT_ID_WIDTH           = BUS_CONFIG.id_width - LOCAL_ID_WIDTH,
  parameter bit               USE_VIP                 = 1,
  parameter bit               USE_NON_POSTED_ID_LOCK  = 1,
  parameter int               ACTUAL_PORT_ID_WIDTH    = (PORT_ID_WIDTH > 0) ? PORT_ID_WIDTH : 1,
  parameter bit               SVA_CHECKER             = 1
)(
  input var                             i_clk,
  input var                             i_rst_n,
  input var [ACTUAL_PORT_ID_WIDTH-1:0]  i_port_id,
  pzcorebus_if.master                   master_if
);
  typedef logic [BUS_CONFIG.id_width-1:0] pzcorebus_id;

  bit [BUS_CONFIG.id_width-1:0] id_base;
  bit [BUS_CONFIG.id_width-1:0] id_mask;

  always_comb begin
    if (BUS_CONFIG.id_width == LOCAL_ID_WIDTH) begin
      id_base = '0;
      id_mask = '1;
    end
    else begin
      id_base = {i_port_id, LOCAL_ID_WIDTH'(0)};
      id_mask = (1 << LOCAL_ID_WIDTH) - 1;
    end
  end

  localparam  bit PZ_UVM  = `ifdef  _PZ_UVM_  1
                            `else             0
                            `endif;

  if (PZ_UVM && USE_VIP) begin : g
`ifdef _PZ_PZVIP_COREBUS_ENABLED_
    pzvip_corebus_if  vip_if(i_clk, i_rst_n);

    always @* begin
      if (!i_rst_n) begin
        vip_if.reset_master();
      end

      vip_if.scmd_accept      = master_if.scmd_accept;
      master_if.mcmd_valid    = vip_if.mcmd_valid;
      master_if.mcmd          = pzcorebus_command_type'(vip_if.mcmd);
      master_if.mid           = id_base | vip_if.mid;
      master_if.maddr         = vip_if.maddr;
      master_if.mlength       = vip_if.mlength;
      master_if.mparam        = vip_if.mparam;
      master_if.minfo         = vip_if.minfo;
      vip_if.sdata_accept     = master_if.sdata_accept;
      master_if.mdata_valid   = vip_if.mdata_valid;
      master_if.mdata         = vip_if.mdata;
      master_if.mdata_byteen  = vip_if.mdata_byteen;
      master_if.mdata_last    = vip_if.mdata_last;
      master_if.mresp_accept  = vip_if.mresp_accept;
      vip_if.sresp_valid      = master_if.sresp_valid;
      vip_if.sresp            = pzvip_corebus_types_pkg::pzvip_corebus_response_type'(master_if.sresp);
      vip_if.sid              = master_if.sid & id_mask;
      vip_if.serror           = master_if.serror;
      vip_if.sdata            = master_if.sdata;
      vip_if.sinfo            = master_if.sinfo;
      vip_if.sresp_uniten     = master_if.sresp_uniten;
      vip_if.sresp_last       = master_if.sresp_last;
    end
`endif
  end
  else begin : g
    tb_pzcrebus_master_bfm_task #(
      .BUS_CONFIG             (BUS_CONFIG             ),
      .USE_NON_POSTED_ID_LOCK (USE_NON_POSTED_ID_LOCK )
    ) u_bfm (
      .i_clk      (i_clk      ),
      .i_rst_n    (i_rst_n    ),
      .i_id_base  (id_base    ),
      .i_id_mask  (id_mask    ),
      .master_if  (master_if  )
    );
  end

//--------------------------------------------------------------
//  SVA checker
//--------------------------------------------------------------
  if (PZCOREBUS_ENABLE_SVA_CHECKER) begin : g_sva
    pzcorebus_response_sva_checker #(
      .BUS_CONFIG   (BUS_CONFIG   ),
      .SVA_CHECKER  (SVA_CHECKER  )
    ) u_sva_checker (
      .i_clk    (i_clk      ),
      .i_rst_n  (i_rst_n    ),
      .bus_if   (master_if  )
    );
  end
endmodule
