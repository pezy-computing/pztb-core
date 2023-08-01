`ifndef PZVIP_COREBUS_AGENT_BASE_SVH
`define PZVIP_COREBUS_AGENT_BASE_SVH
class pzvip_corebus_agent_base #(
  type  BASE  = uvm_agent
) extends BASE;
  uvm_analysis_port #(pzvip_corebus_item) command_item_port;
  uvm_analysis_port #(pzvip_corebus_item) request_item_port;
  uvm_analysis_port #(pzvip_corebus_item) response_item_port;

  protected pzvip_corebus_access_count_monitor  access_count_monitor;
  protected pzvip_corebus_pa_writer             pa_writer;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    command_item_port   = new("command_item_port" , this);
    request_item_port   = new("request_item_port" , this);
    response_item_port  = new("response_item_port", this);

    access_count_monitor  = pzvip_corebus_access_count_monitor::type_id::create("access_count_monitor", this);
    access_count_monitor.set_context(configuration, status);

    if (configuration.pa_writer.enable_writer) begin
      pa_writer = pzvip_corebus_pa_writer::type_id::create("pa_writer");
      pa_writer.build(this, configuration);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    monitor.command_item_port.connect(command_item_port);
    monitor.request_item_port.connect(request_item_port);
    monitor.response_item_port.connect(response_item_port);

    monitor.command_item_port.connect(access_count_monitor.command_item_export);
    monitor.request_item_port.connect(access_count_monitor.request_item_export);
    monitor.response_item_port.connect(access_count_monitor.response_item_export);

    if (sequencer != null) begin
      monitor.command_item_port.connect(sequencer.command_item_export);
      monitor.request_item_port.connect(sequencer.request_item_export);
      monitor.response_item_port.connect(sequencer.response_item_export);
    end

    monitor.connect_pa_writer(pa_writer);
  endfunction

  `tue_component_default_constructor(pzvip_corebus_agent_base)
endclass
`endif
