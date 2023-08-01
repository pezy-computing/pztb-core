`ifndef PZVIP_COREBUS_SEQUENCER_BASE_SVH
`define PZVIP_COREBUS_SEQUENCER_BASE_SVH
class pzvip_corebus_item_waiter extends tue_item_waiter #(
  .CONFIGURATION  (pzvip_corebus_configuration  ),
  .STATUS         (pzvip_corebus_status         ),
  .ITEM           (pzvip_corebus_item           ),
  .ID             (pzvip_corebus_id             )
);
  function pzvip_corebus_id get_id(pzvip_corebus_item item);
    return item.id;
  endfunction
  `tue_component_default_constructor(pzvip_corebus_item_waiter)
endclass

class pzvip_corebus_sequencer_base #(
  type  BASE  = uvm_sequencer,
  type  ITEM  = uvm_sequence_item
) extends BASE;
  uvm_analysis_export #(pzvip_corebus_item) command_item_export;
  uvm_analysis_export #(pzvip_corebus_item) request_item_export;
  uvm_analysis_export #(pzvip_corebus_item) response_item_export;
  uvm_analysis_export #(pzvip_corebus_item) item_export;

  protected pzvip_corebus_item_waiter command_item_waiter;
  protected pzvip_corebus_item_waiter request_item_waiter;
  protected pzvip_corebus_item_waiter response_item_waiter;
  protected pzvip_corebus_item_waiter item_waiter;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    command_item_export = new("command_item_export", this);
    command_item_waiter = new("command_item_waiter", this);
    command_item_waiter.set_context(configuration, status);

    request_item_export = new("request_item_export", this);
    request_item_waiter = new("request_item_waiter", this);
    request_item_waiter.set_context(configuration, status);

    response_item_export  = new("response_item_export", this);
    response_item_waiter  = new("response_item_waiter", this);
    response_item_waiter.set_context(configuration, status);

    item_export = new("item_export", this);
    item_waiter = new("item_waiter", this);
    item_waiter.set_context(configuration, status);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    command_item_export.connect(command_item_waiter.analysis_export);
    request_item_export.connect(request_item_waiter.analysis_export);
    response_item_export.connect(response_item_waiter.analysis_export);
    item_export.connect(item_waiter.analysis_export);
  endfunction

  `define pzvip_corebus_define_item_getter_tasks(ITEM_TYPE) \
  virtual task get_``ITEM_TYPE(ref ITEM item); \
    pzvip_corebus_item  temp; \
    ITEM_TYPE``_waiter.get_item(temp); \
    $cast(item, temp); \
  endtask \
  virtual task get_``ITEM_TYPE``_by_id(input pzvip_corebus_id id, ref ITEM item); \
    pzvip_corebus_item  temp; \
    ITEM_TYPE``_waiter.get_item_by_id(id, temp); \
    $cast(item, temp); \
  endtask

  `pzvip_corebus_define_item_getter_tasks(command_item )
  `pzvip_corebus_define_item_getter_tasks(request_item )
  `pzvip_corebus_define_item_getter_tasks(response_item)
  `pzvip_corebus_define_item_getter_tasks(item         )

  `undef  pzvip_corebus_define_item_getter_tasks

  `tue_component_default_constructor(pzvip_corebus_sequencer_base)
endclass
`endif
