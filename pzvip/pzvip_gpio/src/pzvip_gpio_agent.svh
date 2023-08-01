`ifndef PZVIP_GPIO_AGENT_SVH
`define PZVIP_GPIO_AGENT_SVH
class pzvip_gpio_agent extends tue_param_agent #(
  .CONFIGURATION  (pzvip_gpio_configuration ),
  .SEQUENCER      (pzvip_gpio_sequencer     )
);
  pzvip_gpio_vif  vif;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    vif                     = configuration.vif;
    vif.reset_value_out     = configuration.reset_value.value_out;
    vif.reset_output_enable = configuration.reset_value.output_enable;
  endfunction

  task run_phase(uvm_phase phase);
    if (configuration.use_reset && configuration.reset_by_agent) begin
      reset_loop();
    end
    else if (!configuration.use_reset) begin
      vif.reset();
    end
  endtask

  task reset_loop();
    forever @(vif.master_cb, negedge vif.reset_n) begin
      if (!vif.reset_n) begin
        vif.reset();
      end
    end
  endtask

  `tue_component_default_constructor(pzvip_gpio_agent)
  `uvm_component_utils(pzvip_gpio_agent)
endclass
`endif
