`ifndef PZVIP_COREBUS_SLAVE_MONITOR_SVH
`define PZVIP_COREBUS_SLAVE_MONITOR_SVH
typedef tue_reactive_monitor #(
  .CONFIGURATION  (pzvip_corebus_configuration  ),
  .STATUS         (pzvip_corebus_status         ),
  .ITEM           (pzvip_corebus_slave_item     ),
  .ITEM_HANDLE    (pzvip_corebus_item           ),
  .REQUEST        (pzvip_corebus_item           )
) pzvip_corebus_slave_monitor_base;

class pzvip_corebus_slave_monitor extends pzvip_corebus_monitor_base #(
  .BASE (pzvip_corebus_slave_monitor_base ),
  .ITEM (pzvip_corebus_slave_item         )
);
  protected virtual task begin_command(pzvip_corebus_item item, time begin_time = 0);
    super.begin_command(item, begin_time);
    request_port.write(item);
  endtask

  `tue_component_default_constructor(pzvip_corebus_slave_monitor)
  `uvm_component_utils(pzvip_corebus_slave_monitor)
endclass
`endif
