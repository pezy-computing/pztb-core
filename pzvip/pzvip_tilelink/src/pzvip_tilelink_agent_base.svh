`ifndef PZVIP_TILELINK_AGENT_BASE_SVH
`define PZVIP_TILELINK_AGENT_BASE_SVH
virtual class pzvip_tilelink_agent_base #(
  type  MONITOR   = tue_monitor_dummy,
  type  SEQUENCER = tue_sequencer_dummy,
  type  DRIVER    = tue_driver_dummy,
  bit   IS_SENDER = 1
) extends tue_param_agent #(
  .CONFIGURATION  (pzvip_tilelink_configuration ),
  .STATUS         (pzvip_tilelink_status        ),
  .ITEM           (pzvip_tilelink_message_item  ),
  .MONITOR        (MONITOR                      ),
  .SEQUENCER      (SEQUENCER                    ),
  .DRIVER         (DRIVER                       )
);
  uvm_analysis_port #(pzvip_tilelink_message_item)  request_port;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!IS_SENDER) begin
      request_port  = new("request_port", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (!IS_SENDER) begin
      monitor.request_port.connect(request_port);
    end
  endfunction

  `tue_component_default_constructor(pzvip_tilelink_agent_base)
endclass
`endif
