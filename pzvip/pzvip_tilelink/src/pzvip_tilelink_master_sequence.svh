`ifndef PZVIP_TILELINK_MASTER_SEQUENCE_SVH
`define PZVIP_TILELINK_MASTER_SEQUENCE_SVH
class pzvip_tilelink_master_sequence extends tue_sequence #(
  .CONFIGURATION  (pzvip_tilelink_configuration ),
  .STATUS         (pzvip_tilelink_status        ),
  .REQ            (pzvip_tilelink_message_item  )
);
  pzvip_tilelink_a_sequencer  a_sequencer;
  pzvip_tilelink_a_sequencer  b_sequencer;
  pzvip_tilelink_a_sequencer  c_sequencer;
  pzvip_tilelink_d_sequencer  d_sequencer;
  pzvip_tilelink_a_sequencer  e_sequencer;

  function void set_sequencer(uvm_sequencer_base sequencer);
    super.set_sequencer(sequencer);
    a_sequencer = p_sequencer.a_sequencer;
    b_sequencer = p_sequencer.b_sequencer;
    c_sequencer = p_sequencer.c_sequencer;
    d_sequencer = p_sequencer.d_sequencer;
    e_sequencer = p_sequencer.e_sequencer;
  endfunction

  task get_put_get_message(
    ref pzvip_tilelink_receiver_message_item  message
  );
    p_sequencer.get_put_get_message(message);
  endtask

  task get_atomic_message(
    ref pzvip_tilelink_receiver_message_item  message
  );
    p_sequencer.get_atomic_message(message);
  endtask

  task get_hint_message(
    ref pzvip_tilelink_receiver_message_item  message
  );
    p_sequencer.get_hint_message(message);
  endtask

  task get_probe_message(
    ref pzvip_tilelink_receiver_message_item  message
  );
    p_sequencer.get_probe_message(message);
  endtask

  task get_access_ack_message(
    input int                                   source,
    ref   pzvip_tilelink_receiver_message_item  message
  );
    p_sequencer.get_access_ack_message(source, message);
  endtask

  task get_hint_ack_message(
    input int                                   source,
    ref   pzvip_tilelink_receiver_message_item  message
  );
    p_sequencer.get_hint_ack_message(source, message);
  endtask

  task get_grant_message(
    input int                                   source,
    ref   pzvip_tilelink_receiver_message_item  message
  );
    p_sequencer.get_grant_message(source, message);
  endtask

  task get_release_ack_message(
    input int                                   source,
    ref   pzvip_tilelink_receiver_message_item  message
  );
    p_sequencer.get_release_ack_message(source, message);
  endtask

  task get_id(ref pzvip_tilelink_id id);
    p_sequencer.get_id(id);
  endtask

  function void put_id(pzvip_tilelink_id id);
    p_sequencer.put_id(id);
  endfunction

  `tue_object_default_constructor(pzvip_tilelink_uncached_master_sequence)
  `uvm_declare_p_sequencer(pzvip_tilelink_master_sequencer)
endclass
`endif
