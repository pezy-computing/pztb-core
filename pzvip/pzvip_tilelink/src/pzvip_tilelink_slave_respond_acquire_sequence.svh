`ifndef PZVIP_TILELINK_SLAVE_RESPOND_ACQUIRE_SEQUENCE_SVH
`define PZVIP_TILELINK_SLAVE_RESPOND_ACQUIRE_SEQUENCE_SVH
class pzvip_tilelink_slave_respond_acquire_sequence extends pzvip_tilelink_slave_sequence;
  task body();
    forever begin
      pzvip_tilelink_receiver_message_item  acquire_message;
      wait_for_acquire(acquire_message);
      fork
        process_grant(acquire_message);
      join_none
    end
  endtask

  local task wait_for_acquire(ref pzvip_tilelink_receiver_message_item acquire_message);
    pzvip_tilelink_receiver_message_item  message;
    get_acquire_message(message);
    $cast(acquire_message, message.clone());
    receice_acquire_message(acquire_message);
  endtask

  local task receice_acquire_message(pzvip_tilelink_receiver_message_item acquire_message);
    acquire_message.set_sequencer(a_sequencer);
    `uvm_rand_send(acquire_message)
  endtask

  local task process_grant(pzvip_tilelink_receiver_message_item acquire_message);
    pzvip_tilelink_id id;
    get_id(id);
    fork
      send_grant(acquire_message, id);
      wait_for_grant_ack(id);
    join
    put_id(id);
  endtask

  local task send_grant(pzvip_tilelink_receiver_message_item acquire_message, int id);
    pzvip_tilelink_sender_message_item  grant_message;
    `uvm_create_on(grant_message, d_sequencer)
    grant_message.related_request = acquire_message;
    `uvm_rand_send_with(grant_message, {
      sink == id;
    })
  endtask

  local task wait_for_grant_ack(int id);
    pzvip_tilelink_receiver_message_item  grant_ack_message;
    get_grant_ack_message(id, grant_ack_message);
    receive_grant_ack_message(grant_ack_message);
  endtask

  local task receive_grant_ack_message(pzvip_tilelink_receiver_message_item grant_ack_message);
    pzvip_tilelink_receiver_message_item  message;
    $cast(message, grant_ack_message.clone());
    message.set_sequencer(e_sequencer);
    `uvm_rand_send(message)
    grant_ack_message.end_event.wait_on();
  endtask

  `tue_object_default_constructor(pzvip_tilelink_slave_respond_acquire_sequence)
  `uvm_object_utils(pzvip_tilelink_slave_respond_acquire_sequence)
endclass
`endif
