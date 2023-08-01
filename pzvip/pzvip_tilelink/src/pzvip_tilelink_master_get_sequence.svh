`ifndef PZVIP_TILELINK_MASTER_GET_SEQUENCE_SVH
`define PZVIP_TILELINK_MASTER_GET_SEQUENCE_SVH
class pzvip_tilelink_master_get_sequence extends pzvip_tilelink_master_sequence;
  rand  int                     size;
  rand  pzvip_tilelink_address  address;
  rand  pzvip_tilelink_mask     mask;
        pzvip_tilelink_data     data[];
  rand  int                     gap_delay;
  rand  int                     ready_delay[];

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

  `pzvip_tilelink_delay_constraint(gap_delay, this.configuration.gap_delay)
  `pzvip_tilelink_array_delay_constraint(ready_delay, this.configuration.ready_delay)

  task body();
    pzvip_tilelink_id id;
    get_id(id);
    fork
      send_get(id);
      wait_for_access_ack(id);
    join
    put_id(id);
  endtask

  local task send_get(pzvip_tilelink_id id);
    pzvip_tilelink_sender_message_item  message_item;

    `uvm_create_on(message_item, a_sequencer)
    message_item.opcode       = PZVIP_TILELINK_GET;
    message_item.source       = id;
    message_item.address      = address;
    message_item.size         = size;
    message_item.mask         = new[1];
    message_item.mask[0]      = mask;
    message_item.gap_delay    = new[1];
    message_item.gap_delay[0] = gap_delay;

    `uvm_send(message_item)
  endtask

  local task wait_for_access_ack(pzvip_tilelink_id id);
    pzvip_tilelink_receiver_message_item  access_ack;
    get_access_ack_message(id, access_ack);
    receive_access_ack(access_ack);
    data  = new[access_ack.data.size](access_ack.data);
  endtask

  local task receive_access_ack(pzvip_tilelink_receiver_message_item access_ack);
    pzvip_tilelink_receiver_message_item  message;

    $cast(message, access_ack.clone());
    message.ready_delay = new[ready_delay.size](ready_delay);
    message.set_sequencer(d_sequencer);
    `uvm_send(message)

    access_ack.end_event.wait_on();
  endtask

  `tue_object_default_constructor(pzvip_tilelink_master_get_sequence)
  `uvm_object_utils_begin(pzvip_tilelink_master_get_sequence)
    `uvm_field_int(size, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(address, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(mask, UVM_DEFAULT | UVM_HEX)
    `uvm_field_array_int(data, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(gap_delay, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
    `uvm_field_array_int(ready_delay, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
  `uvm_object_utils_end
endclass
`endif
