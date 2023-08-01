`ifndef PZVIP_COREBUS_RAL_PREDICTOR_SVH
`define PZVIP_COREBUS_RAL_PREDICTOR_SVH
typedef tue_reg_predictor #(pzvip_corebus_item) pzvip_corebus_ral_predictor_base;

class pzvip_corebus_ral_predictor extends tue_component_base #(
  .BASE           (pzvip_corebus_ral_predictor_base ),
  .CONFIGURATION  (pzvip_corebus_configuration      ),
  .STATUS         (pzvip_corebus_status             )
);
  `tue_component_default_constructor(pzvip_corebus_ral_predictor)
  `uvm_component_utils(pzvip_corebus_ral_predictor)
endclass

`endif
