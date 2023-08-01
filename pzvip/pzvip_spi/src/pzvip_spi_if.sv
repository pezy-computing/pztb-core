//========================================
//
// Copyright (c) 2023 PEZY Computing, K.K.
//                    All Rights Reserved.
//
//========================================
interface pzvip_spi_if;
  timeunit  1ns;

  bit                               sclk;
  bit [`PZVIP_SPI_MAX_SS_WIDTH-1:0] ss_n;
  bit                               mosi;
  bit                               miso;

  bit   cpha;
  bit   cpol;
  event at_shift;
  event at_sample;

  always @(posedge sclk) begin
    case ({cpol, cpha})
      2'b00:  ->at_sample;
      2'b01:  ->at_shift;
      2'b10:  ->at_shift;
      2'b11:  ->at_sample;
    endcase
  end

  always @(negedge sclk) begin
    case ({cpol, cpha})
      2'b00:  ->at_shift;
      2'b01:  ->at_sample;
      2'b10:  ->at_sample;
      2'b11:  ->at_shift;
    endcase
  end

  int   slave_devices;
  event at_start;
  event at_end;

  initial begin
    monitor_ss();
  end

  task automatic monitor_ss();
    bit [`PZVIP_SPI_MAX_SS_WIDTH-1:0] prvious_ss_n;
    prvious_ss_n  = '1;
    forever @(ss_n) begin
      for (int i = 0;i < slave_devices;++i) begin
        case ({ss_n[i], prvious_ss_n[i]})
          2'b01:  ->at_start;
          2'b10:  ->at_end;
        endcase
      end
      prvious_ss_n  = ss_n;
    end
  endtask

  task automatic do_spi_master_access(
    input int sclk_period_ns,
    input bit sclk_cpol,
    input bit sclk_cpha,
    input int slave_index,
    ref   bit mosi_bits[],
    ref   bit miso_bits[]
  );
    int half_period;

    half_period       = sclk_period_ns / 2;
    cpol              = sclk_cpol;
    cpha              = sclk_cpha;

    sclk              = sclk_cpol;
    ss_n[slave_index] = '0;
    #(half_period);
    if (cpha) begin
      foreach (mosi_bits[i]) begin
        sclk  = ~sclk;
        mosi  = mosi_bits[i];
        #(half_period);

        sclk          = ~sclk;
        miso_bits[i]  = miso;
        #(half_period);
      end
    end
    else begin
      foreach (mosi_bits[i]) begin
        mosi  = mosi_bits[i];

        #(half_period);
        sclk          = ~sclk;
        miso_bits[i]  = miso;

        #(half_period);
        sclk  = ~sclk;
      end
      #(half_period);
    end

    ss_n  = '1;
  endtask

  task automatic wait_for_start(
    ref int slave_index
  );
    if (!at_start.triggered) begin
      @(at_start);
    end

    for (int i = 0;i < slave_devices;++i) begin
      if (!ss_n[i]) begin
        slave_index = i;
        break;
      end
    end
  endtask

  task automatic monitor_spi_access(
    ref int slave_index,
    ref bit mosi_bits[$],
    ref bit miso_bits[$]
  );
    wait_for_start(slave_index);
    forever @(at_sample, at_end) begin
      if (at_end.triggered) begin
        break;
      end
      mosi_bits.push_back(mosi);
      miso_bits.push_back(miso);
    end
  endtask

  task drive_miso(bit miso_bit);
    miso  = miso_bit;
    @(at_shift, at_end);
  endtask
endinterface
