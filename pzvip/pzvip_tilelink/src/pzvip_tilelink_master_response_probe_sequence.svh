`ifndef PZVIP_TILELINK_MASTER_RESPONSE_PROBE_SEQUENCE_SVH
`define PZVIP_TILELINK_MASTER_RESPONSE_PROBE_SEQUENCE_SVH
class pzvip_tilelink_master_response_probe_sequence extends pzvip_tilelink_master_sequence;
  task body();
    forever begin
      pzvip_tilelink_receiver_message_item  probe_message;
      wait_for_probe_message(probe_message);
      fork
        send_probe_ack_message(probe_message);
      join_none
    end
  endtask

  local task wait_for_probe_message(ref pzvip_tilelink_receiver_message_item probe_message);
    pzvip_tilelink_receiver_message_item  message;
    get_probe_message(message);
    $cast(probe_message, message.clone());
    probe_message.set_sequencer(b_sequencer);
    `uvm_rand_send(probe_message)
  endtask

  local task send_probe_ack_message(pzvip_tilelink_receiver_message_item probe_message);
    pzvip_tilelink_sender_message_item  probe_ack_message;
    `uvm_create_on(probe_ack_message, c_sequencer)
    probe_ack_message.related_request = probe_message;
    `uvm_rand_send(probe_ack_message)
  endtask

  `tue_object_default_constructor(pzvip_tilelink_master_response_probe_sequence)
  `uvm_object_utils(pzvip_tilelink_master_response_probe_sequence)
endclass
`endif
