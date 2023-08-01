`ifndef PZVIP_TILELINK_MASTER_ACQUIRE_SEQUENCE_SVH
`define PZVIP_TILELINK_MASTER_ACQUIRE_SEQUENCE_SVH
class pzvip_tilelink_master_acquire_sequence extends pzvip_tilelink_master_sequence;
  rand  int                                 size;
  rand  pzvip_tilelink_address              address;
  rand  pzvip_tilelink_mask                 mask;
  rand  bit                                 need_data;
  rand  pzvip_tilelink_permission_transfer  request_transfer;
        pzvip_tilelink_permission_transfer  result_transfer;
        pzvip_tilelink_data                 data[];
  rand  int                                 acquire_gap_delay;
  rand  int                                 grant_ready_delay[];
  rand  int                                 grant_ack_gap_delay;

  constraint c_valid_size {
    size inside {[1:this.configuration.max_size]};
    $countones(size) == 1;
  }

  constraint c_valid_address {
    solve size before address;
   (address % size) == 0;
  }

  constraint c_valid_mask {
    solve size, address before mask;
    mask == get_mask(size, address, this.configuration.byte_width);
  }

  constraint c_valid_request_transfer {
    request_transfer inside {
      PZVIP_TILELINK_N_TO_B,
      PZVIP_TILELINK_N_TO_T,
      PZVIP_TILELINK_B_TO_T
    };
  }

  `pzvip_tilelink_delay_constraint(acquire_gap_delay, this.configuration.gap_delay)
  `pzvip_tilelink_array_delay_constraint(grant_ready_delay, this.configuration.ready_delay)
  `pzvip_tilelink_delay_constraint(grant_ack_gap_delay, this.configuration.gap_delay)

  constraint c_grant_ready_delay_valid_size {
    if (!need_data) {
      grant_ready_delay.size == 1;
    }
  }

  task body();
    pzvip_tilelink_id id;
    get_id(id);
    send_acquire_message(id);
    wait_for_grant_message(id);
    put_id(id);
  endtask

  local task send_acquire_message(int id);
    pzvip_tilelink_sender_message_item  acquire_message;

    `uvm_create_on(acquire_message, a_sequencer)
    acquire_message.opcode              = (need_data) ? PZVIP_TILELINK_ACQUIRE_BLOCK
                                                      : PZVIP_TILELINK_ACQUIRE_PERM;
    acquire_message.source              = id;
    acquire_message.address             = address;
    acquire_message.size                = size;
    acquire_message.mask                = new[1];
    acquire_message.mask[0]             = mask;
    acquire_message.permission_transfer = request_transfer;
    acquire_message.gap_delay           = new[1];
    acquire_message.gap_delay[0]        = acquire_gap_delay;

    `uvm_send(acquire_message)
  endtask

  local task wait_for_grant_message(int id);
    pzvip_tilelink_receiver_message_item  grant_message;
    get_grant_message(id, grant_message);
    fork
      process_grant_message(grant_message);
      receive_grant_message(grant_message);
    join
  endtask

  local task process_grant_message(pzvip_tilelink_receiver_message_item grant_message);
    pzvip_tilelink_receiver_message_item  message;

    $cast(message, grant_message.clone());
    message.set_sequencer(d_sequencer);
    if (message.has_data()) begin
      message.ready_delay = new[grant_ready_delay.size](grant_ready_delay);
    end
    else begin
      message.ready_delay     = new[1];
      message.ready_delay[0]  = grant_ready_delay[0];
    end
    `uvm_send(message)

    send_grant_ack_message(message);
  endtask

  local task receive_grant_message(pzvip_tilelink_receiver_message_item grant_message);
    grant_message.end_event.wait_on();
    result_transfer = grant_message.permission_transfer;
    if (grant_message.has_data()) begin
      data  = new[grant_message.data.size](grant_message.data);
    end
  endtask

  local task send_grant_ack_message(pzvip_tilelink_receiver_message_item grant_message);
    pzvip_tilelink_sender_message_item  grant_ack_message;

    `uvm_create_on(grant_ack_message, e_sequencer)
    grant_ack_message.opcode          = PZVIP_TILELINK_GRANT_ACK;
    grant_ack_message.sink            = grant_message.sink;
    grant_ack_message.gap_delay       = new[1];
    grant_ack_message.gap_delay[0]    = grant_ack_gap_delay;
    grant_ack_message.related_request = grant_message;

    `uvm_send(grant_ack_message)
    grant_ack_message.end_event.wait_on();
  endtask

  `tue_object_default_constructor(pzvip_tilelink_master_acquire_sequence)
  `uvm_object_utils_begin(pzvip_tilelink_master_acquire_sequence)
    `uvm_field_int(size, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(address, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(mask, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(need_data, UVM_DEFAULT | UVM_HEX)
    `uvm_field_enum(pzvip_tilelink_permission_transfer, request_transfer, UVM_DEFAULT)
    `uvm_field_enum(pzvip_tilelink_permission_transfer, result_transfer, UVM_DEFAULT)
    `uvm_field_array_int(data, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(acquire_gap_delay, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
    `uvm_field_array_int(grant_ready_delay, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
    `uvm_field_int(grant_ack_gap_delay, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
  `uvm_object_utils_end
endclass
`endif
