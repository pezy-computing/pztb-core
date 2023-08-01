`ifndef PZVIP_COREBUS_MASTER_MONITOR_SVH
`define PZVIP_COREBUS_MASTER_MONITOR_SVH
typedef tue_param_monitor #(
  .CONFIGURATION  (pzvip_corebus_configuration  ),
  .STATUS         (pzvip_corebus_status         ),
  .ITEM           (pzvip_corebus_master_item    ),
  .ITEM_HANDLE    (pzvip_corebus_item           )
) pzvip_corebus_master_monitor_base;

class pzvip_corebus_master_monitor extends pzvip_corebus_monitor_base #(
  .BASE (pzvip_corebus_master_monitor_base  ),
  .ITEM (pzvip_corebus_master_item          )
);
  `tue_component_default_constructor(pzvip_corebus_master_monitor)
  `uvm_component_utils(pzvip_corebus_master_monitor)
endclass
`endif
