`ifndef PZVIP_GPIO_MACROS_SVH
`define PZVIP_GPIO_MACROS_SVH

`ifdef PZVIP_GPIO_INCLUDE_USER_MACROS
  `include  "pzvip_gpio_user_macros.svh"
`endif

`ifndef PZVIP_GPIO_MAX_WIDTH
  `define PZVIP_GPIO_MAX_WIDTH  32
`endif

`endif
