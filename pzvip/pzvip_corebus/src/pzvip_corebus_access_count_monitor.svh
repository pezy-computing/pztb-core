`ifndef PZVIP_COREBUS_ACCESS_COUNT_MONITOR_SVH
`define PZVIP_COREBUS_ACCESS_COUNT_MONITOR_SVH
typedef tue_subscriber #(
  .CONFIGURATION  (pzvip_corebus_configuration  ),
  .STATUS         (pzvip_corebus_status         ),
  .T              (pzvip_corebus_item           )
) pzvip_corebus_access_count_sub_monitor_base;

class pzvip_corebus_command_count_monitor extends pzvip_corebus_access_count_sub_monitor_base;
  function void write(pzvip_corebus_item t);
    status.access_count.command_count[t.command]  += 1;
  endfunction
  `tue_component_default_constructor(pzvip_corebus_command_count_monitor)
  `uvm_component_utils(pzvip_corebus_command_count_monitor)
endclass

class pzvip_corebus_ongoing_non_posted_access_count_monitor extends pzvip_corebus_access_count_sub_monitor_base;
  function void write(pzvip_corebus_item t);
    if (t.response_ended()) begin
      status.access_count.ongoing_non_posted_access_count -= 1;
    end
    else if (t.is_non_posted_request() && t.command_ended()) begin
      status.access_count.ongoing_non_posted_access_count += 1;
    end
  endfunction

  task run_phase(uvm_phase phase);
    if (configuration.vif == null) begin
      return;
    end

    forever @(negedge configuration.vif.monitor_cb.reset_n) begin
      status.access_count.ongoing_non_posted_access_count = 0;
    end
  endtask

  `tue_component_default_constructor(pzvip_corebus_ongoing_non_posted_access_count_monitor)
  `uvm_component_utils(pzvip_corebus_ongoing_non_posted_access_count_monitor)
endclass

class pzvip_corebus_access_count_monitor extends tue_monitor #(
  .CONFIGURATION  (pzvip_corebus_configuration  ),
  .STATUS         (pzvip_corebus_status         )
);
  uvm_analysis_export #(pzvip_corebus_item) command_item_export;
  uvm_analysis_port #(pzvip_corebus_item)   request_item_export;  // use uvm_analysis_port temporary
  uvm_analysis_export #(pzvip_corebus_item) response_item_export;

  protected pzvip_corebus_access_count                            access_count;
  protected pzvip_corebus_command_count_monitor                   command_count_monitor;
  protected pzvip_corebus_ongoing_non_posted_access_count_monitor ongoing_non_posted_access_count_monitor;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (status.access_count == null) begin
      status.access_count = pzvip_corebus_access_count::type_id::create("access_count");
    end

    command_item_export   = new("command_item_export" , this);
    request_item_export   = new("request_item_export" , this);
    response_item_export  = new("response_item_export", this);

    command_count_monitor = pzvip_corebus_command_count_monitor::type_id::create("command_count_monitor", this);
    command_count_monitor.set_context(configuration, status);

    ongoing_non_posted_access_count_monitor = pzvip_corebus_ongoing_non_posted_access_count_monitor::type_id::create("ongoing_non_posted_access_count_monitor", this);
    ongoing_non_posted_access_count_monitor.set_context(configuration, status);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    access_count  = status.access_count;
    command_item_export.connect(command_count_monitor.analysis_export);
    command_item_export.connect(ongoing_non_posted_access_count_monitor.analysis_export);
    response_item_export.connect(ongoing_non_posted_access_count_monitor.analysis_export);
  endfunction

  `tue_component_default_constructor(pzvip_corebus_access_count_monitor)
  `uvm_component_utils(pzvip_corebus_access_count_monitor)
endclass
`endif
