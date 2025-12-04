//========================================
//
// Copyright (c) 2023 PEZY Computing, K.K.
//
//========================================
module tb_pzcorebus_slave_bfm
  import  `PZCOREBUS_COMMON_PKG::*,
          pztb_pkg::*;
#(
  parameter pzcorebus_config  BUS_CONFIG              = '0,
  parameter int               SLAVES                  = 1,
  parameter type              MCMD                    = logic,
  parameter type              MDATA                   = logic,
  parameter type              SRESP                   = logic,
  parameter longint           RAM_SIZE                = -1,
  parameter int               MAX_NON_POSTED_REQUESTS = 256,
  parameter int               RESPONSE_START_DELAY    = 100,
  parameter int               ADDRESS_WIDTH           = BUS_CONFIG.address_width,
  parameter pztb_mem_init     DEFAULT_VALUE           = PZTB_MEM_INIT_X,
  parameter bit               USE_VIP                 = 1,
  parameter bit               WAIT_FOR_MDATA_LAST     = 0,
  parameter bit               SVA_CHECKER             = 1
)(
  input var       i_clk,
  input var       i_rst_n,
  interface.slave slave_if[SLAVES]
);
  localparam  bit PZ_UVM  = `ifdef  _PZ_UVM_  1
                            `else             0
                            `endif;

