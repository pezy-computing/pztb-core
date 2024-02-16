//========================================
//
// Copyright (c) 2023 PEZY Computing, K.K.
//                    All Rights Reserved.
//
//========================================
module tb_pzcorebus_slave_bfm
  import  pzcorebus_pkg::*,
          pztb_pkg::*;
#(
  parameter pzcorebus_config  BUS_CONFIG              = '0,
  parameter longint           RAM_SIZE                = -1,
  parameter int               MAX_NON_POSTED_REQUESTS = 256,
  parameter int               RESPONSE_START_DELAY    = 100,
  parameter int               ADDRESS_WIDTH           = BUS_CONFIG.address_width,
  parameter pztb_mem_init     DEFAULT_VALUE           = PZTB_MEM_INIT_X,
  parameter bit               USE_VIP                 = 1,
  parameter int               ATOMIC_FLAG             = -1,
  parameter bit               WAIT_FOR_MDATA_LAST     = 0,
  parameter bit               SVA_CHECKER             = 1
)(
  input var           i_clk,
  input var           i_rst_n,
  pzcorebus_if.slave  slave_if
);
  localparam  bit PZ_UVM  = `ifdef  _PZ_UVM_  1
                            `else             0
                            `endif;

  pzcorebus_if #(BUS_CONFIG)  corebus_if();
  bit                         write_command_done;
  bit                         write_data_done;

  if (is_memory_profile(BUS_CONFIG) && WAIT_FOR_MDATA_LAST) begin
    always_ff @(posedge i_clk, negedge i_rst_n) begin
      if (!i_rst_n) begin
        write_command_done  <= '0;
        write_data_done     <= '0;
      end
      else begin
        if (slave_if.command_with_data_ack() && (!write_command_done)) begin
          if (!(write_data_done || slave_if.write_data_last_ack())) begin
            write_command_done  <= '1;
          end
        end
        else if (write_command_done && slave_if.write_data_last_ack()) begin
          write_command_done  <= '0;
        end

        if (slave_if.write_data_last_ack() && (!write_data_done)) begin
          if (!(write_command_done || slave_if.command_with_data_ack())) begin
            write_data_done <= '1;
          end
        end
        else if (slave_if.command_with_data_ack() && write_data_done) begin
          write_data_done <= '0;
        end
      end
    end
  end
  else begin
    always_comb begin
      write_command_done  = '0;
      write_data_done     = '0;
    end
  end

  always_comb begin
    slave_if.scmd_accept  = (!write_command_done) && corebus_if.scmd_accept;
    corebus_if.mcmd_valid = (!write_command_done) && slave_if.mcmd_valid;
    corebus_if.put_command(slave_if.get_command());

    slave_if.sdata_accept   = (!write_data_done) && corebus_if.sdata_accept;
    corebus_if.mdata_valid  = (!write_data_done) && slave_if.mdata_valid;
    corebus_if.put_write_data(slave_if.get_write_data());
  end

  always_comb begin
    corebus_if.mresp_accept = slave_if.mresp_accept;
    slave_if.sresp_valid    = corebus_if.sresp_valid;
    slave_if.put_response(corebus_if.get_response());
  end

  if (PZ_UVM && USE_VIP) begin : g
`ifdef _PZ_PZVIP_COREBUS_ENABLED_
    pzvip_corebus_if  vip_if (i_clk, i_rst_n);

    always @* begin
      if (!i_rst_n) begin
        vip_if.reset_slave();
      end

      corebus_if.scmd_accept  = vip_if.scmd_accept;
      vip_if.mcmd_valid       = corebus_if.mcmd_valid;
      vip_if.mcmd             = get_mcmd(corebus_if.mcmd, corebus_if.mid);
      vip_if.mid              = corebus_if.mid;
      vip_if.maddr            = corebus_if.maddr;
      vip_if.mlength          = corebus_if.mlength;
      vip_if.minfo            = corebus_if.minfo;
      corebus_if.sdata_accept = vip_if.sdata_accept;
      vip_if.mdata_valid      = corebus_if.mdata_valid;
      vip_if.mdata            = corebus_if.mdata;
      vip_if.mdata_byteen     = corebus_if.mdata_byteen;
      vip_if.mdata_last       = corebus_if.mdata_last;
      vip_if.mresp_accept     = corebus_if.mresp_accept;
      corebus_if.sresp_valid  = vip_if.sresp_valid;
      corebus_if.sresp        = pzcorebus_response_type'(vip_if.sresp);
      corebus_if.sid          = vip_if.sid;
      corebus_if.serror       = vip_if.serror;
      corebus_if.sdata        = vip_if.sdata;
      corebus_if.sinfo        = vip_if.sinfo;
      corebus_if.sresp_uniten = vip_if.sresp_uniten;
      corebus_if.sresp_last   = vip_if.sresp_last;
    end

    function automatic pzvip_corebus_types_pkg::pzvip_corebus_command_type get_mcmd(
      pzcorebus_command_type          mcmd,
      logic [BUS_CONFIG.id_width-1:0] mid
    );
      logic atomic_flag;
      int   flag_position;

      flag_position = ATOMIC_FLAG;
      atomic_flag   = (flag_position >= 0) ? mid[flag_position] : '0;

      if (atomic_flag && (mcmd == PZCOREBUS_WRITE)) begin
        return pzvip_corebus_types_pkg::PZVIP_COREBUS_ATOMIC_NON_POSTED;
      end
      else begin
        return pzvip_corebus_types_pkg::pzvip_corebus_command_type'(mcmd);
      end
    endfunction
`endif
  end
  else begin : g
    tb_pzcorebus_slave_ram_bfm #(
      .BUS_CONFIG     (BUS_CONFIG     ),
      .ADDRESS_WIDTH  (ADDRESS_WIDTH  ),
      .RAM_SIZE       (RAM_SIZE       )
    ) u_bfm (
      .i_clk    (i_clk      ),
      .i_rst_n  (i_rst_n    ),
      .slave_if (corebus_if )
    );
    initial begin
      u_bfm.set_max_non_posted_requests(MAX_NON_POSTED_REQUESTS);
      u_bfm.set_start_delay(RESPONSE_START_DELAY);
      u_bfm.set_default_value(DEFAULT_VALUE);
    end
  end

//--------------------------------------------------------------
//  SVA checker
//--------------------------------------------------------------
  if (PZCOREBUS_ENABLE_SVA_CHECKER) begin : g_sva
    pzcorebus_request_sva_checker #(
      .BUS_CONFIG   (BUS_CONFIG   ),
      .SVA_CHECKER  (SVA_CHECKER  )
    ) u_sva_checker (
      .i_clk    (i_clk    ),
      .i_rst_n  (i_rst_n  ),
      .bus_if   (slave_if )
    );
  end
endmodule
