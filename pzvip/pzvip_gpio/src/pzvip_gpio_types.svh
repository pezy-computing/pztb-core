`ifndef PZVIP_GPIO_TYPES_SVH
`define PZVIP_GPIO_TYPES_SVH

typedef virtual pzvip_gpio_if pzvip_gpio_vif;

typedef bit [`PZVIP_GPIO_MAX_WIDTH-1:0] pzvip_gpio_value;

typedef struct packed {
  pzvip_gpio_value  value_out;
  pzvip_gpio_value  output_enable;
} pzvip_gpio_output_pair;

typedef enum {
  PZVIP_GPIO_SET,
  PZVIP_GPIO_SET_ONE_SHOT,
  PZVIP_GPIO_GET,
  PZVIP_GPIO_CLEAR_OUTPUT_ENABLE,
  PZVIP_GPIO_WAIT_FOR_CHANGE,
  PZVIP_GPIO_WAIT_FOR_EDGE,
  PZVIP_GPIO_WAIT_FOR_POSEDGE,
  PZVIP_GPIO_WAIT_FOR_NEGEDGE,
  PZVIP_GPIO_WAIT_FOR_HIGH,
  PZVIP_GPIO_WAIT_FOR_LOW
} pzvip_gpio_action;
`endif
