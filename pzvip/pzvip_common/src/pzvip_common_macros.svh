`ifndef PZVIP_COMMON_MACROS_SVH
`define PZVIP_COMMON_MACROS_SVH

`define pzvip_delay_constraint(DELAY, CONFIGURATION) \
if (CONFIGURATION.max_delay > CONFIGURATION.min_delay) { \
  (DELAY inside {[CONFIGURATION.min_delay:CONFIGURATION.mid_delay[0]]}) || \
  (DELAY inside {[CONFIGURATION.mid_delay[1]:CONFIGURATION.max_delay]}); \
  if (CONFIGURATION.min_delay == 0) { \
    DELAY dist { \
      0                                                       := CONFIGURATION.weight_zero_delay, \
      [1                         :CONFIGURATION.mid_delay[0]] :/ CONFIGURATION.weight_short_delay, \
      [CONFIGURATION.mid_delay[1]:CONFIGURATION.max_delay   ] :/ CONFIGURATION.weight_long_delay \
    }; \
  } \
  else { \
    DELAY dist { \
      [CONFIGURATION.min_delay   :CONFIGURATION.mid_delay[0]] :/ CONFIGURATION.weight_short_delay, \
      [CONFIGURATION.mid_delay[1]:CONFIGURATION.max_delay   ] :/ CONFIGURATION.weight_long_delay \
    }; \
  } \
} \
else { \
  DELAY == CONFIGURATION.min_delay; \
}

`define pzvip_array_delay_constraint(DELAY, CONFIGURATION) \
foreach (DELAY[i]) { \
  `pzvip_delay_constraint(DELAY[i], CONFIGURATION) \
}

`endif
