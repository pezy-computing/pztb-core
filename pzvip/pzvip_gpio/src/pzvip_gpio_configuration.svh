`ifndef PZVIP_GPIO_CONFIGURATION_SVH
`define PZVIP_GPIO_CONFIGURATION_SVH
class pzvip_gpio_configuration extends tue_configuration;
        pzvip_gpio_vif          vif;
  rand  int                     width;
  rand  bit                     no_sync_clock;
  rand  bit                     use_reset;
  rand  pzvip_gpio_output_pair  reset_value;
  rand  bit                     reset_by_agent;

  constraint c_valid_width {
    width inside {[1:`PZVIP_GPIO_MAX_WIDTH]};
  }

  constraint c_default_reset_value {
    soft reset_value.value_out     == 0;
    soft reset_value.output_enable == 0;
  }

  constraint c_default_no_sync_clock {
    soft no_sync_clock == 0;
  }

  constraint c_default_use_reset {
    soft use_reset == 1;
  }

  constraint c_default_reset_by_agent {
    soft reset_by_agent == 1;
  }

  `tue_object_default_constructor(pzvip_gpio_configuration)
  `uvm_object_utils_begin(pzvip_gpio_configuration)
    `uvm_field_int(width                    , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(reset_value.value_out    , UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(reset_value.output_enable, UVM_DEFAULT | UVM_HEX)
  `uvm_object_utils_end
endclass
`endif
