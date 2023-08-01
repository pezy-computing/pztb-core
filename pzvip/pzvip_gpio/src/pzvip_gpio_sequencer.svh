`ifndef PZVIP_GPIO_SEQUENCER_SVH
`define PZVIP_GPIO_SEQUENCER_SVH
class pzvip_gpio_sequencer extends tue_sequencer #(
  .CONFIGURATION  (pzvip_gpio_configuration ),
  .REQ            (tue_sequence_item_dummy  )
);
  pzvip_gpio_vif  vif;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    vif = configuration.vif;
  endfunction

  task set(
    pzvip_gpio_value  value_out,
    pzvip_gpio_value  output_enable = '0,
    bit               one_shot      = 0
  );
    wait_for_deasserting_reset();
    wait_for_clock_posedge();

    if (configuration.no_sync_clock) begin
      vif.value_out     = value_out;
      vif.output_enable = output_enable;
    end
    else begin
      vif.master_cb.value_out     <= value_out;
      vif.master_cb.output_enable <= output_enable;
    end

    if (!one_shot) begin
      return;
    end

    @(vif.at_clock_posedge);
    set(
      configuration.reset_value.value_out,
      configuration.reset_value.output_enable,
      0
    );
  endtask

  function pzvip_gpio_value get();
    if (configuration.no_sync_clock) begin
      return vif.value_in;
    end
    else begin
      return vif.monitor_cb.value_in;
    end
  endfunction

  task clear_output_enable();
    wait_for_deasserting_reset();
    wait_for_clock_posedge();
    if (configuration.no_sync_clock) begin
      vif.output_enable = '0;
    end
    else begin
      vif.master_cb.output_enable <= '0;
    end
  endtask

  task wait_for_change(ref pzvip_gpio_value value_out);
    pzvip_gpio_value  previous_value;
    pzvip_gpio_value  current_value;
    pzvip_gpio_value  mask;

    mask            = (1 << configuration.width) - 1;
    previous_value  = get() & mask;
    forever begin
      if (configuration.no_sync_clock) begin
        @(vif.value_in);
      end
      else begin
        @(vif.monitor_cb.value_in);
      end

      current_value = get() & mask;
      if (current_value != previous_value) begin
        break;
      end
      else begin
        previous_value  = current_value;
      end
    end

    value_out = current_value;
  endtask

  task wait_for_edge(
    pzvip_gpio_value  target_bits   = '1,
    bit               wait_for_all  = 1,
    pzvip_gpio_action action        = PZVIP_GPIO_WAIT_FOR_EDGE
  );
    bit [3:0]         event_type;
    pzvip_gpio_value  done;

    if (target_bits == '0) begin
      return;
    end

    event_type[0] = action == PZVIP_GPIO_WAIT_FOR_EDGE;
    event_type[1] = action == PZVIP_GPIO_WAIT_FOR_POSEDGE;
    event_type[2] = action == PZVIP_GPIO_WAIT_FOR_NEGEDGE;
    event_type[3] = configuration.no_sync_clock;

    done  = '0;
    for (int i = 0;i < configuration.width;++i) begin
      if (target_bits[i]) begin
        fork
          automatic int ii  = i;
          begin
            case (event_type)
              4'b0001:  @(vif.monitor_cb.value_in[ii]);
              4'b1001:  @(vif.value_in[ii]);
              4'b0010:  @(posedge vif.monitor_cb.value_in[ii]);
              4'b1010:  @(posedge vif.value_in[ii]);
              4'b0100:  @(negedge vif.monitor_cb.value_in[ii]);
              4'b1100:  @(negedge vif.value_in[ii]);
            endcase
            done[ii]  = 1;
          end
        join_none
      end
    end

    #0;
    if (wait_for_all) begin
      wait fork;
    end
    else begin
      wait (done != '0);
      disable fork;
    end
  endtask

  task wait_for_posedge(
    pzvip_gpio_value  target_bits   = '1,
    bit               wait_for_all  = 1
  );
    wait_for_edge(target_bits, wait_for_all, PZVIP_GPIO_WAIT_FOR_POSEDGE);
  endtask

  task wait_for_negedge(
    pzvip_gpio_value  target_bits   = '1,
    bit               wait_for_all  = 1
  );
    wait_for_edge(target_bits, wait_for_all, PZVIP_GPIO_WAIT_FOR_NEGEDGE);
  endtask

  task wait_for_high(
    pzvip_gpio_value  target_bits,
    bit               wait_for_all
  );
    pzvip_gpio_value  done;

    if (target_bits == '0) begin
      return;
    end

    done  = '0;
    for (int i = 0;i < configuration.width;++i) begin
      if (target_bits[i]) begin
        fork
          automatic int ii  = i;
          if (configuration.no_sync_clock) begin
            if (!vif.value_in[ii]) begin
              @(posedge vif.value_in[ii]);
            end
            done[ii]  = '1;
          end
          else begin
            if (!vif.monitor_cb.value_in[ii]) begin
              @(posedge vif.monitor_cb.value_in[ii]);
            end
            done[ii]  = '1;
          end
        join_none
      end
    end

    #0;
    if (wait_for_all) begin
      wait fork;
    end
    else begin
      wait (done != '0);
      disable fork;
    end
  endtask

  task wait_for_low(
    pzvip_gpio_value  target_bits,
    bit               wait_for_all
  );
    pzvip_gpio_value  done;

    if (target_bits == '0) begin
      return;
    end

    done  = '0;
    for (int i = 0;i < configuration.width;++i) begin
      if (target_bits[i]) begin
        fork
          automatic int ii  = i;
          if (configuration.no_sync_clock) begin
            if (vif.value_in[ii]) begin
              @(negedge vif.value_in[ii]);
            end
            done[ii]  = '1;
          end
          else begin
            if (vif.monitor_cb.value_in[ii]) begin
              @(negedge vif.monitor_cb.value_in[ii]);
            end
            done[ii]  = '1;
          end
        join_none
      end
    end

    #0;
    if (wait_for_all) begin
      wait fork;
    end
    else begin
      wait (done != '0);
      disable fork;
    end
  endtask

  task wait_cycles(int cycles);
    vif.wait_cycles(cycles);
  endtask

  task wait_for_clock_posedge();
    if (!(configuration.no_sync_clock || vif.at_clock_posedge.triggered)) begin
      vif.wait_for_clock_posedge();
    end
  endtask

  task wait_for_deasserting_reset();
    if (configuration.use_reset && (!vif.reset_n)) begin
      @(posedge vif.reset_n);
    end
  endtask

  `tue_component_default_constructor(pzvip_gpio_sequencer)
  `uvm_component_utils(pzvip_gpio_sequencer)
endclass
`endif
