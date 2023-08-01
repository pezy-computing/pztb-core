`ifndef PZVIP_COREBUS_SLAVE_SEQUENCER_SVH
`define PZVIP_COREBUS_SLAVE_SEQUENCER_SVH
typedef tue_reactive_sequencer #(
  .CONFIGURATION  (pzvip_corebus_configuration  ),
  .STATUS         (pzvip_corebus_status         ),
  .ITEM           (pzvip_corebus_slave_item     ),
  .REQUEST        (pzvip_corebus_slave_item     ),
  .REQUEST_HANDLE (pzvip_corebus_item           )
) pzvip_corebus_slave_sequencer_base;

class pzvip_corebus_slave_sequencer extends pzvip_corebus_sequencer_base #(
  .BASE (pzvip_corebus_slave_sequencer_base ),
  .ITEM (pzvip_corebus_slave_item           )
);
  protected pzvip_corebus_item_waiter request_waiter;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    request_waiter  = new("request_waiter", this);
    request_waiter.set_context(configuration, status);
  endfunction

  virtual function void write_request(pzvip_corebus_item request);
    request_waiter.write(request);
  endfunction

  virtual task get_request(ref pzvip_corebus_slave_item request);
    pzvip_corebus_item  temp;
    request_waiter.get_item(temp);
    $cast(request, temp);
  endtask

  `tue_component_default_constructor(pzvip_corebus_slave_sequencer)
  `uvm_component_utils(pzvip_corebus_slave_sequencer)
endclass
`endif
