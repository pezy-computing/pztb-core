class pzvip_spi_slave_random_response_sequence extends pzvip_spi_slave_sequence_base;
  task body();
    forever begin
      @(vif.at_start);
      if (vif.cpha) begin
        @(vif.at_shift);
      end

      forever begin
        randcase
          1:  vif.drive_miso(0);
          1:  vif.drive_miso(1);
        endcase

        if (vif.at_end.triggered) begin
          break;
        end
      end
    end
  endtask

  `tue_object_default_constructor(pzvip_spi_slave_random_response_sequence)
  `uvm_object_utils(pzvip_spi_slave_random_response_sequence)
endclass
