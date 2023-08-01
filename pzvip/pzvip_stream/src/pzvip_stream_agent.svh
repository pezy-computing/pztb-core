class pzvip_stream_agent_base #(
  type  DRIVER  = uvm_component
) extends tue_param_agent #(
  .CONFIGURATION  (pzvip_stream_configuration ),
  .STATUS         (pzvip_stream_status        ),
  .ITEM           (pzvip_stream_item          ),
  .MONITOR        (pzvip_stream_monitor       ),
  .SEQUENCER      (pzvip_stream_sequencer     ),
  .DRIVER         (DRIVER                     )
);
  uvm_analysis_port #(pzvip_stream_unit_item) unit_item_port;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    unit_item_port  = new("unit_item_port", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    monitor.unit_item_port.connect(unit_item_port);
    if (sequencer != null) begin
      monitor.item_port.connect(sequencer.item_export);
    end
  endfunction

  `tue_component_default_constructor(pzvip_stream_agent_base)
endclass

class pzvip_stream_master_agent extends pzvip_stream_agent_base #(
  .DRIVER (pzvip_stream_driver  )
);
  `tue_component_default_constructor(pzvip_stream_master_agent)
  `uvm_component_utils(pzvip_stream_master_agent)
endclass

class pzvip_stream_slave_agent extends pzvip_stream_agent_base #(
  .DRIVER (pzvip_stream_ready_driver  )
);
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    configuration.vif.default_ready = configuration.default_ready;
  endfunction

  `tue_component_default_constructor(pzvip_stream_slave_agent)
  `uvm_component_utils(pzvip_stream_slave_agent)
endclass
