`ifndef PZVIP_COREBUS_SAMPLE_CONFIGURATION_SVH
`define PZVIP_COREBUS_SAMPLE_CONFIGURATION_SVH
class pzvip_corebus_sample_configuration extends tue_configuration;
        pzvip_corebus_profile       profile;
        bit                         enable_delay;
        bit                         enable_response_interleaving;
  rand  pzvip_corebus_configuration corebus_cfg;

  constraint c_corebus_basic {
    corebus_cfg.reset_by_agent  == 1;
    corebus_cfg.profile         == profile;
    corebus_cfg.id_width        == 4;
    corebus_cfg.address_width   == 32;
    if (profile == PZVIP_COREBUS_MEMORY_H) {
      corebus_cfg.max_length      == 32;
      corebus_cfg.unit_data_width == 32;
      corebus_cfg.max_data_width  == 256;
      corebus_cfg.data_width      == 128;
    }
    else if (profile == PZVIP_COREBUS_MEMORY_L) {
      corebus_cfg.max_length == 32;
      corebus_cfg.data_width == 64;
    }
    else if (profile == PZVIP_COREBUS_CSR) {
      corebus_cfg.data_width == 32;
    }
    corebus_cfg.pa_writer.enable_writer        == (`ifdef ENABLE_VERDI_PA_WRITER 1 `else 0 `endif);
    corebus_cfg.pa_writer.enable_memory_writer == (`ifdef ENABLE_VERDI_PA_WRITER 1 `else 0 `endif);
  }

  constraint c_delay {
    if (enable_delay) {
      corebus_cfg.request_start_delay.min_delay          == 0;
      corebus_cfg.request_start_delay.max_delay          == 10;
      corebus_cfg.request_start_delay.weight_zero_delay  == 3;
      corebus_cfg.request_start_delay.weight_short_delay == 2;
      corebus_cfg.request_start_delay.weight_long_delay  == 1;

      if (profile != PZVIP_COREBUS_CSR) {
        corebus_cfg.data_delay.min_delay          == 0;
        corebus_cfg.data_delay.max_delay          == 10;
        corebus_cfg.data_delay.weight_zero_delay  == 3;
        corebus_cfg.data_delay.weight_short_delay == 2;
        corebus_cfg.data_delay.weight_long_delay  == 1;
      }

      corebus_cfg.response_start_delay.min_delay          == 0;
      corebus_cfg.response_start_delay.max_delay          == 10;
      corebus_cfg.response_start_delay.weight_zero_delay  == 3;
      corebus_cfg.response_start_delay.weight_short_delay == 2;
      corebus_cfg.response_start_delay.weight_long_delay  == 1;

      corebus_cfg.response_delay.min_delay          == 0;
      corebus_cfg.response_delay.max_delay          == 10;
      corebus_cfg.response_delay.weight_zero_delay  == 3;
      corebus_cfg.response_delay.weight_short_delay == 2;
      corebus_cfg.response_delay.weight_long_delay  == 1;

      corebus_cfg.command_accept_delay.min_delay          == 0;
      corebus_cfg.command_accept_delay.max_delay          == 10;
      corebus_cfg.command_accept_delay.weight_zero_delay  == 3;
      corebus_cfg.command_accept_delay.weight_short_delay == 2;
      corebus_cfg.command_accept_delay.weight_long_delay  == 1;

      if (profile != PZVIP_COREBUS_CSR) {
        corebus_cfg.data_accept_delay.min_delay          == 0;
        corebus_cfg.data_accept_delay.max_delay          == 10;
        corebus_cfg.data_accept_delay.weight_zero_delay  == 3;
        corebus_cfg.data_accept_delay.weight_short_delay == 2;
        corebus_cfg.data_accept_delay.weight_long_delay  == 1;
      }

      corebus_cfg.response_accept_delay.min_delay          == 0;
      corebus_cfg.response_accept_delay.max_delay          == 10;
      corebus_cfg.response_accept_delay.weight_zero_delay  == 3;
      corebus_cfg.response_accept_delay.weight_short_delay == 2;
      corebus_cfg.response_accept_delay.weight_long_delay  == 1;
    }
  }

  constraint c_response_interleaving {
    if ((profile == PZVIP_COREBUS_MEMORY_H) && enable_response_interleaving) {
      corebus_cfg.outstanding_non_posted_accesses inside {[10:20]};
      corebus_cfg.outstanding_responses inside {[10:20]};
      corebus_cfg.outstanding_non_posted_accesses >= corebus_cfg.outstanding_responses;
      corebus_cfg.enable_response_interleaving == 1;
    }
  }

  function new(string name = "pzvip_corebus_sample_configuration");
    super.new(name);
    corebus_cfg = pzvip_corebus_configuration::type_id::create("corebus_cfg");
  endfunction

  function void pre_randomize();
    uvm_cmdline_processor clp;
    string                value;
    string                values[$];

    super.pre_randomize();

    clp = uvm_cmdline_processor::get_inst();
    if (clp.get_arg_value("+PROFILE=", value)) begin
      case (value)
        "CSR":      profile = PZVIP_COREBUS_CSR;
        "MEMORY_L": profile = PZVIP_COREBUS_MEMORY_L;
        "MEMORY_H": profile = PZVIP_COREBUS_MEMORY_H;
      endcase
    end
    if (clp.get_arg_matches("+ENABLE_DELAY", values)) begin
      enable_delay  = 1;
    end
    if (clp.get_arg_matches("+ENABLE_RESPONSE_INTERLEAVING", values)) begin
      enable_response_interleaving  = 1;
    end
  endfunction

  `uvm_object_utils_begin(pzvip_corebus_sample_configuration)
    `uvm_field_enum(pzvip_corebus_profile, profile, UVM_DEFAULT)
    `uvm_field_int(enable_delay, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(enable_response_interleaving, UVM_DEFAULT | UVM_BIN)
    `uvm_field_object(corebus_cfg, UVM_DEFAULT)
  `uvm_object_utils_end
endclass
`endif
