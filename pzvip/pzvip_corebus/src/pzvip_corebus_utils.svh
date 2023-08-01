`ifndef PZVIP_COREBUS_UTILS_SVH
`define PZVIP_COREBUS_UTILS_SVH

function automatic bit is_command_with_data(pzvip_corebus_command_type command);
  return command[PZVIP_COREBUS_COMMAND_DATA_BIT];
endfunction

function automatic bit is_no_data_command(pzvip_corebus_command_type command);
  return !is_command_with_data(command);
endfunction

function automatic bit is_non_posted_command(pzvip_corebus_command_type command);
  return command[PZVIP_COREBUS_COMMAND_NON_POSTED_BIT];
endfunction

function automatic bit is_posted_command(pzvip_corebus_command_type command);
  return !is_non_posted_command(command);
endfunction

function automatic bit is_read_command(pzvip_corebus_command_type command);
  return command == PZVIP_COREBUS_READ;
endfunction

function automatic bit is_write_command(pzvip_corebus_command_type command);
  return command inside {
    PZVIP_COREBUS_WRITE, PZVIP_COREBUS_WRITE_NON_POSTED,
    PZVIP_COREBUS_FULL_WRITE, PZVIP_COREBUS_FULL_WRITE_NON_POSTED,
    PZVIP_COREBUS_BROADCAST, PZVIP_COREBUS_BROADCAST_NON_POSTED
  };
endfunction

function automatic bit is_full_write_command(pzvip_corebus_command_type command);
  return command inside {PZVIP_COREBUS_FULL_WRITE, PZVIP_COREBUS_FULL_WRITE_NON_POSTED};
endfunction

function automatic bit is_atomic_command(pzvip_corebus_command_type command);
  return command inside {PZVIP_COREBUS_ATOMIC, PZVIP_COREBUS_ATOMIC_NON_POSTED};
endfunction

function automatic bit is_message_command(pzvip_corebus_command_type command);
  return command inside {PZVIP_COREBUS_MESSAGE, PZVIP_COREBUS_MESSAGE_NON_POSTED};
endfunction

function automatic bit is_response_with_data(pzvip_corebus_command_type command);
  if (is_posted_command(command)) begin
    return 0;
  end
  else if (is_write_command(command)) begin
    return 0;
  end
  else if (is_message_command(command)) begin
    return 0;
  end
  else begin
    return 1;
  end
endfunction

function automatic bit is_no_data_response(pzvip_corebus_command_type command);
  if (is_posted_command(command)) begin
    return 0;
  end
  else if (is_write_command(command)) begin
    return 1;
  end
  else if (is_message_command(command)) begin
    return 1;
  end
  else begin
    return 0;
  end
endfunction

function automatic int calc_initial_offset(
  pzvip_corebus_configuration configuration,
  pzvip_corebus_command_type  command,
  pzvip_corebus_address       address,
  bit                         request
);
  if (is_atomic_command(command)) begin
    return 0;
  end
  else if (configuration.profile == PZVIP_COREBUS_MEMORY_H) begin
    int data_size;
    data_size = (request) ? configuration.data_size : configuration.max_data_size;
    return (address >> configuration.address_shift) % data_size;
  end
  else begin
    return 0;
  end
endfunction

function automatic int calc_burst_length(
  pzvip_corebus_configuration configuration,
  pzvip_corebus_command_type  command,
  pzvip_corebus_address       address,
  int                         length
);
  if (configuration.profile == PZVIP_COREBUS_CSR) begin
    return 1;
  end
  else if (configuration.profile == PZVIP_COREBUS_MEMORY_L) begin
    return length;
  end
  else begin
    return (
      length + calc_initial_offset(configuration, command, address, 1) +
      (configuration.data_size - 1)
    ) / configuration.data_size;
  end
endfunction

function automatic int calc_response_burst_length(
  pzvip_corebus_configuration configuration,
  pzvip_corebus_command_type  command,
  pzvip_corebus_address       address,
  int                         length
);
  if (is_posted_command(command)) begin
    return 0;
  end
  else if (is_write_command(command)) begin
    return 1;
  end
  else begin
    return calc_burst_length(
      configuration, command, address, length
    );
  end
endfunction


`endif
