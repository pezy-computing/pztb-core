`ifndef PZVIP_TILELINK_SLAVE_PROBE_SEQUENCE_SVH
`define PZVIP_TILELINK_SLAVE_PROBE_SEQUENCE_SVH
class pzvip_tilelink_slave_probe_sequence extends pzvip_tilelink_slave_sequence;
  rand  int                                 size;
  rand  pzvip_tilelink_address              address;
  rand  pzvip_tilelink_mask                 mask;
  rand  pzvip_tilelink_source               target_master;
  rand  pzvip_tilelink_permission_transfer  request_transfer;
        pzvip_tilelink_permission_transfer  result_transfer;
        pzvip_tilelink_data                 data[];
  rand  int                                 probe_gap_delay;
  rand  int                                 probe_ack_ready_delay[];

  constraint c_valid_size {
    size inside {[1:this.configuration.max_size]};
    $countones(size) == 1;
  }

  constraint c_valid_address {
    solve size before address;
    (address >> this.configuration.address_width) == 0;
    (address % size) == 0;
  }

  constraint c_valid_mask {
    solve size, address before mask;
    mask == get_mask(size, address, this.configuration.byte_width);
  }

  constraint c_valid_target_master {
    target_master < 2**this.configuration.sink_width;
    (target_master & ((1 << this.configuration.tag_width) - 1)) == 0;
  }

  constraint c_valid_request_transfer {
    request_transfer inside {
      PZVIP_TILELINK_TO_T,
      PZVIP_TILELINK_TO_B,
      PZVIP_TILELINK_TO_N
    };
  }

  `pzvip_tilelink_delay_constraint(probe_gap_delay, this.configuration.gap_delay)
  `pzvip_tilelink_array_delay_constraint(probe_ack_ready_delay, this.configuration.ready_delay)

  task body();
    pzvip_tilelink_id id;
    get_id(id, target_master);
    send_probe_message(id);
    wait_for_probe_ack_message(id);
    put_id(id);
  endtask

  local task send_probe_message(pzvip_tilelink_id id);
    pzvip_tilelink_sender_message_item  probe_message;

    `uvm_create_on(probe_message, b_sequencer)
    probe_message.opcode              = PZVIP_TILELINK_PROBE;
    probe_message.size                = size;
    probe_message.source              = id;
    probe_message.address             = address;
    probe_message.mask                = new[1];
    probe_message.mask[0]             = mask;
    probe_message.permission_transfer = request_transfer;
    probe_message.gap_delay           = new[1];
    probe_message.gap_delay[0]        = probe_gap_delay;

    `uvm_send(probe_message)
  endtask

  local task wait_for_probe_ack_message(pzvip_tilelink_id id);
    pzvip_tilelink_receiver_message_item  probe_ack_message;
    pzvip_tilelink_receiver_message_item  message;

    get_probe_ack_message(id, probe_ack_message);

    $cast(message, probe_ack_message.clone());
    message.set_sequencer(c_sequencer);
    if (message.has_data()) begin
      message.ready_delay = new[probe_ack_ready_delay.size](probe_ack_ready_delay);
    end
    else begin
      message.ready_delay     = new[1];
      message.ready_delay[0]  = probe_ack_ready_delay[0];
    end
    `uvm_send(message)

    probe_ack_message.end_event.wait_on();
    result_transfer = probe_ack_message.permission_transfer;
    if (probe_ack_message.has_data()) begin
      data  = new[probe_ack_message.data.size](probe_ack_message.data);
    end
  endtask

  `tue_object_default_constructor(pzvip_tilelink_slave_probe_sequence)
  `uvm_object_utils_begin(pzvip_tilelink_slave_probe_sequence)
    `uvm_field_int(size, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(address, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(mask, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(target_master, UVM_DEFAULT | UVM_HEX)
    `uvm_field_enum(pzvip_tilelink_permission_transfer, request_transfer, UVM_DEFAULT)
    `uvm_field_enum(pzvip_tilelink_permission_transfer, result_transfer, UVM_DEFAULT)
    `uvm_field_array_int(data, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(probe_gap_delay, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
    `uvm_field_array_int(probe_ack_ready_delay, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
  `uvm_object_utils_end
endclass
`endif
