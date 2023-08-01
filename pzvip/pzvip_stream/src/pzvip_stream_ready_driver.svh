class pzvip_stream_ready_driver extends tue_driver #(
  .CONFIGURATION  (pzvip_stream_configuration ),
  .STATUS         (pzvip_stream_status        ),
  .REQ            (pzvip_stream_item          )
);
  protected pzvip_stream_vif  vif;
  protected int               delay;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    vif = configuration.vif;
  endfunction

  task run_phase(uvm_phase phase);
    forever @(vif.slave_cb, negedge vif.i_rst_n) begin
      if (!vif.i_rst_n) begin
        do_reset();
      end
      else begin
        do_drive();
      end
    end
  endtask

  protected task do_reset();
    if (configuration.reset_by_agent) begin
      vif.reset_slave();
    end
    delay = -1;
  endtask

  protected task do_drive();
    if (vif.slave_cb.valid && (delay < 0)) begin
      randomize_delay();
    end

    vif.slave_cb.ready  <=
      ((configuration.default_ready == 1) && (delay <= 0)) ||
      ((configuration.default_ready == 0) && (delay == 0));

    if (delay >= 0) begin
      --delay;
    end
  endtask

  protected function void randomize_delay();
    if (!std::randomize(delay) with {
      `pzvip_delay_constraint(delay, this.configuration.ready_delay)
    }) begin
      `uvm_fatal("RNDFLD", "Randomization failed")
    end
  endfunction

  `tue_component_default_constructor(pzvip_stream_ready_driver)
  `uvm_component_utils(pzvip_stream_ready_driver)
endclass
