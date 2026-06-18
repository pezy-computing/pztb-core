//========================================
//
// Copyright (c) 2026 PEZY Computing, K.K.
//                    All Rights Reserved.
//
//========================================
module pzvip_i2c_wrapper #(
  parameter int N_VIP = 1
)(
  input   var logic i_scl,
  output  var logic o_scl,
  input   var logic i_sda,
  output  var logic o_sda
);
  wire  i2c_scl;
  wire  i2c_sda;

  pullup u_pullup_scl (i2c_scl);
  pullup u_pullup_sda (i2c_sda);

  virtual pzvip_i2c_if  vip_vif[N_VIP];
  for (genvar i = 0;i < N_VIP;++i) begin : g_vip
    pzvip_i2c_if  vip_if();
    initial begin
      vip_vif[i]  = vip_if;
    end

    bufif0 u_buf_scl (i2c_scl, 1'b0, vip_if.scl_out);
    bufif0 u_buf_sda (i2c_sda, 1'b0, vip_if.sda_out);

    always @* begin
      vip_if.scl_in = i2c_scl;
      vip_if.sda_in = i2c_sda;
    end
  end

  if (1) begin : g_duv
    bufif0 u_buf_scl (i2c_scl, 1'b0, i_scl);
    bufif0 u_buf_sda (i2c_sda, 1'b0, i_sda);

    always @* begin
      o_scl = i2c_scl;
      o_sda = i2c_sda;
    end
  end
endmodule
