class pzvip_stream_configuration extends tue_configuration;
        pzvip_stream_vif            vif;
  rand  int                         data_width;
  rand  int                         byte_enable_width;
  rand  bit                         default_ready;
  rand  pzvip_delay_configuration   data_delay;
  rand  pzvip_delay_configuration   ready_delay;
  rand  bit                         reset_by_agent;

  constraint c_valid_data_width {
    data_width inside {[8:`PZVIP_STREAM_MAX_DATA_WIDTH]};
    $countones(data_width) == 1;
  }

  constraint c_valid_byte_enable_width {
    byte_enable_width == (data_width / 8);
  }

  constraint c_default_reset_by_agent {
    soft reset_by_agent == 1;
  }

  function new(string name = "pzvip_stream_configuration");
    super.new(name);
    data_delay  = pzvip_delay_configuration::type_id::create("data_delay");
    ready_delay = pzvip_delay_configuration::type_id::create("ready_delay");
  endfunction

  `uvm_object_utils_begin(pzvip_stream_configuration)
    `uvm_field_int(data_width, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(byte_enable_width, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(default_ready, UVM_DEFAULT | UVM_BIN)
    `uvm_field_object(data_delay, UVM_DEFAULT)
    `uvm_field_object(ready_delay, UVM_DEFAULT)
  `uvm_object_utils_end
endclass
