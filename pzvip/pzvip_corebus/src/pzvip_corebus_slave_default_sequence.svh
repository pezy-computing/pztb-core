`ifndef PZVIP_COREBUS_SLAVE_DEFAULT_SEQUENCE_SVH
`define PZVIP_COREBUS_SLAVE_DEFAULT_SEQUENCE_SVH
class pzvip_corebus_slave_default_sequence extends pzvip_corebus_slave_sequence;
  task body();
    pzvip_corebus_slave_item  items[$];
    forever begin
      get_request_items(items);
      while (items.size() > 0) begin
        pzvip_corebus_slave_item  item;
        item  = items.pop_front();
        item.set_item_context(this);
        item  = randomize_response(item);
        execute_response(item);
      end
    end
  endtask

  protected virtual task get_request_items(ref pzvip_corebus_slave_item items[$]);
    pzvip_corebus_slave_item  item;
    get_request(item);
    items.push_back(item);
  endtask

  protected virtual function pzvip_corebus_slave_item randomize_response(
    pzvip_corebus_slave_item  item
  );
    int                         start_delay;
    int                         response_delay[$];
    bit                         error_valid[$];
    bit                         error[$];
    pzvip_corebus_data          data[$];
    bit                         response_info_valid[$];
    pzvip_corebus_response_info response_info[$];
    int                         command_accept_delay;
    int                         data_accept_delay[$];

    start_delay = get_start_delay(item);
    if (item.needs_response_data()) begin
      for (int i = 0;i < item.get_burst_length();++i) begin
        response_delay.push_back(get_response_delay(item, i));
        error_valid.push_back(get_error_valid(item, i));
        error.push_back(get_error(item, i));
        data.push_back(get_data(item, i));
        response_info_valid.push_back(get_response_info_valid(item, i));
        response_info.push_back(get_response_info(item, i));
      end
    end
    else begin
      response_delay.push_back(get_response_delay(item, 0));
      error_valid.push_back(get_error_valid(item, 0));
      error.push_back(get_error(item, 0));
      response_info_valid.push_back(get_response_info_valid(item, 0));
      response_info.push_back(get_response_info(item, 0));
    end

    command_accept_delay  = get_command_accept_delay(item);
    for (int i = 0;i < item.get_burst_length();++i) begin
      data_accept_delay.push_back(get_data_accept_delay(item, i));
    end

    if (!item.randomize() with {
      if (local::start_delay >= 0) {
        start_delay == local::start_delay;
      }
      foreach (response_delay[i]) {
        if (local::response_delay[i] >= 0) {
          response_delay[i] == local::response_delay[i];
        }
      }

      foreach (error[i]) {
        if (local::error_valid[i]) {
          error[i] == local::error[i];
        }
      }
      foreach (response_data[i]) {
        response_data[i] == local::data[i];
      }
      foreach (response_info[i]) {
        if (local::response_info_valid[i]) {
          response_info[i] == local::response_info[i];
        }
      }

      if (local::command_accept_delay >= 0) {
        command_accept_delay == local::command_accept_delay;
      }
      foreach (data_accept_delay[i]) {
        if (local::data_accept_delay[i] >= 0) {
          data_accept_delay[i] == local::data_accept_delay[i];
        }
      }
    }) begin
      `uvm_fatal("RNDFLD", "Randomization failed")
      return null;
    end

    return item;
  endfunction

  protected virtual function int get_start_delay(pzvip_corebus_slave_item item);
    return -1;
  endfunction

  protected virtual function int get_response_delay(pzvip_corebus_slave_item item, int index);
    return -1;
  endfunction

  protected virtual function bit get_error_valid(pzvip_corebus_slave_item item, int index);
    return 0;
  endfunction

  protected virtual function bit get_error(pzvip_corebus_slave_item item, int index);
    return 0;
  endfunction

  protected virtual function pzvip_corebus_data get_data(pzvip_corebus_slave_item item, int index);
    return status.memory.get(
      .base       (item.address                 ),
      .word_index (index                        ),
      .word_width (configuration.data_width / 8 ),
      .backdoor   (0                            )
    );
  endfunction

  protected virtual function bit get_response_info_valid(pzvip_corebus_slave_item item, int index);
    return 0;
  endfunction

  protected virtual function pzvip_corebus_response_info get_response_info(pzvip_corebus_slave_item item, int index);
    return '0;
  endfunction

  protected virtual function int get_command_accept_delay(pzvip_corebus_slave_item item);
    return -1;
  endfunction

  protected virtual function int get_data_accept_delay(pzvip_corebus_slave_item item, int index);
    return -1;
  endfunction

  protected virtual task execute_response(pzvip_corebus_slave_item item);
    `uvm_send(item)
  endtask

  `tue_object_default_constructor(pzvip_corebus_slave_default_sequence)
  `uvm_object_utils(pzvip_corebus_slave_default_sequence)
endclass
`endif
