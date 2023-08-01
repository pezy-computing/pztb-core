`ifndef PZVIP_GPIO_SEQUENCE_SVH
`define PZVIP_GPIO_SEQUENCE_SVH
class pzvip_gpio_sequence extends tue_sequence #(pzvip_gpio_configuration);
  rand  pzvip_gpio_action action;
  rand  pzvip_gpio_value  value;
  rand  pzvip_gpio_value  output_enable;
  rand  pzvip_gpio_value  target_bits;
  rand  bit               wait_for_all;

  constraint c_valid_action {
    if (this.configuration.no_sync_clock) {
      action != PZVIP_GPIO_SET_ONE_SHOT;
    }
  }

  constraint c_valid_value {
    solve action before value;
    if (action inside {PZVIP_GPIO_SET, PZVIP_GPIO_SET_ONE_SHOT}) {
      (value >> this.configuration.width) == 0;
    }
    else {
      value == 0;
    }
  }

  constraint c_valid_output_enable {
    solve action before output_enable;
    if (action inside {PZVIP_GPIO_SET, PZVIP_GPIO_SET_ONE_SHOT}) {
      (output_enable >> this.configuration.width) == 0;
    }
    else {
      output_enable == 0;
    }
  }

  constraint c_default_output_enable {
    if (action inside {PZVIP_GPIO_SET, PZVIP_GPIO_SET_ONE_SHOT}) {
      soft output_enable == ((1 << this.configuration.width) - 1);
    }
  }

  constraint c_valid_target_bits {
    solve action before target_bits;
    if (action inside {
      PZVIP_GPIO_WAIT_FOR_EDGE, PZVIP_GPIO_WAIT_FOR_POSEDGE, PZVIP_GPIO_WAIT_FOR_NEGEDGE,
      PZVIP_GPIO_WAIT_FOR_HIGH, PZVIP_GPIO_WAIT_FOR_LOW
    }){
      (target_bits >> this.configuration.width) == 0;
    }
    else {
      target_bits == 0;
    }
  }

  constraint c_default_target_bits {
    soft target_bits == ((2**this.configuration.width) - 1);
  }

  constraint c_default_wait_for_all {
    soft wait_for_all == 1;
  }

  task body();
    case (action)
      PZVIP_GPIO_SET: begin
        p_sequencer.set(value, output_enable, 0);
      end
      PZVIP_GPIO_SET_ONE_SHOT: begin
        p_sequencer.set(value, output_enable, 1);
      end
      PZVIP_GPIO_GET: begin
        value = p_sequencer.get();
      end
      PZVIP_GPIO_CLEAR_OUTPUT_ENABLE: begin
        p_sequencer.clear_output_enable();
      end
      PZVIP_GPIO_WAIT_FOR_CHANGE: begin
        p_sequencer.wait_for_change(value);
      end
      PZVIP_GPIO_WAIT_FOR_EDGE: begin
        p_sequencer.wait_for_edge(target_bits, wait_for_all);
      end
      PZVIP_GPIO_WAIT_FOR_POSEDGE: begin
        p_sequencer.wait_for_posedge(target_bits, wait_for_all);
      end
      PZVIP_GPIO_WAIT_FOR_NEGEDGE: begin
        p_sequencer.wait_for_negedge(target_bits, wait_for_all);
      end
      PZVIP_GPIO_WAIT_FOR_HIGH: begin
        p_sequencer.wait_for_high(target_bits, wait_for_all);
      end
      PZVIP_GPIO_WAIT_FOR_LOW: begin
        p_sequencer.wait_for_low(target_bits, wait_for_all);
      end
    endcase
  endtask

  `uvm_declare_p_sequencer(pzvip_gpio_sequencer)

  `tue_object_default_constructor(pzvip_gpio_sequence)
  `uvm_object_utils_begin(pzvip_gpio_sequence)
    `uvm_field_enum(pzvip_gpio_action, action, UVM_DEFAULT)
    `uvm_field_int(value        , UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(output_enable, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(target_bits  , UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(wait_for_all , UVM_DEFAULT | UVM_BIN)
  `uvm_object_utils_end
endclass
`endif
