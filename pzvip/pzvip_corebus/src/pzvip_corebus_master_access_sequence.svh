`ifndef PZVIP_COREBUS_MASTER_ACCESS_SEQUENCE_SVH
`define PZVIP_COREBUS_MASTER_ACCESS_SEQUENCE_SVH
class pzvip_corebus_master_access_sequence extends pzvip_corebus_master_sequence;
  rand  pzvip_corebus_command_type  command;
  rand  pzvip_corebus_id            id;
  rand  pzvip_corebus_address       address;
  rand  int                         length;
  rand  int                         burst_length;
  rand  pzvip_corebus_message_code  message_code;
  rand  pzvip_corebus_request_info  request_info;
  rand  pzvip_corebus_data          request_data[];
  rand  pzvip_corebus_byte_enable   byte_enable[];
        bit                         error[];
        pzvip_corebus_data          response_data[];
        pzvip_corebus_response_info response_info[];
  rand  int                         start_delay;
  rand  int                         data_delay[];
  rand  int                         accept_delay[];
        uvm_event                   command_end_event;
        uvm_event                   request_end_event;
        uvm_event                   response_end_event;

  constraint c_valid_command {
    if (this.configuration.profile == PZVIP_COREBUS_CSR) {
      command inside {
        PZVIP_COREBUS_READ, PZVIP_COREBUS_WRITE, PZVIP_COREBUS_WRITE_NON_POSTED,
        PZVIP_COREBUS_BROADCAST, PZVIP_COREBUS_BROADCAST_NON_POSTED
      };
    }
    else {
      command inside {
        PZVIP_COREBUS_READ, PZVIP_COREBUS_WRITE, PZVIP_COREBUS_WRITE_NON_POSTED,
        PZVIP_COREBUS_FULL_WRITE, PZVIP_COREBUS_FULL_WRITE_NON_POSTED,
        PZVIP_COREBUS_ATOMIC, PZVIP_COREBUS_ATOMIC_NON_POSTED,
        PZVIP_COREBUS_MESSAGE, PZVIP_COREBUS_MESSAGE_NON_POSTED
      };
    }
  }

  constraint c_valid_id {
    (id >> this.configuration.id_width) == 0;
  }

  constraint c_valid_address {
    solve command before address;

    (address >> this.configuration.address_width) == 0;
    if ((this.configuration.profile == PZVIP_COREBUS_MEMORY_H) && is_full_write_command(command)) {
      (address % (this.configuration.data_width / 8)) == 0;
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
    solve command, length before burst_length;

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
      request_data.size() == burst_length;
    }
    else {
      request_data.size() == 0;
    }
    foreach (request_data[i]) {
      (request_data[i] >> this.configuration.data_width) == 0;
    }
  }

  constraint c_valid_byte_enable {
    solve command, burst_length before byte_enable;

    if (!this.configuration.use_byte_enable) {
      byte_enable.size() == 0;
    }
    else if (is_command_with_data(command)) {
      byte_enable.size() == burst_length;
    }
    else {
      byte_enable.size() == 0;
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
      data_delay.size() == 0;
    }
    else if (is_command_with_data(command)) {
      data_delay.size() == burst_length;
    }
    else {
      data_delay.size() == 0;
    }
    `pzvip_array_delay_constraint(
      data_delay, this.configuration.data_delay
    )
  }

  constraint c_valid_accept_delay {
    solve command, burst_length before accept_delay;
    if (is_response_with_data(command)) {
      accept_delay.size() == burst_length;
    }
    else if (is_no_data_response(command)) {
      accept_delay.size() == 1;
    }
    else {
      accept_delay.size() == 0;
    }
    `pzvip_array_delay_constraint(
      accept_delay, this.configuration.response_accept_delay
    )
  }

  function new(string name = "pzvip_corebus_master_access_sequence");
    super.new(name);
    command_end_event   = events.get("command_end");
    request_end_event   = events.get("request_end");
    response_end_event  = events.get("response_end");
  endfunction

  task body();
    pzvip_corebus_master_item request;
    create_request(request);
    `uvm_send(request)
    wait_for_access_done(request);
  endtask

  task wait_for_command_end();
    command_end_event.wait_on();
  endtask

  task wait_for_request_end();
    request_end_event.wait_on();
  endtask

  task wait_for_response_end();
    response_end_event.wait_on();
  endtask

  task wait_for_end();
    if (is_posted_command(command)) begin
      wait_for_request_end();
    end
    else begin
      wait_for_response_end();
    end
  endtask

  protected virtual function void create_request(
    ref pzvip_corebus_master_item request
  );
    `uvm_create(request)
    request.command               = command;
    request.id                    = id;
    request.address               = address;
    request.length                = length;
    request.burst_length          = burst_length;
    request.message_code          = message_code;
    request.request_info          = request_info;
    request.start_delay           = start_delay;
    request.response_accept_delay = new[accept_delay.size()](accept_delay);
    if (request.is_request_with_data()) begin
      request.request_data  = new[burst_length](request_data);
      if (configuration.use_byte_enable) begin
        request.byte_enable = new[burst_length](byte_enable);
      end
      if (configuration.profile != PZVIP_COREBUS_CSR) begin
        request.data_delay  = new[burst_length](data_delay);
      end
    end
  endfunction

  protected virtual task wait_for_access_done(
    pzvip_corebus_master_item request
  );
    request.command_end_event.wait_on();
    command_end_event.trigger();

    request.wait_for_request_done();
    request_end_event.trigger();

    if (request.is_posted_request()) begin
      return;
    end

    request.response_end_event.wait_on();
    copy_response(request);
    response_end_event.trigger();
  endtask

  protected virtual function void copy_response(
    pzvip_corebus_master_item request
  );
    error         = new[request.error.size()](request.error);
    response_info = new[request.response_info.size()](request.response_info);
    if (request.needs_response_data()) begin
      response_data = new[request.response_data.size()](request.response_data);
    end
  endfunction

  `uvm_object_utils_begin(pzvip_corebus_master_access_sequence)
    `uvm_field_enum(pzvip_corebus_command_type, command, UVM_DEFAULT | UVM_ENUM)
    `uvm_field_int(id, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(address, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(length, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(burst_length, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(message_code, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(request_info, UVM_DEFAULT | UVM_HEX)
    `uvm_field_array_int(request_data, UVM_DEFAULT | UVM_HEX)
    `uvm_field_array_int(byte_enable, UVM_DEFAULT | UVM_HEX)
    `uvm_field_array_int(error, UVM_DEFAULT | UVM_BIN)
    `uvm_field_array_int(response_data, UVM_DEFAULT | UVM_HEX)
    `uvm_field_array_int(response_info, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(start_delay, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
    `uvm_field_array_int(data_delay, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
    `uvm_field_array_int(accept_delay, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
  `uvm_object_utils_end
endclass

class pzvip_corebus_master_write_sequence extends pzvip_corebus_master_access_sequence;
  constraint c_write_command {
    command inside {
      PZVIP_COREBUS_WRITE,
      PZVIP_COREBUS_WRITE_NON_POSTED,
      PZVIP_COREBUS_FULL_WRITE,
      PZVIP_COREBUS_FULL_WRITE_NON_POSTED,
      PZVIP_COREBUS_BROADCAST,
      PZVIP_COREBUS_BROADCAST_NON_POSTED
    };
  }

  `tue_object_default_constructor(pzvip_corebus_master_write_sequence)
  `uvm_object_utils(pzvip_corebus_master_write_sequence)
endclass

class pzvip_corebus_master_read_sequence extends pzvip_corebus_master_access_sequence;
  constraint c_read_command {
    command == PZVIP_COREBUS_READ;
  }

  `tue_object_default_constructor(pzvip_corebus_master_read_sequence)
  `uvm_object_utils(pzvip_corebus_master_read_sequence)
endclass

class pzvip_corebus_master_send_message_sequence extends pzvip_corebus_master_access_sequence;
  constraint c_message_command {
    command inside {
      PZVIP_COREBUS_MESSAGE, PZVIP_COREBUS_MESSAGE_NON_POSTED
    };
  }

  `tue_object_default_constructor(pzvip_corebus_master_send_message_sequence)
  `uvm_object_utils(pzvip_corebus_master_send_message_sequence)
endclass
`endif
