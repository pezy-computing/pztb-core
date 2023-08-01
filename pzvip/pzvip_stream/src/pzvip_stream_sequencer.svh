class pzvip_stream_item_waiter extends tue_item_waiter #(
  .CONFIGURATION  (pzvip_stream_configuration ),
  .STATUS         (pzvip_stream_status        ),
  .ITEM           (pzvip_stream_item          ),
  .ID             (int                        )
);
  function int get_id(pzvip_stream_item item);
    return 0;
  endfunction
  `tue_component_default_constructor(pzvip_stream_item_waiter)
endclass

class pzvip_stream_sequencer extends tue_sequencer #(
  .CONFIGURATION  (pzvip_stream_configuration ),
  .STATUS         (pzvip_stream_status        ),
  .REQ            (pzvip_stream_item          )
);
  uvm_analysis_export #(pzvip_stream_item)  item_export;

  protected pzvip_stream_item_waiter  item_waiter;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    item_export = new("item_export", this);
    item_waiter = new("item_waiter", this);
    item_waiter.set_context(configuration, status);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    item_export.connect(item_waiter.analysis_export);
  endfunction

  task get_item(ref pzvip_stream_item item);
    item_waiter.get_item(item);
  endtask

  `tue_component_default_constructor(pzvip_stream_sequencer)
  `uvm_component_utils(pzvip_stream_sequencer)
endclass
