`ifndef PZVIP_COREBUS_SLAVE_AGENT_SVH
`define PZVIP_COREBUS_SLAVE_AGENT_SVH
typedef tue_reactive_agent #(
  .CONFIGURATION            (pzvip_corebus_configuration    ),
  .STATUS                   (pzvip_corebus_status           ),
  .ITEM                     (pzvip_corebus_item             ),
  .MONITOR                  (pzvip_corebus_slave_monitor    ),
  .SEQUENCER                (pzvip_corebus_slave_sequencer  ),
  .DRIVER                   (pzvip_corebus_slave_driver     ),
  .ENABLE_PASSIVE_SEQUENCER (1                              )
) pzvip_corebus_slave_agent_base;

class pzvip_corebus_slave_agent extends pzvip_corebus_agent_base #(
  .BASE (pzvip_corebus_slave_agent_base )
);
  protected pzvip_corebus_slave_data_monitor  data_monitor;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    data_monitor  = pzvip_corebus_slave_data_monitor::type_id::create("data_monitor", this);
    data_monitor.set_context(configuration, status);

    if (configuration.vif != null) begin
      pzvip_corebus_vif vif = configuration.vif;
      vif.default_command_accept  = configuration.default_command_accept;
      vif.default_data_accept     = get_default_data_accept();
      vif.default_response_valid  = '0;
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    monitor.request_item_port.connect(data_monitor.analysis_export);
    monitor.response_item_port.connect(data_monitor.analysis_export);
    data_monitor.connect_pa_writer(pa_writer);
  endfunction

  local function logic get_default_data_accept();
    if (configuration.profile != PZVIP_COREBUS_CSR) begin
      return configuration.default_data_accept;
    end
    else begin
      return 'x;
    end
  endfunction

  `tue_component_default_constructor(pzvip_corebus_slave_agent)
  `uvm_component_utils(pzvip_corebus_slave_agent)
endclass
`endif
