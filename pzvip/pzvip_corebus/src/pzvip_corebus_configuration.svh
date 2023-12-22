`ifndef PZVIP_COREBUS_CONFIGURATION_SVH
`define PZVIP_COREBUS_CONFIGURATION_SVH
typedef enum {
  PZVIP_COREBUS_IN_ORDER_RESPONSE,
  PZVIP_COREBUS_OUT_OF_ORDER_RESPONSE
} pzvip_corebus_response_order;

class pzvip_corebus_configuration extends tue_configuration;
        pzvip_corebus_vif               vif;
  rand  pzvip_corebus_profile           profile;
  rand  int                             id_width;
  rand  int                             address_width;
  rand  int                             max_length;
  rand  int                             length_width;
  rand  int                             message_code_width;
  rand  int                             request_info_width;
  rand  int                             unit_data_width;
  rand  int                             max_data_width;
  rand  int                             data_width;
  rand  bit                             use_byte_enable;
  rand  int                             byte_enable_width;
  rand  int                             unit_enable_width;
  rand  int                             response_info_width;
  rand  bit                             monitor_read_data;
  rand  int                             weight_no_error;
  rand  int                             weight_error;
  rand  pzvip_corebus_response_order    response_order;
  rand  int                             outstanding_non_posted_accesses;
  rand  int                             outstanding_responses;
  rand  bit                             enable_response_interleaving;
  rand  int                             min_interleave_size;
  rand  int                             max_interleave_size;
  rand  pzvip_delay_configuration       request_start_delay;
  rand  pzvip_delay_configuration       data_delay;
  rand  pzvip_delay_configuration       response_start_delay;
  rand  pzvip_delay_configuration       response_delay;
  rand  bit                             default_command_accept;
  rand  pzvip_delay_configuration       command_accept_delay;
  rand  bit                             default_data_accept;
  rand  pzvip_delay_configuration       data_accept_delay;
  rand  bit                             default_response_accept;
  rand  pzvip_delay_configuration       response_accept_delay;
  rand  bit                             force_command_accept_low;
  rand  bit                             force_data_accept_low;
  rand  bit                             force_response_accept_low;
  rand  bit                             drop_response;
  rand  bit                             block_sending_response;
  rand  pzvip_pa_writer_configuration   pa_writer;
  rand  bit                             reset_by_agent;
  rand  bit                             mask_unused_bits;
  rand  int                             data_size;
  rand  int                             max_data_size;
  rand  int                             address_shift;
  rand  pzvip_corebus_data              unit_data_mask;
  rand  int                             unit_byte_enable_width;
  rand  pzvip_corebus_byte_enable       unit_byte_enable_mask;

  constraint c_valid_id_width {
    id_width inside {[0:`PZVIP_COREBUS_MAX_ID_WIDTH]};
  }

  constraint c_valid_address_width {
    address_width inside {[1:`PZVIP_COREBUS_MAX_ADDRESS_WIDTH]};
  }

  constraint c_valid_max_length {
    solve profile before max_length;
    max_length inside {[1:`PZVIP_COREBUS_MAX_LENGTH]};
    $countones(max_length) == 1;
    if (profile == PZVIP_COREBUS_CSR) {
      max_length == 1;
    }
  }

  constraint c_valid_length_width {
    solve max_length before length_width;
    if (profile == PZVIP_COREBUS_CSR) {
      length_width == 0;
    }
    else if (max_length == 1) {
      length_width == 1;
    }
    else {
      length_width == $clog2(max_length);
    }
  }

  constraint c_valid_message_code_width {
    solve max_length before message_code_width;
    if (profile == PZVIP_COREBUS_CSR) {
      message_code_width == 0;
    }
    else if (max_length == 1) {
      message_code_width == 1;
    }
    else {
      message_code_width == $clog2(max_length);
    }
  }

  constraint c_valid_request_info_width {
    request_info_width inside {[0:`PZVIP_COREBUS_MAX_REQUEST_INFO_WIDTH]};
  }

  constraint c_default_request_info_width {
    soft request_info_width == 0;
  }

  constraint c_valid_unit_data_width {
    unit_data_width inside {[`PZVIP_COREBUS_MIN_DATA_WIDTH:`PZVIP_COREBUS_MAX_DATA_WIDTH]};
    unit_data_width >= 8;
    $countones(unit_data_width) == 1;
  }

  constraint c_valid_max_data_width {
    solve profile, unit_data_width before max_data_width;
    max_data_width inside {[unit_data_width:`PZVIP_COREBUS_MAX_DATA_WIDTH]};
    (max_data_width % unit_data_width) == 0;
    if (profile == PZVIP_COREBUS_CSR) {
      max_data_width == unit_data_width;
    }
  }

  constraint c_valid_data_width {
    solve profile, unit_data_width, max_data_width before data_width;
    data_width inside {[unit_data_width:max_data_width]};
    (data_width % unit_data_width) == 0;
    if (profile != PZVIP_COREBUS_MEMORY_H) {
      data_width == max_data_width;
    }
  }

  constraint c_valid_byte_enable_width {
    solve data_width, use_byte_enable before byte_enable_width;
    if (use_byte_enable) {
      byte_enable_width == (data_width / 8);
    }
    else {
      byte_enable_width == 0;
    }
  }

  constraint c_valid_unit_enable_width {
    solve profile, unit_data_width, max_data_width before unit_enable_width;
    if (profile == PZVIP_COREBUS_MEMORY_H) {
      unit_enable_width == (max_data_width / unit_data_width);
    }
    else {
      unit_enable_width == 0;
    }
  }

  constraint c_valid_response_info_width {
    response_info_width inside {[0:`PZVIP_COREBUS_MAX_RESPONSE_INFO_WIDTH]};
  }

  constraint c_default_response_info_width {
    soft response_info_width == 0;
  }

  constraint c_default_monitor_read_data {
    soft monitor_read_data == 0;
  }

  constraint c_valid_status_weight {
    weight_error    >= -1;
    weight_no_error >= -1;
  }

  constraint c_default_status_weight {
    soft weight_error    == -1;
    soft weight_no_error == -1;
  }

  constraint c_valid_outstanding_non_posted_accesses {
    outstanding_non_posted_accesses >= 0;
  }

  constraint c_default_outstanding_non_posted_accesses {
    soft outstanding_non_posted_accesses == 0;
  }

  constraint c_valid_outstanding_responses {
    outstanding_responses >= 0;
  }

  constraint c_default_outstanding_responses {
    soft outstanding_responses == 0;
  }

  constraint c_default_enable_response_interleaving {
    soft enable_response_interleaving == 0;
  }

  constraint c_valid_interleave_size {
    solve profile before min_interleave_size, max_interleave_size;
    if (profile == PZVIP_COREBUS_MEMORY_H) {
      min_interleave_size >= 0;
      max_interleave_size >= 0;
      max_interleave_size >= min_interleave_size;
    }
    else {
      min_interleave_size == -1;
      max_interleave_size == -1;
    }
  }

  constraint c_default_interleave_size {
    soft min_interleave_size == 0;
    soft max_interleave_size == 0;
  }

  constraint c_default_force_accept_low {
    soft force_command_accept_low  == 0;
    soft force_data_accept_low     == 0;
    soft force_response_accept_low == 0;
  }

  constraint c_default_drop_response {
    soft drop_response == 0;
  }

  constraint c_default_block_sending_response {
    soft block_sending_response == 0;
  }

  constraint c_valid_pa_writer {
    pa_writer.address_width == address_width;
    pa_writer.data_width    == data_width;
  }

  constraint c_default_reset_by_agent {
    soft reset_by_agent == 0;
  }

  constraint c_default_mask_unused_bits {
    soft mask_unused_bits == 0;
  }

  constraint c_valid_data_size {
    solve unit_data_width, data_width before data_size;
    data_size == (data_width / unit_data_width);
  }

  constraint c_valid_max_data_size {
    solve unit_data_width, max_data_width before max_data_size;
    max_data_size == (max_data_width / unit_data_width);
  }

  constraint c_valid_address_shift {
    solve unit_data_width before address_shift;
    address_shift == ($clog2(unit_data_width) - 3);
  }

  constraint c_valid_unit_data_mask {
    solve unit_data_width before unit_data_mask;
    unit_data_mask == ((1 << unit_data_width) - 1);
  }

  constraint c_valid_unit_byte_enable_width {
    solve use_byte_enable, unit_data_width before unit_byte_enable_width;
    if (use_byte_enable) {
      unit_byte_enable_width == (unit_data_width / 8);
    }
    else {
      unit_byte_enable_width == 0;
    }
  }

  constraint c_valid_unit_byte_enable_mask {
    solve unit_byte_enable_width before unit_byte_enable_mask;
    unit_byte_enable_mask == ((1 << unit_byte_enable_width) - 1);
  }

  function new(string name = "pzvip_corebus_configuration");
    super.new(name);
    request_start_delay   = pzvip_delay_configuration::type_id::create("request_start_delay");
    data_delay            = pzvip_delay_configuration::type_id::create("data_delay");
    response_start_delay  = pzvip_delay_configuration::type_id::create("response_start_delay");
    response_delay        = pzvip_delay_configuration::type_id::create("response_delay");
    command_accept_delay  = pzvip_delay_configuration::type_id::create("command_accept_delay");
    data_accept_delay     = pzvip_delay_configuration::type_id::create("data_accept_delay");
    response_accept_delay = pzvip_delay_configuration::type_id::create("response_accept_delay");
    pa_writer             = pzvip_pa_writer_configuration::type_id::create("pa_writer");
  endfunction

  function void post_randomize();
    super.post_randomize();
    weight_no_error   = (weight_no_error  == -1) ? 1 : weight_no_error;
    weight_error      = (weight_error     == -1) ? 0 : weight_error;
  endfunction

  `uvm_object_utils_begin(pzvip_corebus_configuration)
    `uvm_field_enum(pzvip_corebus_profile, profile, UVM_DEFAULT | UVM_ENUM)
    `uvm_field_int(id_width, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(address_width, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(max_length, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(length_width, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(message_code_width, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(request_info_width, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(unit_data_width, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(max_data_width, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(data_width, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(use_byte_enable, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(byte_enable_width, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(unit_enable_width, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(response_info_width, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(monitor_read_data, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(weight_no_error, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(weight_error, UVM_DEFAULT | UVM_DEC)
    `uvm_field_enum(pzvip_corebus_response_order, response_order, UVM_DEFAULT | UVM_ENUM)
    `uvm_field_int(outstanding_non_posted_accesses, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(outstanding_responses, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(enable_response_interleaving, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(min_interleave_size, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(max_interleave_size, UVM_DEFAULT | UVM_DEC)
    `uvm_field_object(request_start_delay, UVM_DEFAULT)
    `uvm_field_object(data_delay, UVM_DEFAULT)
    `uvm_field_object(response_start_delay, UVM_DEFAULT)
    `uvm_field_object(response_delay, UVM_DEFAULT)
    `uvm_field_int(default_command_accept, UVM_DEFAULT | UVM_BIN)
    `uvm_field_object(command_accept_delay, UVM_DEFAULT)
    `uvm_field_int(default_data_accept, UVM_DEFAULT | UVM_BIN)
    `uvm_field_object(data_accept_delay, UVM_DEFAULT)
    `uvm_field_int(default_response_accept, UVM_DEFAULT | UVM_BIN)
    `uvm_field_object(response_accept_delay, UVM_DEFAULT)
    `uvm_field_int(force_command_accept_low, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(force_data_accept_low, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(force_response_accept_low, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(drop_response, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(block_sending_response, UVM_DEFAULT | UVM_BIN)
    `uvm_field_object(pa_writer, UVM_DEFAULT)
    `uvm_field_int(reset_by_agent, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(mask_unused_bits, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(unit_byte_enable_width, UVM_DEFAULT | UVM_NOPRINT)
    `uvm_field_int(data_size, UVM_DEFAULT | UVM_NOPRINT)
    `uvm_field_int(max_data_size, UVM_DEFAULT | UVM_NOPRINT)
    `uvm_field_int(address_shift, UVM_DEFAULT | UVM_NOPRINT)
    `uvm_field_int(unit_data_mask, UVM_DEFAULT | UVM_NOPRINT)
    `uvm_field_int(unit_byte_enable_mask, UVM_DEFAULT | UVM_NOPRINT)
  `uvm_object_utils_end
endclass
`endif
