//========================================
//
// Copyright (c) 2023 PEZY Computing, K.K.
//                    All Rights Reserved.
//
//========================================
interface pzvip_i2c_if;
  timeunit  1ns;

  logic scl_in;
  logic sda_in;
  logic scl_out = '1;
  logic sda_out = '1;

  event scl_posedge;
  event scl_negedge;
  event start_condition;
  event stop_condition;

  always @(posedge scl_in) begin
    ->scl_posedge;
  end

  always @(negedge scl_in) begin
    ->scl_negedge;
  end

  always @(negedge sda_in) begin
    if (scl_in) begin
      ->start_condition;
    end
  end

  always @(posedge sda_in) begin
    if (scl_in) begin
      ->stop_condition;
    end
  end

  task automatic drive_i2c_master(
    input int scl_period_ns,
    input bit out_bit,
    ref   bit in_bit
  );
    sda_out <= out_bit;
    scl_out <= '0;
    #(scl_period_ns / 2);

    scl_out <= '1;
    if (!scl_posedge.triggered) begin
      @(scl_posedge);
    end

    in_bit  = sda_in;
    #(scl_period_ns / 2);

    sda_out <= '1;
  endtask

  task automatic send_i2c_master(
    input int scl_period_ns,
    input bit out_bit,
    ref   bit lost_arbitration
  );
    bit in_bit;
    drive_i2c_master(scl_period_ns, out_bit, in_bit);
    lost_arbitration  = in_bit != out_bit;
  endtask

  task automatic receive_i2c_master(
    input int scl_period_ns,
    ref   bit in_bit
  );
    drive_i2c_master(scl_period_ns, '1, in_bit);
  endtask

  task automatic send_start_condition(
    input int period_ns,
    ref   bit lost_arbitration
  );
    sda_out <= '0;
    #(period_ns);
    lost_arbitration  = sda_in != '0;
  endtask

  task automatic send_repeated_start_condition(
    input int period_ns,
    ref   bit lost_arbitration
  );
    scl_out <= '0;
    #(period_ns);
    sda_out <= '1;
    #(period_ns);
    scl_out <= '1;
    #(period_ns);
    send_start_condition(period_ns, lost_arbitration);
  endtask

  task automatic send_stop_condition(
    int period_ns
  );
    scl_out <= '0;
    #(period_ns);
    sda_out <= '0;
    #(period_ns);
    scl_out <= '1;
    #(period_ns);
    sda_out <= '1;
    #(period_ns);
  endtask

  task automatic drive_i2c_slave(
    input int scl_stretching_ns,
    input bit out_bit,
    ref   bit in_bit
  );
    if (!scl_negedge.triggered) begin
      @(scl_negedge);
    end

    sda_out <= out_bit;
    if (scl_stretching_ns > 0) begin
      scl_out <= '0;
      #(scl_stretching_ns);
      scl_out <= '1;
    end

    if (!scl_posedge.triggered) begin
      @(scl_posedge);
    end
    in_bit  = sda_in;

    @(scl_negedge);
    sda_out <= '1;
  endtask

  task automatic sample_bit(
    ref bit sda
  );
    @(posedge scl_in);
    sda = sda_in;
  endtask

  task automatic sample_byte(
    ref bit [7:0] sda_byte
  );
    for (int i = 7;i >= 0;--i) begin
      bit sda;
      sample_bit(sda);
      sda_byte[i] = sda;
    end
  endtask

  task automatic sample_byte_acknack(
    ref bit [7:0] sda_byte,
    ref bit       acknack
  );
    sample_byte(sda_byte);
    sample_bit(acknack);
  endtask

  task automatic wait_for_start_condition();
    if (!start_condition.triggered) begin
      @(start_condition);
    end
  endtask

  task automatic wait_for_stop_condition();
    if (!stop_condition.triggered) begin
      @(stop_condition);
    end
  endtask
endinterface
