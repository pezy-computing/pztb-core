`ifndef PZVIP_TILELINK_MASTER_AGENT_SVH
`define PZVIP_TILELINK_MASTER_AGENT_SVH
class pzvip_tilelink_master_agent extends tue_agent #(
  .CONFIGURATION  (pzvip_tilelink_configuration ),
  .STATUS         (pzvip_tilelink_status        )
);
  uvm_analysis_port #(pzvip_tilelink_message_item)  item_port;
  pzvip_tilelink_master_sequencer                   sequencer;

  protected pzvip_tilelink_a_master_agent   a_agent;
  protected pzvip_tilelink_b_master_agent   b_agent;
  protected pzvip_tilelink_c_master_agent   c_agent;
  protected pzvip_tilelink_d_master_agent   d_agent;
  protected pzvip_tilelink_e_master_agent   e_agent;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    item_port = new("item_port", this);

    sequencer = pzvip_tilelink_master_sequencer::type_id::create("sequencer", this);
    sequencer.set_context(configuration, status);

    if (1) begin
      a_agent = pzvip_tilelink_a_master_agent::type_id::create("a_agent", this);
      a_agent.set_context(configuration, status);
    end

    if (configuration.conformance_level == PZVIP_TILELINK_TL_C) begin
      b_agent = pzvip_tilelink_b_master_agent::type_id::create("b_agent", this);
      b_agent.set_context(configuration, status);
    end

    if (configuration.conformance_level == PZVIP_TILELINK_TL_C) begin
      c_agent = pzvip_tilelink_c_master_agent::type_id::create("c_agent", this);
      c_agent.set_context(configuration, status);
    end

    if (1) begin
      d_agent = pzvip_tilelink_d_master_agent::type_id::create("d_agent", this);
      d_agent.set_context(configuration, status);
    end

    if (configuration.conformance_level == PZVIP_TILELINK_TL_C) begin
      e_agent = pzvip_tilelink_e_master_agent::type_id::create("e_agent", this);
      e_agent.set_context(configuration, status);
    end

    configuration.vif.set_default_ready(
      .b_default_ready  (configuration.b_default_ready  ),
      .d_default_ready  (configuration.d_default_ready  )
    );
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if (a_agent != null) begin
      sequencer.connect_sub_agent(a_agent);
      a_agent.item_port.connect(item_port);
    end

    if (b_agent != null) begin
      sequencer.connect_sub_agent(b_agent);
      b_agent.item_port.connect(item_port);
    end

    if (c_agent != null) begin
      sequencer.connect_sub_agent(c_agent);
      c_agent.item_port.connect(item_port);
    end

    if (d_agent != null) begin
      sequencer.connect_sub_agent(d_agent);
      d_agent.item_port.connect(item_port);
    end

    if (e_agent != null) begin
      sequencer.connect_sub_agent(e_agent);
      e_agent.item_port.connect(item_port);
    end
  endfunction

  `tue_component_default_constructor(pzvip_tilelink_master_agent)
  `uvm_component_utils(pzvip_tilelink_master_agent)
endclass
`endif
