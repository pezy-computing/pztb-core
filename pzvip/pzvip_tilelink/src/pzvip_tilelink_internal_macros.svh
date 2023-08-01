`ifndef PZVIP_TILELINK_INTERNAL_MACROS_SVH
`define PZVIP_TILELINK_INTERNAL_MACROS_SVH

`define pzvip_tilelink_delay_constraint(DELAY, CONFIGURATION, ADDITIONAL_CONSTRAINTS = 1, VALID_CONDITION = 1) \
constraint c_valid_``DELAY { \
  if (!(VALID_CONDITION)) { \
    DELAY == 0; \
  } \
  else if (CONFIGURATION.max_delay > CONFIGURATION.min_delay) { \
    (DELAY inside {[CONFIGURATION.min_delay:CONFIGURATION.mid_delay[0]]}) || \
    (DELAY inside {[CONFIGURATION.mid_delay[1]:CONFIGURATION.max_delay]}); \
    if (CONFIGURATION.min_delay == 0) { \
      DELAY dist { \
        0 := CONFIGURATION.weight_zero_delay, \
        [ \
          1: \
          CONFIGURATION.mid_delay[0] \
        ] :/ CONFIGURATION.weight_short_delay, \
        [ \
          CONFIGURATION.mid_delay[1]: \
          CONFIGURATION.max_delay \
        ] :/ CONFIGURATION.weight_long_delay \
      }; \
    } \
    else { \
      DELAY dist { \
        [ \
          CONFIGURATION.min_delay: \
          CONFIGURATION.mid_delay[0] \
        ] :/ CONFIGURATION.weight_short_delay, \
        [ \
          CONFIGURATION.mid_delay[1]: \
          CONFIGURATION.max_delay \
        ] :/ CONFIGURATION.weight_long_delay \
      }; \
    } \
  } \
  else { \
    DELAY == CONFIGURATION.min_delay; \
  } \
  if (VALID_CONDITION) { \
    ADDITIONAL_CONSTRAINTS; \
  } \
}

`define pzvip_tilelink_array_delay_constraint(DELAY, CONFIGURATION, HAS_DATA_CONDITION = 1) \
constraint c_valid_``DELAY { \
  solve size before DELAY; \
  if (HAS_DATA_CONDITION) { \
    DELAY.size == `pzvip_tilelink_get_number_of_beats(size, this.configuration.byte_width); \
  } \
  else { \
    DELAY.size == 1; \
  } \
  if (CONFIGURATION.max_delay > CONFIGURATION.min_delay) { \
    foreach (DELAY[i]) { \
      (DELAY[i] inside {[CONFIGURATION.min_delay:CONFIGURATION.mid_delay[0]]}) || \
      (DELAY[i] inside {[CONFIGURATION.mid_delay[1]:CONFIGURATION.max_delay]}); \
      if (CONFIGURATION.min_delay == 0) { \
        DELAY[i] dist { \
          0 := CONFIGURATION.weight_zero_delay, \
          [ \
            1: \
            CONFIGURATION.mid_delay[0] \
          ] :/ CONFIGURATION.weight_short_delay, \
          [ \
            CONFIGURATION.mid_delay[1]: \
            CONFIGURATION.max_delay \
          ] :/ CONFIGURATION.weight_long_delay \
        }; \
      } \
      else { \
        DELAY[i] dist { \
          [ \
            CONFIGURATION.min_delay: \
            CONFIGURATION.mid_delay[0] \
          ] :/ CONFIGURATION.weight_short_delay, \
          [ \
            CONFIGURATION.mid_delay[1]: \
            CONFIGURATION.max_delay \
          ] :/ CONFIGURATION.weight_long_delay \
        }; \
      } \
    } \
  } \
  else { \
    foreach (DELAY[i]) { \
      DELAY[i] == CONFIGURATION.min_delay; \
    } \
  } \
}

`define pzvip_tilelink_get_number_of_beats(SIZE, BYTE_WIDTH) \
((SIZE + BYTE_WIDTH - 1) / BYTE_WIDTH)

`define pzvip_tilelink_get_mask(SIZE, ADDRESS, BYTE_WIDTH) \
((SIZE < BYTE_WIDTH) ? ((1 << SIZE) - 1) << (ADDRESS & (~(SIZE - 1)) & (BYTE_WIDTH - 1)) : (1 << BYTE_WIDTH) - 1)

`endif
