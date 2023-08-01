`ifndef PZVIP_TILELINK_SLAVE_SEQUENCER_SVH
`define PZVIP_TILELINK_SLAVE_SEQUENCER_SVH
class pzvip_tilelink_slave_sequencer extends tue_sequencer #(
  .CONFIGURATION  (pzvip_tilelink_configuration ),
  .STATUS         (pzvip_tilelink_status        )
);
  pzvip_tilelink_a_sequencer  a_sequencer;
  pzvip_tilelink_a_sequencer  b_sequencer;
  pzvip_tilelink_a_sequencer  c_sequencer;
  pzvip_tilelink_d_sequencer  d_sequencer;
  pzvip_tilelink_a_sequencer  e_sequencer;

  protected pzvip_tilelink_id_manager     id_manager;
  protected pzvip_tilelink_message_waiter message_waiter;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    id_manager  = new();
    id_manager.set_context(configuration, status);

    message_waiter  = new("message_waiter", this);
    message_waiter.set_context(configuration, status);
  endfunction

  function void connect_sub_agent(uvm_agent agent);
    pzvip_tilelink_a_slave_agent  a_agent;
    pzvip_tilelink_b_slave_agent  b_agent;
    pzvip_tilelink_c_slave_agent  c_agent;
    pzvip_tilelink_d_slave_agent  d_agent;
    pzvip_tilelink_e_slave_agent  e_agent;
    if ($cast(a_agent, agent)) begin
      a_sequencer = a_agent.sequencer;
      a_agent.request_port.connect(message_waiter.analysis_export);
    end
    else if ($cast(b_agent, agent)) begin
      b_sequencer = b_agent.sequencer;
    end
    else if ($cast(c_agent, agent)) begin
      c_sequencer = c_agent.sequencer;
      c_agent.request_port.connect(message_waiter.analysis_export);
    end
    else if ($cast(d_agent, agent)) begin
      d_sequencer = d_agent.sequencer;
    end
    else if ($cast(e_agent, agent)) begin
      e_sequencer = e_agent.sequencer;
      e_agent.request_port.connect(message_waiter.analysis_export);
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

  task get_acquire_message(
    ref pzvip_tilelink_receiver_message_item  message
  );
    pzvip_tilelink_message_item temp;
    message_waiter.get_message(
      '{
        PZVIP_TILELINK_ACQUIRE_BLOCK,
        PZVIP_TILELINK_ACQUIRE_PERM
      },
      temp
    );
    $cast(message, temp);
  endtask

  task get_probe_ack_message(
    input int                                   source,
    ref   pzvip_tilelink_receiver_message_item  message
  );
    pzvip_tilelink_message_item temp;
    message_waiter.get_message_by_source(
      '{
        PZVIP_TILELINK_PROBE_ACK,
        PZVIP_TILELINK_PROBE_ACK_DATA
      },
      source,
      temp
    );
    $cast(message, temp);
  endtask

  task get_release_message(
    ref pzvip_tilelink_receiver_message_item  message
  );
    pzvip_tilelink_message_item temp;
    message_waiter.get_message(
      '{
        PZVIP_TILELINK_RELEASE,
        PZVIP_TILELINK_RELEASE_DATA
      },
      temp
    );
    $cast(message, temp);
  endtask

  task get_grant_ack_message(
    input int                                   sink,
    ref   pzvip_tilelink_receiver_message_item  message
  );
    pzvip_tilelink_message_item temp;
    message_waiter.get_message_by_sink(
      '{PZVIP_TILELINK_GRANT_ACK},
      sink,
      temp
    );
    $cast(message, temp);
  endtask

  task get_id(
    ref   pzvip_tilelink_id id,
    input int               base_id = -1
  );
    id_manager.get(id, base_id);
  endtask

  function void put_id(pzvip_tilelink_id id);
    id_manager.put(id);
  endfunction

  `tue_component_default_constructor(pzvip_tilelink_slave_sequencer)
  `uvm_component_utils(pzvip_tilelink_slave_sequencer)
endclass
`endif