`ifdef _PZ_PZVIP_COREBUS_ENABLED_
  pzvip_corebus_pkg::pzvip_corebus_vif  vip_vif[SLAVES];

  function automatic pzvip_corebus_pkg::pzvip_corebus_vif get_vip_vif(int index);
    return vip_vif[index];
  endfunction
`endif

  for (genvar i = 0;i < SLAVES;++i) begin : g
    logic scmd_accept;
    logic mcmd_valid;
    MCMD  mcmd;
    bit   mcmd_done;
    logic sdata_accept;
    logic mdata_valid;
    MDATA mdata;
    bit   mdata_done;
    logic mresp_accept;
    logic sresp_valid;
    SRESP sresp;

    if (WAIT_FOR_MDATA_LAST && is_mem_profile(BUS_CONFIG)) begin : g_wait_for_mdata_last
      logic mcmd_ack;
      logic mdata_ack;

      always_comb begin
        mcmd_ack  = slave_if[i].mcmd_with_data_ack();
        mdata_ack = slave_if[i].mdata_last_ack();
      end

      always_ff @(posedge i_clk, negedge i_rst_n) begin
        if (!i_rst_n) begin
          mcmd_done   <= '0;
          mdata_done  <= '0;
        end
        else if (mcmd_ack || mdata_ack) begin
          if (mcmd_ack && (!mcmd_done)) begin
            if (!(mdata_done || mdata_ack)) begin
              mcmd_done <= '1;
            end
          end
          else if (mcmd_done && mdata_ack) begin
            mcmd_done <= '0;
          end

          if (mdata_ack && (!mdata_done)) begin
            if (!(mcmd_done || mcmd_ack)) begin
              mdata_done  <= '1;
            end
          end
          else if (mdata_done && mcmd_ack) begin
            mdata_done  <= '0;
          end
        end
      end
    end
    else begin : g_wait_for_mdata_last
      always_comb begin
        mcmd_done   = '0;
        mdata_done  = '0;
      end
    end

    always_comb begin
      if (!mcmd_done) begin
        slave_if[i].scmd_accept = scmd_accept;
        mcmd_valid              = slave_if[i].mcmd_valid;
      end
      else begin
        slave_if[i].scmd_accept = '0;
        mcmd_valid              = '0;
      end
      mcmd  = slave_if[i].get_mcmd();

      if (!mdata_done) begin
        slave_if[i].sdata_accept  = sdata_accept;
        mdata_valid               = slave_if[i].mdata_valid;
      end
      else begin
        slave_if[i].sdata_accept  = '0;
        mdata_valid               = '0;
      end
      mdata = slave_if[i].get_mdata();
    end

    always_comb begin
      mresp_accept            = slave_if[i].mresp_accept;
      slave_if[i].sresp_valid = sresp_valid;
      slave_if[i].put_sresp(sresp);
    end

    if (PZ_UVM && USE_VIP) begin : g
  `ifdef _PZ_PZVIP_COREBUS_ENABLED_
      pzvip_corebus_if  vip_if (i_clk, i_rst_n);

      always @* begin
        if (!i_rst_n) begin
          vip_if.reset_slave();
        end

        scmd_accept         = vip_if.scmd_accept;
        vip_if.mcmd_valid   = mcmd_valid;
        vip_if.mcmd         = pzvip_corebus_types_pkg::pzvip_corebus_command_type'(mcmd.mcmd);
        vip_if.mid          = mcmd.mid;
        vip_if.maddr        = mcmd.maddr;
        vip_if.mlength      = mcmd.mlength;
        vip_if.mparam       = mcmd.mparam;
        vip_if.minfo        = mcmd.minfo;
        if (is_mem_profile(BUS_CONFIG)) begin
          sdata_accept        = vip_if.sdata_accept;
          vip_if.mdata_valid  = mdata_valid;
          vip_if.mdata        = mdata.mdata;
          vip_if.mdata_byteen = mdata.mdata_byteen;
          vip_if.mdata_last   = mdata.mdata_last;
        end
        else begin
          sdata_accept        = '0;
          vip_if.mdata_valid  = '0;
          vip_if.mdata        = mcmd.mdata;
          vip_if.mdata_byteen = mcmd.mdata_byteen;
          vip_if.mdata_last   = '1;
        end

        vip_if.mresp_accept = mresp_accept;
        sresp_valid         = vip_if.sresp_valid;
        sresp.sresp         = pzcorebus_sresp'(vip_if.sresp);
        sresp.sid           = vip_if.sid;
        sresp.serror        = vip_if.serror;
        sresp.sdata         = vip_if.sdata;
        sresp.sinfo         = vip_if.sinfo;
        sresp.sresp_uniten  = vip_if.sresp_uniten;
        sresp.sresp_last    = vip_if.sresp_last;
      end

      initial begin
        vip_vif[i]  = vip_if;
      end
  `endif
    end
    else begin : g
      tb_pzcorebus_slave_ram_bfm #(
        .BUS_CONFIG     (BUS_CONFIG     ),
        .MCMD           (MCMD           ),
        .MDATA          (MDATA          ),
        .SRESP          (SRESP          ),
        .ADDRESS_WIDTH  (ADDRESS_WIDTH  ),
        .RAM_SIZE       (RAM_SIZE       )
      ) u_bfm (
        .i_clk          (i_clk        ),
        .i_rst_n        (i_rst_n      ),
        .o_scmd_accept  (scmd_accept  ),
        .i_mcmd_valid   (mcmd_valid   ),
        .i_mcmd         (mcmd         ),
        .o_sdata_accept (sdata_accept ),
        .i_mdata_valid  (mdata_valid  ),
        .i_mdata        (mdata        ),
        .i_mresp_accept (mresp_accept ),
        .o_sresp_valid  (sresp_valid  ),
        .o_sresp        (sresp        )
      );
      initial begin
        u_bfm.set_max_non_posted_requests(MAX_NON_POSTED_REQUESTS);
        u_bfm.set_start_delay(RESPONSE_START_DELAY);
        u_bfm.set_default_value(DEFAULT_VALUE);
      end
    end
  end

//--------------------------------------------------------------
//  SVA checker
//--------------------------------------------------------------
//  if (PZCOREBUS_ENABLE_SVA_CHECKER) begin : g_sva
//    pzcorebus_request_sva_checker #(
//      .BUS_CONFIG   (BUS_CONFIG   ),
//      .SVA_CHECKER  (SVA_CHECKER  )
//    ) u_sva_checker (
//      .i_clk    (i_clk    ),
//      .i_rst_n  (i_rst_n  ),
//      .bus_if   (slave_if )
//    );
//  end
endmodule
