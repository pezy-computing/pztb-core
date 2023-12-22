`ifndef PZVIP_COREBUS_ITEM_SVH
`define PZVIP_COREBUS_ITEM_SVH
class pzvip_corebus_item extends tue_sequence_item #(
  .CONFIGURATION  (pzvip_corebus_configuration  ),
  .STATUS         (pzvip_corebus_status         )
);
  rand  pzvip_corebus_command_type  command;
  rand  pzvip_corebus_id            id;
  rand  pzvip_corebus_address       address;
  rand  int                         length;
  rand  int                         burst_length;
  rand  pzvip_corebus_message_code  message_code;
  rand  pzvip_corebus_request_info  request_info;
  rand  pzvip_corebus_data          request_data[];
  rand  pzvip_corebus_byte_enable   byte_enable[];
  rand  pzvip_corebus_response_type response_type;
  rand  bit                         error[];
  rand  pzvip_corebus_data          response_data[];
  rand  pzvip_corebus_response_info response_info[];
  rand  int                         start_delay;
  rand  int                         data_delay[];
  rand  int                         response_delay[];
  rand  int                         command_accept_delay;
  rand  int                         data_accept_delay[];
  rand  int                         response_accept_delay[];
        uvm_event                   command_begin_event;
        time                        command_begin_time;
        uvm_event                   command_end_event;
        time                        command_end_time;
        uvm_event                   data_begin_event;
        time                        data_begin_time;
        uvm_event                   data_end_event;
        time                        data_end_time;
        uvm_event                   response_begin_event;
        time                        response_begin_time;
        uvm_event                   response_end_event;
        time                        response_end_time;
        bit                         drop_response;
  rand  bit                         use_response_port;

  constraint c_default_use_response_port {
    soft use_response_port == 0;
  }

  function new(string name = "pzvip_corebus_item");
    super.new(name);
    command_begin_event   = get_event("command_begn");
    command_begin_time    = 0;
    command_end_event     = get_event("command_end");
    command_end_time      = 0;
    data_begin_event      = get_event("data_begn");
    data_begin_time       = 0;
    data_end_event        = get_event("data_end");
    data_end_time         = 0;
    response_begin_event  = get_event("response_begn");
    response_begin_time   = 0;
    response_end_event    = get_event("response_end");
    response_end_time     = 0;
  endfunction

  virtual function void do_copy(uvm_object rhs);
    pzvip_corebus_item  rhs_item;
    super.do_copy(rhs);
    void'($cast(rhs_item, rhs));
    command_begin_event   = rhs_item.command_begin_event;
    command_end_event     = rhs_item.command_end_event;
    data_begin_event      = rhs_item.data_begin_event;
    data_end_event        = rhs_item.data_end_event;
    response_begin_event  = rhs_item.response_begin_event;
    response_end_event    = rhs_item.response_end_event;
  endfunction

  function bit is_request_with_data();
    return is_command_with_data(command);
  endfunction

  function bit is_no_data_request();
    return is_no_data_command(command);
  endfunction

  function bit is_non_posted_request();
    return is_non_posted_command(command);
  endfunction

  function bit is_posted_request();
    return is_posted_command(command);
  endfunction

  function bit is_read_request();
    return is_read_command(command);
  endfunction

  function bit is_write_request();
    return is_write_command(command);
  endfunction

  function bit is_atomic_request();
    return is_atomic_command(command);
  endfunction

  function bit is_message_request();
    return is_message_command(command);
  endfunction

  function bit has_error();
    foreach (error[i]) begin
      if (error[i]) begin
        return 1;
      end
    end
    return 0;
  endfunction

  function bit needs_response();
    return is_non_posted_request();
  endfunction

  function bit needs_response_data();
    return is_response_with_data(command);
  endfunction

  function void put_command(ref pzvip_corebus_command_item item);
    command = item.command;
    id      = item.id;
    address = item.address;
    if (configuration.profile == PZVIP_COREBUS_CSR) begin
      length        = 0;
      message_code  = '0;
      if (is_write_request()) begin
        request_data    = new[1];
        request_data[0] = item.data;
        if (configuration.use_byte_enable) begin
          byte_enable     = new[1];
          byte_enable[0]  = item.byte_enable;
        end
      end
    end
    else if (is_message_request()) begin
      length        = 0;
      message_code  = item.message_code;
    end
    else begin
      length        = item.length;
      message_code  = '0;
    end
    if (configuration.request_info_width > 0) begin
      request_info  = item.info;
    end
  endfunction

  function void put_request_data(const ref pzvip_corebus_request_data_item items[$]);
    request_data  = new[items.size()];
    if (configuration.use_byte_enable) begin
      byte_enable = new[items.size()];
    end

    foreach (items[i]) begin
      request_data[i] = items[i].data;
      if (byte_enable.size() > 0) begin
        byte_enable[i]  = items[i].byte_enable;
      end
    end
  endfunction

  function pzvip_corebus_data get_request_data(int index);
    return request_data[index];
  endfunction

  function pzvip_corebus_byte_enable get_byte_enable(int index);
    if (configuration.use_byte_enable) begin
      return byte_enable[index];
    end
    else begin
      return (1 << (configuration.data_width / 8)) - 1;
    end
  endfunction

  function void put_response(const ref pzvip_corebus_response_item items[$]);
    response_type = items[0].response_type;
    error         = new[items.size()];
    if (response_type == PZVIP_COREBUS_RESPONSE_WITH_DATA) begin
      response_data = new[items.size()];
    end
    if (configuration.response_info_width > 0) begin
      response_info = new[items.size()];
    end

    foreach (items[i]) begin
      error[i]  = items[i].error;
      if (response_data.size() > 0) begin
        response_data[i]  = items[i].data;
      end
      if (response_info.size() > 0) begin
        response_info[i]  = items[i].info;
      end
    end
  endfunction

  function logic get_error(int index);
    return error[index];
  endfunction

  function pzvip_corebus_data get_response_data(int index);
    return response_data[index];
  endfunction

  function pzvip_corebus_response_info get_response_info(int index);
    return response_info[index];
  endfunction

  function int pack_length();
    if (length == configuration.max_length) begin
      return 0;
    end
    else begin
      return length;
    end
  endfunction

  function void unpack_length(int packed_length);
    if (packed_length == 0) begin
      length  = configuration.max_length;
    end
    else begin
      length  = packed_length;
    end
  endfunction

  function int get_burst_length();
    if ((burst_length == 0) && (!is_message_command(command))) begin
      burst_length  = calc_burst_length(configuration, command, address, length);
    end
    return burst_length;
  endfunction

  `define pzvip_corebus_declare_begin_end_api(EVENT) \
  function void begin_``EVENT(time begin_time = 0); \
    if (EVENT``_begin_event.is_off()) begin \
      EVENT``_begin_time  = (begin_time == 0) ? `tue_current_time : begin_time; \
      EVENT``_begin_event.trigger(); \
    end \
  endfunction \
  function void end_``EVENT(time end_time = 0); \
    if (EVENT``_end_event.is_off()) begin \
      EVENT``_end_time  = (end_time == 0) ? `tue_current_time : end_time; \
      EVENT``_end_event.trigger(); \
    end \
  endfunction \
  function bit EVENT``_began(); \
    return EVENT``_begin_event.is_on(); \
  endfunction \
  function bit EVENT``_ended(); \
    return EVENT``_end_event.is_on(); \
  endfunction

  `pzvip_corebus_declare_begin_end_api(command)
  `pzvip_corebus_declare_begin_end_api(data)
  `pzvip_corebus_declare_begin_end_api(response)

  `undef  pzvip_corebus_declare_begin_end_api

  function time get_request_begin_time();
    if (configuration.profile == PZVIP_COREBUS_CSR) begin
      return command_begin_time;
    end
    else if (data_begin_time == 0) begin
      return command_begin_time;
    end
    else if (command_begin_time == 0) begin
      return data_begin_time;
    end
    else if (command_begin_time < data_begin_time) begin
      return command_begin_time;
    end
    else begin
      return data_begin_time;
    end
  endfunction

  function time get_request_end_time();
    if (configuration.profile == PZVIP_COREBUS_CSR) begin
      return command_end_time;
    end
    else if (is_no_data_request()) begin
      return command_end_time;
    end
    else begin
      return (command_end_time > data_end_time) ? command_end_time : data_end_time;
    end
  endfunction

  function bit request_ended();
    if ((configuration.profile != PZVIP_COREBUS_CSR) && is_request_with_data()) begin
      return command_ended() && data_ended();
    end
    begin
      return command_ended();
    end
  endfunction

  task wait_for_request_done();
    command_end_event.wait_on();
    if ((configuration.profile != PZVIP_COREBUS_CSR) && is_request_with_data()) begin
      data_end_event.wait_on();
    end
  endtask

  task wait_for_done();
    if (is_non_posted_request()) begin
      response_end_event.wait_on();
    end
    else begin
      wait_for_request_done();
    end
  endtask

  `uvm_object_utils_begin(pzvip_corebus_item)
    `uvm_field_enum(pzvip_corebus_command_type, command, UVM_DEFAULT | UVM_ENUM)
    `uvm_field_int(id, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(address, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(length, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(burst_length, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
    `uvm_field_int(message_code, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(request_info, UVM_DEFAULT | UVM_HEX)
    `uvm_field_array_int(request_data, UVM_DEFAULT | UVM_HEX)
    `uvm_field_array_int(byte_enable, UVM_DEFAULT | UVM_HEX)
    `uvm_field_enum(pzvip_corebus_response_type, response_type, UVM_DEFAULT | UVM_ENUM)
    `uvm_field_array_int(error, UVM_DEFAULT | UVM_BIN)
    `uvm_field_array_int(response_data, UVM_DEFAULT | UVM_HEX)
    `uvm_field_array_int(response_info, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(start_delay, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
    `uvm_field_array_int(data_delay, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
    `uvm_field_array_int(response_delay, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
    `uvm_field_int(command_accept_delay, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
    `uvm_field_array_int(data_accept_delay, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
    `uvm_field_array_int(response_accept_delay, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
    `uvm_field_int(command_begin_time, UVM_DEFAULT | UVM_TIME | UVM_NOCOMPARE)
    `uvm_field_int(command_end_time, UVM_DEFAULT | UVM_TIME | UVM_NOCOMPARE)
    `uvm_field_int(data_begin_time, UVM_DEFAULT | UVM_TIME | UVM_NOCOMPARE)
    `uvm_field_int(data_end_time, UVM_DEFAULT | UVM_TIME | UVM_NOCOMPARE)
    `uvm_field_int(response_begin_time, UVM_DEFAULT | UVM_TIME | UVM_NOCOMPARE)
    `uvm_field_int(response_end_time, UVM_DEFAULT | UVM_TIME | UVM_NOCOMPARE)
    `uvm_field_int(drop_response, UVM_COPY)
    `uvm_field_int(use_response_port, UVM_COPY)
  `uvm_object_utils_end
endclass

class pzvip_corebus_master_item extends pzvip_corebus_item;
  constraint c_valid_command {
    if (this.configuration.profile == PZVIP_COREBUS_CSR) {
      command != PZVIP_COREBUS_NULL;
      command != PZVIP_COREBUS_ATOMIC;
      command != PZVIP_COREBUS_ATOMIC_NON_POSTED;
      command != PZVIP_COREBUS_MESSAGE;
      command != PZVIP_COREBUS_MESSAGE_NON_POSTED;
    }
    else {
      command != PZVIP_COREBUS_NULL;
      command != PZVIP_COREBUS_BROADCAST;
      command != PZVIP_COREBUS_BROADCAST_NON_POSTED;
    }
  }

  constraint c_valid_id {
    (id >> this.configuration.id_width) == 0;
  }

  constraint c_valid_address {
    solve command before address;

    (address >> this.configuration.address_width) == 0;
    if ((this.configuration.profile != PZVIP_COREBUS_CSR) && is_full_write_command(command)) {
      (address % (this.configuration.data_width / 8) == 0);
    }
  }

  constraint c_valid_length {
    solve command before length;

    if (this.configuration.profile == PZVIP_COREBUS_CSR) {
      length == 1;
    }
    else if (is_message_command(command)) {
      length == 0;
    }
    else {
      length inside {[1:this.configuration.max_length]};
    }

    if ((this.configuration.profile != PZVIP_COREBUS_CSR) && is_full_write_command(command)) {
      (length % this.configuration.data_size) == 0;
    }
  }

  constraint c_valid_burst_length {
    solve command, address before burst_length;

    if (this.configuration.profile == PZVIP_COREBUS_CSR) {
      burst_length == length;
    }
    else if (is_atomic_command(command)) {
      burst_length == (length + (this.configuration.data_size - 1)) / this.configuration.data_size;
    }
    else if (is_message_command(command)) {
      burst_length == 0;
    }
    else {
      burst_length == (
          length +
          ((address >> this.configuration.address_shift) % this.configuration.data_size) +
          (this.configuration.data_size - 1)
        ) / this.configuration.data_size;
    }
  }

  constraint c_valid_message_code {
    solve command before message_code;
    if (is_message_command(command)) {
      (message_code >> this.configuration.message_code_width) == 0;
    }
    else {
      message_code == 0;
    }
  }

  constraint c_valid_request_info {
    (request_info >> this.configuration.request_info_width) == 0;
  }

  constraint c_valid_request_data {
    solve command, burst_length before request_data;
    if (is_command_with_data(command)) {
      request_data.size == burst_length;
    }
    else {
      request_data.size == 0;
    }
    foreach (request_data[i]) {
      (request_data[i] >> this.configuration.data_width) == 0;
    }
  }

  constraint c_valid_byte_enable {
    solve command, burst_length before byte_enable;

    if (!this.configuration.use_byte_enable) {
      byte_enable.size == 0;
    }
    else if (is_command_with_data(command)) {
      byte_enable.size == burst_length;
    }
    else {
      byte_enable.size == 0;
    }

    if (is_full_write_command(command)) {
      foreach (byte_enable[i]) {
        byte_enable[i] == ((1 << this.configuration.byte_enable_width) - 1);
      }
    }
    else {
      foreach (byte_enable[i]) {
        (byte_enable[i] >> this.configuration.byte_enable_width) == 0;
      }
    }
  }

  constraint c_valid_start_delay {
    `pzvip_delay_constraint(
      start_delay, this.configuration.request_start_delay
    )
  }

  constraint c_valid_data_delay {
    solve command, burst_length before data_delay;
    if (this.configuration.profile == PZVIP_COREBUS_CSR) {
      data_delay.size == 0;
    }
    else if (is_command_with_data(command)) {
      data_delay.size == burst_length;
    }
    else {
      data_delay.size == 0;
    }
    `pzvip_array_delay_constraint(
      data_delay, this.configuration.data_delay
    )
  }

  constraint c_valid_response_accept_delay {
    solve command, length before response_accept_delay;
    if (is_posted_command(command)) {
      response_accept_delay.size == 0;
    }
    else if (command == PZVIP_COREBUS_WRITE_NON_POSTED) {
      response_accept_delay.size == 1;
    }
    else if (command == PZVIP_COREBUS_MESSAGE_NON_POSTED) {
      response_accept_delay.size == 1;
    }
    else {
      response_accept_delay.size == burst_length;
    }
    `pzvip_array_delay_constraint(
      response_accept_delay, this.configuration.response_accept_delay
    )
  }

  function void pre_randomize();
    super.pre_randomize();
    response_type.rand_mode(0);
    error.rand_mode(0);
    response_data.rand_mode(0);
    response_info.rand_mode(0);
    response_delay.rand_mode(0);
    command_accept_delay.rand_mode(0);
    data_accept_delay.rand_mode(0);
  endfunction

  `tue_object_default_constructor(pzvip_corebus_master_item)
  `uvm_object_utils(pzvip_corebus_master_item)
endclass

class pzvip_corebus_slave_item extends pzvip_corebus_item;
  constraint c_default_response_type {
    if (is_response_with_data(command)) {
      soft response_type == PZVIP_COREBUS_RESPONSE_WITH_DATA;
    }
    else {
      soft response_type == PZVIP_COREBUS_RESPONSE;
    }
  }

  constraint c_valid_error_size {
    if (is_posted_command(command)) {
      error.size() == 0;
    }
    else if (response_type == PZVIP_COREBUS_RESPONSE_WITH_DATA) {
      error.size() == burst_length;
    }
    else {
      error.size() == 1;
    }
  }

  constraint c_default_error_value {
    foreach (error[i]) {
      error[i] dist {
        0 := this.configuration.weight_no_error,
        1 := this.configuration.weight_error
      };
    }
  }

  constraint c_valid_response_data {
    solve response_type before response_data;
    if (response_type == PZVIP_COREBUS_RESPONSE_WITH_DATA) {
      response_data.size() == burst_length;
    }
    else {
      response_data.size() == 0;
    }
    foreach (response_data[i]) {
      (response_data[i] >> this.configuration.data_width) == 0;
    }
  }

  constraint c_valid_response_info {
    solve response_type before response_info;
    if (this.configuration.response_info_width > 0) {
      if (is_posted_command(command)) {
        response_info.size() == 0;
      }
      else if (response_type == PZVIP_COREBUS_RESPONSE_WITH_DATA) {
        response_info.size() == burst_length;
      }
      else {
        response_info.size() == 1;
      }
    }
    else {
      response_info.size() == 0;
    }
    foreach (response_info[i]) {
      (response_info[i] >> this.configuration.response_info_width) == 0;
    }
  }

  constraint c_default_response_info {
    foreach (response_info[i]) {
      if (i > 0) {
        soft response_info[i] == response_info[i-1];
      }
    }
  }

  constraint c_valid_start_delay {
    `pzvip_delay_constraint(
      start_delay, this.configuration.response_start_delay
    )
  }

  constraint c_valid_response_delay {
    solve response_type before response_delay;
    if (is_posted_command(command)) {
      response_delay.size() == 0;
    }
    else if (response_type == PZVIP_COREBUS_RESPONSE_WITH_DATA) {
      response_delay.size == burst_length;
    }
    else {
      response_delay.size == 1;
    }
    `pzvip_array_delay_constraint(
      response_delay, this.configuration.response_delay
    )
  }

  constraint c_valid_command_accept_delay {
    `pzvip_delay_constraint(
      command_accept_delay, this.configuration.command_accept_delay
    )
  }

  constraint c_valid_data_accept_delay {
    if (this.configuration.profile == PZVIP_COREBUS_CSR) {
      data_accept_delay.size() == 0;
    }
    else if (is_command_with_data(command)) {
      data_accept_delay.size() == burst_length;
    }
    else {
      data_accept_delay.size() == 0;
    }
    `pzvip_array_delay_constraint(
      data_accept_delay, this.configuration.data_accept_delay
    )
  }

  function void pre_randomize();
    super.pre_randomize();
    command.rand_mode(0);
    id.rand_mode(0);
    address.rand_mode(0);
    length.rand_mode(0);
    burst_length.rand_mode(0);
    message_code.rand_mode(0);
    request_info.rand_mode(0);
    request_data.rand_mode(0);
    byte_enable.rand_mode(0);
    data_delay.rand_mode(0);
    response_accept_delay.rand_mode(0);
    void'(get_burst_length());
  endfunction

  `tue_object_default_constructor(pzvip_corebus_slave_item)
  `uvm_object_utils(pzvip_corebus_slave_item)
endclass
`endif
