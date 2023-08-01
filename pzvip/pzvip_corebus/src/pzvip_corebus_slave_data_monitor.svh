`ifndef PZVIP_COREBUS_SLAVE_DATA_MONITOR_SVH
`define PZVIP_COREBUS_SLAVE_DATA_MONITOR_SVH
class pzvip_corebus_slave_data_monitor extends tue_subscriber #(
  .CONFIGURATION  (pzvip_corebus_configuration  ),
  .STATUS         (pzvip_corebus_status         ),
  .T              (pzvip_corebus_item           )
);
  protected int                   byte_width;
  protected pzvip_corebus_memory  memory;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    byte_width  = configuration.data_width / 8;
    if (status.memory == null) begin
      status.memory = pzvip_corebus_memory::type_id::create("memory");
      status.memory.set_context(configuration, status);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    memory  = status.memory;
  endfunction

  function void write(pzvip_corebus_item t);
    if (t.is_write_request()) begin
      monitor_write_data(t, 1);
    end
    else if (configuration.monitor_read_data && t.is_read_request() && t.response_ended()) begin
      monitor_write_data(t, 0);
    end
  endfunction

  function void connect_pa_writer(pzvip_corebus_pa_writer pa_writer);
    if ((pa_writer != null) && configuration.pa_writer.enable_memory_writer) begin
      memory.connect_pa_writer(pa_writer);
    end
  endfunction

  protected virtual function void monitor_write_data(pzvip_corebus_item item, bit is_request_data);
    int burst_length  = item.get_burst_length();
    for (int i = 0;i < burst_length;++i) begin
      pzvip_corebus_data        data;
      pzvip_corebus_byte_enable byte_enable;

      if (is_request_data) begin
        data        = item.get_request_data(i);
        byte_enable = item.get_byte_enable(i);
      end
      else begin
        data        = item.get_response_data(i);
        byte_enable = (1 << byte_width) - 1;
      end

      memory.put(
        .data         (data         ),
        .byte_enable  (byte_enable  ),
        .base         (item.address ),
        .word_index   (i            ),
        .word_width   (byte_width   ),
        .backdoor     (0            )
      );
    end
  endfunction

  `tue_component_default_constructor(pzvip_corebus_slave_data_monitor)
  `uvm_component_utils(pzvip_corebus_slave_data_monitor)
endclass
`endif
