`ifndef PZVIP_TILELINK_MASTER_RELEASE_SEQUENCE_SVH
`define PZVIP_TILELINK_MASTER_RELEASE_SEQUENCE_SVH
class pzvip_tilelink_master_release_sequence extends pzvip_tilelink_master_sequence;
  rand  int                                 size;
  rand  pzvip_tilelink_address              address;
  rand  pzvip_tilelink_permission_transfer  request_transfer;
  rand  bit                                 with_data;
  rand  pzvip_tilelink_data                 data[];
  rand  int                                 release_gap_delay[];
  rand  int                                 release_ack_raedy_delay;

  constraint c_valid_size {
    size inside {[1:this.configuration.max_size]};
    $countones(size) == 1;
  }

  constraint c_valid_address {
    solve size before address;
   (address % size) == 0;
  }

  constraint c_valid_request_transfer {
    request_transfer inside {
      PZVIP_TILELINK_T_TO_B,
      PZVIP_TILELINK_T_TO_N,
      PZVIP_TILELINK_B_TO_N,
      PZVIP_TILELINK_T_TO_T,
      PZVIP_TILELINK_B_TO_B,
      PZVIP_TILELINK_N_TO_N
    };
  }

  constraint c_valid_data {
    solve with_data, size before data;
    if (with_data) {
      data.size == get_number_of_beats(size, this.configuration.byte_width);
    }
    else {
      data.size == 0;
    }
    foreach (data[i]) {
      (data[i] >> this.configuration.data_width) == 0;
    }
  }

  `pzvip_tilelink_array_delay_constraint(release_gap_delay, this.configuration.gap_delay, with_data)
  `pzvip_tilelink_delay_constraint(release_ack_raedy_delay, this.configuration.ready_delay)

  task body();
    pzvip_tilelink_id id;
    get_id(id);
    fork
      send_release_message(id);
      wait_for_release_ack_message(id);
    join
    put_id(id);
  endtask

  local task send_release_message(pzvip_tilelink_id id);
    pzvip_tilelink_sender_message_item  release_message;

    `uvm_create_on(release_message, c_sequencer)
    release_message.opcode    = (with_data) ? PZVIP_TILELINK_RELEASE_DATA
                                            : PZVIP_TILELINK_RELEASE;
    release_message.size      = size;
    release_message.source    = id;
    release_message.address   = address;
    release_message.gap_delay = new[release_gap_delay.size](release_gap_delay);
    if (with_data) begin
      release_message.data  = new[data.size](data);
    end

    `uvm_send(release_message)
  endtask

  local task wait_for_release_ack_message(pzvip_tilelink_id id);
    pzvip_tilelink_receiver_message_item  release_ack_message;
    pzvip_tilelink_receiver_message_item  message;

    get_release_ack_message(id, release_ack_message);

    $cast(message, release_ack_message.clone());
    message.set_sequencer(d_sequencer);
    message.ready_delay     = new[1];
    message.ready_delay[0]  = release_ack_raedy_delay;
    `uvm_send(message)

    release_ack_message.end_event.wait_on();
  endtask

  `tue_object_default_constructor(pzvip_tilelink_master_release_sequence)
  `uvm_object_utils_begin(pzvip_tilelink_master_release_sequence)
    `uvm_field_int(size, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(address, UVM_DEFAULT | UVM_HEX)
    `uvm_field_enum(pzvip_tilelink_permission_transfer, request_transfer, UVM_DEFAULT)
    `uvm_field_int(with_data, UVM_DEFAULT | UVM_BIN)
    `uvm_field_array_int(data, UVM_DEFAULT | UVM_HEX)
    `uvm_field_array_int(release_gap_delay, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
    `uvm_field_int(release_ack_raedy_delay, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
  `uvm_object_utils_end
endclass
`endif
