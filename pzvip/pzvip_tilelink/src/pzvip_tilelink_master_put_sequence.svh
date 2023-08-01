`ifndef PZVIP_TILELINK_MASTER_PUT_SEQUENCE_SVH
`define PZVIP_TILELINK_MASTER_PUT_SEQUENCE_SVH
class pzvip_tilelink_master_put_sequence extends pzvip_tilelink_master_sequence;
  rand  bit                     full_write;
  rand  int                     size;
  rand  pzvip_tilelink_address  address;
  rand  pzvip_tilelink_mask     mask[];
  rand  pzvip_tilelink_data     data[];
  rand  int                     gap_delay[];
  rand  int                     ready_delay;

  constraint c_valid_size {
    size inside {[1:this.configuration.max_size]};
    $countones(size) == 1;
  }

  constraint c_valid_address {
    solve size before address;
    (address % size) == 0;
  }

  constraint c_valid_mask {
    solve full_write, size, address before mask;
    mask.size == `pzvip_tilelink_get_number_of_beats(size, this.configuration.byte_width);
    if (full_write) {
      foreach (mask[i]) {
        soft mask[i] == `pzvip_tilelink_get_mask(size, address, this.configuration.byte_width);
      }
    }
  }

  constraint c_valid_data {
    solve size before data;
    data.size == get_number_of_beats(size, this.configuration.byte_width);
  }

  `pzvip_tilelink_array_delay_constraint(gap_delay, this.configuration.gap_delay)
  `pzvip_tilelink_delay_constraint(ready_delay, this.configuration.ready_delay)

  task body();
    pzvip_tilelink_id id;
    get_id(id);
    fork
      send_put(id);
      wait_for_access_ack(id);
    join
    put_id(id);
  endtask

  local task send_put(pzvip_tilelink_id id);
    pzvip_tilelink_sender_message_item  message_item;

    `uvm_create_on(message_item, a_sequencer)
    message_item.opcode     = (full_write) ? PZVIP_TILELINK_PUT_FULL_DATA
                                           : PZVIP_TILELINK_PUT_PARTIAL_DATA;
    message_item.source     = id;
    message_item.address    = address;
    message_item.size       = size;
    message_item.mask       = new[mask.size](mask);
    message_item.data       = new[data.size](data);
    message_item.gap_delay  = new[gap_delay.size](gap_delay);

    `uvm_send(message_item)
  endtask

  local task wait_for_access_ack(pzvip_tilelink_id id);
    pzvip_tilelink_receiver_message_item  access_ack;
    get_access_ack_message(id, access_ack);
    receive_access_ack(access_ack);
  endtask

  local task receive_access_ack(pzvip_tilelink_receiver_message_item access_ack);
    pzvip_tilelink_receiver_message_item  message;

    $cast(message, access_ack.clone());
    message.ready_delay     = new[1];
    message.ready_delay[0]  = ready_delay;
    message.set_sequencer(d_sequencer);
    `uvm_send(message)

    access_ack.end_event.wait_on();
  endtask

  `tue_object_default_constructor(pzvip_tilelink_master_put_sequence)
  `uvm_object_utils_begin(pzvip_tilelink_master_put_sequence)
    `uvm_field_int(full_write, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(size, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(address, UVM_DEFAULT | UVM_HEX)
    `uvm_field_array_int(mask, UVM_DEFAULT | UVM_HEX)
    `uvm_field_array_int(data, UVM_DEFAULT | UVM_HEX)
    `uvm_field_array_int(gap_delay, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
    `uvm_field_int(ready_delay, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
  `uvm_object_utils_end
endclass
`endif
