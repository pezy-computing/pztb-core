//========================================
//
// Copyright (c) 2023 PEZY Computing, K.K.
//
//========================================
module tb_pzcorebus_master_bfm
  import  `PZCOREBUS_COMMON_PKG::*;
#(
  parameter pzcorebus_config  BUS_CONFIG              = '0,
  parameter int               MASTERS                 = 1,
  parameter type              MCMD                    = logic,
  parameter type              MDATA                   = logic,
  parameter type              SRESP                   = logic,
  parameter int               LOCAL_ID_WIDTH          = BUS_CONFIG.id_width,
  parameter int               PORT_ID_WIDTH           = BUS_CONFIG.id_width - LOCAL_ID_WIDTH,
  parameter bit               USE_VIP                 = 1,
  parameter bit               USE_NON_POSTED_ID_LOCK  = 1,
  parameter int               ACTUAL_PORT_ID_WIDTH    = (PORT_ID_WIDTH > 0) ? PORT_ID_WIDTH : 1,
  parameter bit               SVA_CHECKER             = 1
)(
  input var                             i_clk,
  input var                             i_rst_n,
  input var [ACTUAL_PORT_ID_WIDTH-1:0]  i_port_id[MASTERS],
  interface.master                      master_if[MASTERS]
);
  localparam  bit PZ_UVM  = `ifdef  _PZ_UVM_  1
                            `else             0
                            `endif;

`ifdef _PZ_PZVIP_COREBUS_ENABLED_
  pzvip_corebus_pkg::pzvip_corebus_vif  vip_vif[MASTERS];

  function automatic pzvip_corebus_pkg::pzvip_corebus_vif get_vip_vif(int index);
    return vip_vif[index];
  endfunction
`endif

  for (genvar i = 0;i < MASTERS;++i) begin : g
    bit [BUS_CONFIG.id_width-1:0] id_base;
    bit [BUS_CONFIG.id_width-1:0] id_mask;

    always_comb begin
      if (BUS_CONFIG.id_width == LOCAL_ID_WIDTH) begin
        id_base = '0;
        id_mask = '1;
      end
      else begin
        id_base = {i_port_id[i], LOCAL_ID_WIDTH'(0)};
        id_mask = (1 << LOCAL_ID_WIDTH) - 1;
      end
    end

    if (PZ_UVM && USE_VIP) begin : g
`ifdef _PZ_PZVIP_COREBUS_ENABLED_
      pzvip_corebus_if  vip_if(i_clk, i_rst_n);

      always @* begin
        if (!i_rst_n) begin
          vip_if.reset_master();
        end

        vip_if.scmd_accept        = master_if[i].scmd_accept;
        master_if[i].mcmd_valid   = vip_if.mcmd_valid;
        master_if[i].mcmd         = pzcorebus_mcmd'(vip_if.mcmd);
        master_if[i].mid          = id_base | vip_if.mid;
        master_if[i].maddr        = vip_if.maddr;
        master_if[i].mlength      = vip_if.mlength;
        master_if[i].mparam       = vip_if.mparam;
        master_if[i].minfo        = vip_if.minfo;
        vip_if.sdata_accept       = master_if[i].sdata_accept;
        master_if[i].mdata_valid  = vip_if.mdata_valid;
        master_if[i].mdata        = vip_if.mdata;
        master_if[i].mdata_byteen = vip_if.mdata_byteen;
        master_if[i].mdata_last   = vip_if.mdata_last;
        master_if[i].mresp_accept = vip_if.mresp_accept;
        vip_if.sresp_valid        = master_if[i].sresp_valid;
        vip_if.sresp              = pzvip_corebus_types_pkg::pzvip_corebus_response_type'(master_if[i].sresp);
        vip_if.sid                = master_if[i].sid & id_mask;
        vip_if.serror             = master_if[i].serror;
        vip_if.sdata              = master_if[i].sdata;
        vip_if.sinfo              = master_if[i].sinfo;
        vip_if.sresp_uniten       = master_if[i].sresp_uniten;
        vip_if.sresp_last         = master_if[i].sresp_last;
      end

      initial begin
        vip_vif[i]  = vip_if;
      end
`endif
    end
    else begin : g
      tb_pzcrebus_master_bfm_task #(
        .BUS_CONFIG             (BUS_CONFIG             ),
        .MCMD                   (MCMD                   ),
        .MDATA                  (MDATA                  ),
        .SRESP                  (SRESP                  ),
        .USE_NON_POSTED_ID_LOCK (USE_NON_POSTED_ID_LOCK )
      ) u_bfm (
        .i_clk          (i_clk                      ),
        .i_rst_n        (i_rst_n                    ),
        .i_id_base      (id_base                    ),
        .i_id_mask      (id_mask                    ),
        .i_scmd_accept  (master_if[i].scmd_accept   ),
        .o_mcmd_valid   (master_if[i].mcmd_valid    ),
        .o_mcmd         (mcmd                       ),
        .i_sdata_accept (master_if[i].sdata_accept  ),
        .o_mdata_valid  (master_if[i].mdata_valid   ),
        .o_mdata        (mdata                      ),
        .o_mresp_accept (master_if[i].mresp_accept  ),
        .i_sresp_valid  (master_if[i].sresp_valid   ),
        .i_sresp        (sresp                      )
      );
    end
  end

//--------------------------------------------------------------
//  SVA checker
//--------------------------------------------------------------
//  if (PZCOREBUS_ENABLE_SVA_CHECKER) begin : g_sva
//    pzcorebus_response_sva_checker #(
//      .BUS_CONFIG     (BUS_CONFIG   ),
//      .SVA_CHECKER    (SVA_CHECKER  ),
//      .SRESP_IF_ONLY  (0            )
//    ) u_sva_checker (
//      .i_clk    (i_clk      ),
//      .i_rst_n  (i_rst_n    ),
//      .bus_if   (master_if  )
//    );
//  end
endmodule
