`ifndef PZVIP_TILELINK_SLAVE_RESPOND_RELEASE_SEQUENCE_SVH
`define PZVIP_TILELINK_SLAVE_RESPOND_RELEASE_SEQUENCE_SVH
class pzvip_tilelink_slave_respond_release_sequence extends pzvip_tilelink_slave_sequence;
  task body();
    forever begin
      pzvip_tilelink_receiver_message_item  release_message;
      wait_for_release_message(release_message);
      fork
        send_release_ack_message(release_message);
      join_none
    end
  endtask

  local task wait_for_release_message(ref pzvip_tilelink_receiver_message_item release_message);
    pzvip_tilelink_receiver_message_item  message;
    get_release_message(message);
    $cast(release_message, message);
    release_message.set_sequencer(c_sequencer);
    `uvm_rand_send(release_message)
  endtask

  local task send_release_ack_message(pzvip_tilelink_receiver_message_item release_message);
    pzvip_tilelink_sender_message_item  release_ack_message;
    `uvm_create_on(release_ack_message, d_sequencer)
    release_ack_message.related_request = release_message;
    `uvm_rand_send(release_ack_message)
  endtask

  `tue_object_default_constructor(pzvip_tilelink_slave_respond_release_sequence)
  `uvm_object_utils(pzvip_tilelink_slave_respond_release_sequence)
endclass
`endif
