`ifndef PZVIP_DELAY_CONFIGURATION_SVH
`define PZVIP_DELAY_CONFIGURATION_SVH
class pzvip_delay_configuration extends tue_configuration;
  rand  int min_delay;
  rand  int mid_delay[2];
  rand  int max_delay;
  rand  int weight_zero_delay;
  rand  int weight_short_delay;
  rand  int weight_long_delay;

  constraint c_valid_min_max_delay {
    min_delay >= -1;
    max_delay >= -1;
    max_delay >= min_delay;
  }

  constraint c_default_min_max_delay {
    soft min_delay == -1;
    soft max_delay == -1;
  }

  constraint c_valid_mid_delay {
    solve min_delay, max_delay before mid_delay;

    foreach (mid_delay[i]) {
      mid_delay[i] inside {
        -1, [get_min_delay(min_delay):get_max_delay(max_delay, min_delay)]
      };
    }

    if ((mid_delay[0] != -1) || (mid_delay[1] != -1)) {
      if (get_delay_delta(max_delay, min_delay) >= 1) {
        mid_delay[1] > min_delay[0];
      }
      else {
        mid_delay[1] == min_delay[0];
      }

      if ((get_delay_delta(max_delay, min_delay) >= 2) && (get_min_delay(min_delay) == 0)) {
        mid_delay[0] > 0;
      }
    }
  }

  constraint c_default_mid_delay {
    soft mid_delay[0] == -1;
    soft mid_delay[1] == -1;
  }

  constraint c_valid_weight {
    solve max_delay, min_delay before weight_zero_delay, weight_short_delay, weight_long_delay;

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
    if ((get_min_delay(min_delay) == 0) && (max_delay == 1)) {
      weight_short_delay == 0;
    }
  }

  constraint c_default_weight {
    soft weight_zero_delay  == -1;
    soft weight_short_delay == -1;
    soft weight_long_delay  == -1;
  }

  function int get_min_delay(int min_delay);
    return (min_delay >= 0) ? min_delay : 0;
  endfunction

  function int get_max_delay(int max_delay, int min_delay);
    return (max_delay >= 0) ? max_delay : get_min_delay(min_delay);
  endfunction

  function int get_delay_delta(int max_delay, int min_delay);
    return get_max_delay(max_delay, min_delay) - get_min_delay(min_delay);
  endfunction

  function void post_randomize();
    int delay_delta;

    super.post_randomize();

    weight_zero_delay   = (weight_zero_delay  == -1) ? 1 : weight_zero_delay;
    weight_short_delay  = (weight_short_delay == -1) ? 1 : weight_short_delay;
    weight_long_delay   = (weight_long_delay  == -1) ? 1 : weight_long_delay;

    min_delay   = get_min_delay(min_delay);
    max_delay   = get_max_delay(max_delay, min_delay);
    delay_delta = get_delay_delta(max_delay, min_delay);
    foreach (mid_delay[i]) begin
      if (mid_delay[i] >= 0) begin
        continue;
      end
      case (delay_delta)
        0, 1:     mid_delay[i]  = (i == 0) ? min_delay : max_delay;
        2:        mid_delay[i]  = (i == 0) ? min_delay + 1 : max_delay;
        default:  mid_delay[i]  = (delay_delta / 2) + i;
      endcase
    end
  endfunction

  `tue_object_default_constructor(pzvip_delay_configuration)
  `uvm_object_utils_begin(pzvip_delay_configuration)
    `uvm_field_int(min_delay, UVM_DEFAULT | UVM_DEC)
    `uvm_field_sarray_int(mid_delay, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(max_delay, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(weight_zero_delay, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(weight_short_delay, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(weight_long_delay, UVM_DEFAULT | UVM_DEC)
  `uvm_object_utils_end
endclass
`endif
