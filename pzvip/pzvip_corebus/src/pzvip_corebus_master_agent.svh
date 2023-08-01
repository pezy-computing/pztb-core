`ifndef PZVIP_COREBUS_MASTER_AGENT_SVH
`define PZVIP_COREBUS_MASTER_AGENT_SVH
typedef tue_param_agent #(
  .CONFIGURATION  (pzvip_corebus_configuration    ),
  .STATUS         (pzvip_corebus_status           ),
  .ITEM           (pzvip_corebus_item             ),
  .MONITOR        (pzvip_corebus_master_monitor   ),
  .SEQUENCER      (pzvip_corebus_master_sequencer ),
  .DRIVER         (pzvip_corebus_master_driver    )
) pzvip_corebus_master_agent_base;

class pzvip_corebus_master_agent extends pzvip_corebus_agent_base #(
  .BASE (pzvip_corebus_master_agent_base  )
);
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (configuration.vif != null) begin
      pzvip_corebus_vif vif = configuration.vif;
      vif.default_command_valid   = '0;
      vif.default_data_valid      = get_default_data_valid();
      vif.default_response_accept = configuration.default_response_accept;
    end
  endfunction

  local function logic get_default_data_valid();
    return (configuration.profile != PZVIP_COREBUS_CSR) ? '0 : 'x;
  endfunction

  `tue_component_default_constructor(pzvip_corebus_master_agent)
  `uvm_component_utils(pzvip_corebus_master_agent)
endclass
`endif
