`ifndef PZVIP_TILELINK_CONFIGURATION_SVH
`define PZVIP_TILELINK_CONFIGURATION_SVH
class tvip_tilelink_delay_configuration extends tue_configuration;
  rand  int max_delay;
  rand  int mid_delay[2];
  rand  int min_delay;
  rand  int weight_zero_delay;
  rand  int weight_short_delay;
  rand  int weight_long_delay;

  constraint c_valid_max_min_delay {
    max_delay >= -1;
    min_delay >= -1;
    max_delay >= min_delay;
  }

  constraint c_default_max_min_delay {
    soft max_delay == -1;
    soft min_delay == -1;
  }

  constraint c_valid_mid_delay {
    solve max_delay, min_delay before mid_delay;
    mid_delay[0] inside {-1, [min_delay:max_delay]};
    mid_delay[1] inside {-1, [min_delay:max_delay]};
    if (get_delay_delta(max_delay, min_delay) >= 2) {
      if ((mid_delay[0] >= 0) || (mid_delay[1] >= 0)) {
        mid_delay[0] < mid_delay[1];
      }
      if (get_min_delay(min_delay) == 0) {
        mid_delay[0] > 0;
      }
    }
    else {
      mid_delay[0] == -1;
      mid_delay[1] == -1;
    }
  }

  constraint c_default_mid_delay {
    soft mid_delay[0] == -1;
    soft mid_delay[1] == -1;
  }

  constraint c_valid_weight {
    solve max_delay before weight_zero_delay, weight_short_delay, weight_long_delay;
    solve min_delay before weight_zero_delay, weight_short_delay, weight_long_delay;
    if (get_delay_delta(max_delay, min_delay) >= 1) {
      weight_zero_delay  >= -1;
      weight_short_delay >= -1;
      weight_long_delay  >= -1;
    }
    else {
      weight_zero_delay  == 0;
      weight_short_delay == 0;
      weight_long_delay  == 0;
    }
    if (min_delay > 0) {
      weight_zero_delay == 0;
    }
    if ((min_delay <= 0) && (max_delay == 1)) {
      weight_short_delay == 0;
    }
  }

  constraint c_default_weight {
    soft weight_zero_delay  == -1;
    soft weight_short_delay == -1;
    soft weight_long_delay  == -1;
  }

  function void post_randomize();
    weight_zero_delay   = (weight_zero_delay  == -1) ? 1 : weight_zero_delay;
    weight_short_delay  = (weight_short_delay == -1) ? 1 : weight_short_delay;
    weight_long_delay   = (weight_long_delay  == -1) ? 1 : weight_long_delay;

    min_delay = get_min_delay(min_delay);
    max_delay = get_max_delay(max_delay, min_delay);
    foreach (mid_delay[i]) begin
      if (mid_delay[i] >= 0) begin
        continue;
      end
      case (max_delay - min_delay)
        0, 1: begin
          mid_delay[i]  = (i == 0) ? min_delay : max_delay;
        end
        2: begin
          mid_delay[i]  = (i == 0) ? min_delay + 1 : max_delay;
        end
        default: begin
          mid_delay[i]  = min_delay + ((max_delay - min_delay) / 2) + i;
        end
      endcase
    end
  endfunction

  local function int get_min_delay(int min_delay);
    return (min_delay >= 0) ? min_delay : 0;
  endfunction

  local function int get_max_delay(int max_delay, int min_delay);
    return (max_delay >= 0) ? max_delay : get_min_delay(min_delay);
  endfunction

  local function int get_delay_delta(int max_delay, int min_delay);
    return get_max_delay(max_delay, min_delay) - get_min_delay(min_delay);
  endfunction

  `tue_object_default_constructor(tvip_tilelink_delay_configuration)
  `uvm_object_utils_begin(tvip_tilelink_delay_configuration)
    `uvm_field_int(max_delay, UVM_DEFAULT | UVM_DEC)
    `uvm_field_sarray_int(mid_delay, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(min_delay, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(weight_zero_delay, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(weight_short_delay, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(weight_long_delay, UVM_DEFAULT | UVM_DEC)
  `uvm_object_utils_end
endclass

class pzvip_tilelink_configuration extends tue_configuration;
        pzvip_tilelink_vif                vif;
  rand  pzvip_tilelink_port_type          port_type;
  rand  pzvip_tilelink_conformance_level  conformance_level;
  rand  int                               data_width;
  rand  int                               byte_width;
  rand  int                               address_width;
  rand  int                               max_size;
  rand  int                               source_width;
  rand  int                               sink_width;
  rand  int                               tag_width;
  rand  pzvip_tilelink_id                 base_id;
  rand  tvip_tilelink_delay_configuration gap_delay;
  rand  tvip_tilelink_delay_configuration ready_delay;
  rand  tvip_tilelink_delay_configuration response_start_delay;
  rand  bit                               a_default_ready;
  rand  bit                               b_default_ready;
  rand  bit                               c_default_ready;
  rand  bit                               d_default_ready;
  rand  bit                               e_default_ready;
  rand  bit                               reset_by_agent;

  constraint c_valid_data_width {
    data_width inside {[8:`PZVIP_TILELINK_MAX_DATA_WIDTH]};
    $countones(data_width) == 1;
  }

  constraint c_valid_byte_width {
    solve data_width before byte_width;
    byte_width == (data_width / 8);
  }

  constraint c_valid_address_width {
    address_width inside {[1:`PZVIP_TILELINK_MAX_ADDRESS_WIDTH]};
  }

  constraint c_valid_max_size {
    solve conformance_level, byte_width before max_size;
    max_size inside {[1:`PZVIP_TILELINK_MAX_SIZE]};
    $countones(max_size) == 1;
    if (conformance_level == PZVIP_TILELINK_TL_UL) {
      max_size <= byte_width;
    }
  }

  constraint c_valid_source_width {
    source_width inside {[1:`PZVIP_TILELINK_MAX_ID_WIDTH]};
  }

  constraint c_valid_sink_width {
    sink_width inside {[1:`PZVIP_TILELINK_MAX_ID_WIDTH]};
  }

  constraint c_valid_tag_width {
    solve port_type, source_width, sink_width before tag_width;
    if (port_type == PZVIP_TILELINK_MASTER_PORT) {
      tag_width inside {[0:source_width]};
    }
    else {
      tag_width inside {[0:sink_width]};
    }
  }

  constraint c_valid_base_id {
    solve port_type, source_width, sink_width, tag_width before base_id;
    (base_id & ((2**tag_width) - 1)) == 0;
    if (port_type == PZVIP_TILELINK_MASTER_PORT) {
      base_id < 2**source_width;
    }
    else {
      base_id < 2**sink_width;
    }
  }

  constraint c_default_reset_by_agent {
    soft reset_by_agent == 1;
  }

  function new(string name = "pzvip_tilelink_configuration");
    super.new(name);
    gap_delay             = tvip_tilelink_delay_configuration::type_id::create("gap_delay");
    ready_delay           = tvip_tilelink_delay_configuration::type_id::create("ready_delay");
    response_start_delay  = tvip_tilelink_delay_configuration::type_id::create("response_start_delay");
  endfunction

  function bit is_master_port();
    return (port_type == PZVIP_TILELINK_MASTER_PORT) ? 1 : 0;
  endfunction

  function bit is_slave_port();
    return (port_type == PZVIP_TILELINK_SLAVE_PORT) ? 1 : 0;
  endfunction

  `uvm_object_utils_begin(pzvip_tilelink_configuration)
    `uvm_field_enum(pzvip_tilelink_port_type, port_type, UVM_DEFAULT)
    `uvm_field_enum(pzvip_tilelink_conformance_level, conformance_level, UVM_DEFAULT)
    `uvm_field_int(data_width, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(byte_width, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(address_width, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(max_size, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(source_width, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(sink_width, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(tag_width, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(base_id, UVM_DEFAULT | UVM_HEX)
    `uvm_field_object(gap_delay, UVM_DEFAULT)
    `uvm_field_object(ready_delay, UVM_DEFAULT)
    `uvm_field_object(response_start_delay, UVM_DEFAULT)
    `uvm_field_int(a_default_ready, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(b_default_ready, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(c_default_ready, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(d_default_ready, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(e_default_ready, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(reset_by_agent, UVM_DEFAULT | UVM_BIN)
  `uvm_object_utils_end
endclass
`endif
