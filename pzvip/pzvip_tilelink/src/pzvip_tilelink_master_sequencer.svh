`ifndef PZVIP_TILELINK_MASTER_SEQUENCER_SVH
`define PZVIP_TILELINK_MASTER_SEQUENCER_SVH
class pzvip_tilelink_master_sequencer extends tue_sequencer #(
  .CONFIGURATION  (pzvip_tilelink_configuration ),
  .STATUS         (pzvip_tilelink_status        )
);
  pzvip_tilelink_a_sequencer  a_sequencer;
  pzvip_tilelink_b_sequencer  b_sequencer;
  pzvip_tilelink_c_sequencer  c_sequencer;
  pzvip_tilelink_d_sequencer  d_sequencer;
  pzvip_tilelink_e_sequencer  e_sequencer;

  protected pzvip_tilelink_id_manager     id_manager;
  protected pzvip_tilelink_message_waiter message_waiter;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    id_manager  = new("id_manager");
    id_manager.set_context(configuration, status);

    message_waiter  = new("message_waiter", this);
    message_waiter.set_context(configuration, status);
  endfunction

  function void connect_sub_agent(uvm_agent agent);
    pzvip_tilelink_a_master_agent a_agent;
    pzvip_tilelink_b_master_agent b_agent;
    pzvip_tilelink_c_master_agent c_agent;
    pzvip_tilelink_d_master_agent d_agent;
    pzvip_tilelink_e_master_agent e_agent;
    if ($cast(a_agent, agent)) begin
      a_sequencer = a_agent.sequencer;
    end
    else if ($cast(b_agent, agent)) begin
      b_sequencer = b_agent.sequencer;
      b_agent.request_port.connect(message_waiter.analysis_export);
    end
    else if ($cast(c_agent, agent)) begin
      c_sequencer = c_agent.sequencer;
    end
    else if ($cast(d_agent, agent)) begin
      d_sequencer = d_agent.sequencer;
      d_agent.request_port.connect(message_waiter.analysis_export);
    end
    else if ($cast(e_agent, agent)) begin
      e_sequencer = e_agent.sequencer;
    end
  endfunction

  task get_put_get_message(
    ref pzvip_tilelink_receiver_message_item  message
  );
    pzvip_tilelink_message_item temp;
    message_waiter.get_message(
      '{
        PZVIP_TILELINK_GET,
        PZVIP_TILELINK_PUT_FULL_DATA,
        PZVIP_TILELINK_PUT_PARTIAL_DATA
      },
      temp
    );
    $cast(message, temp);
  endtask

  task get_atomic_message(
    ref pzvip_tilelink_receiver_message_item  message
  );
    pzvip_tilelink_message_item temp;
    message_waiter.get_message(
      '{
        PZVIP_TILELINK_ARITHMETIC_DATA,
        PZVIP_TILELINK_LOGICAL_DATA
      },
      temp
    );
    $cast(message, temp);
  endtask

  task get_hint_message(
    ref pzvip_tilelink_receiver_message_item  message
  );
    pzvip_tilelink_message_item temp;
    message_waiter.get_message(
      '{PZVIP_TILELINK_HINT},
      temp
    );
    $cast(message, temp);
  endtask

  task get_probe_message(
    ref pzvip_tilelink_receiver_message_item  message
  );
    pzvip_tilelink_message_item temp;
    message_waiter.get_message(
      '{PZVIP_TILELINK_PROBE},
      temp
    );
    $cast(message, temp);
  endtask

  task get_access_ack_message(
    input int                                   source,
    ref   pzvip_tilelink_receiver_message_item  message
  );
    pzvip_tilelink_message_item temp;
    message_waiter.get_message_by_source(
      '{
        PZVIP_TILELINK_ACCESS_ACK,
        PZVIP_TILELINK_ACCESS_ACK_DATA
      },
      source,
      temp
    );
    $cast(message, temp);
  endtask

  task get_hint_ack_message(
    input int                                   source,
    ref   pzvip_tilelink_receiver_message_item  message
  );
    pzvip_tilelink_message_item temp;
    message_waiter.get_message_by_source(
      '{PZVIP_TILELINK_HINT_ACK},
      source,
      temp
    );
    $cast(message, temp);
  endtask

  task get_grant_message(
    input int                                   source,
    ref   pzvip_tilelink_receiver_message_item  message
  );
    pzvip_tilelink_message_item temp;
    message_waiter.get_message_by_source(
      '{
        PZVIP_TILELINK_GRANT,
        PZVIP_TILELINK_GRANT_DATA
      },
      source,
      temp
    );
    $cast(message, temp);
  endtask

  task get_release_ack_message(
    input int                                   source,
    ref   pzvip_tilelink_receiver_message_item  message
  );
    pzvip_tilelink_message_item temp;
    message_waiter.get_message_by_source(
      '{PZVIP_TILELINK_RELEASE_ACK},
      source,
      temp
    );
    $cast(message, temp);
  endtask

  task get_id(ref pzvip_tilelink_id id);
    id_manager.get(id);
  endtask

  function void put_id(pzvip_tilelink_id id);
    id_manager.put(id);
  endfunction

  `tue_component_default_constructor(pzvip_tilelink_master_sequencer)
  `uvm_component_utils(pzvip_tilelink_master_sequencer)
endclass
`endif
