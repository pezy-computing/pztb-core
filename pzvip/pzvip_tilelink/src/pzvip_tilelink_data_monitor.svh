`ifndef PZVIP_TILELINK_DATA_MONITOR_SVH
`define PZVIP_TILELINK_DATA_MONITOR_SVH
class pzvip_tilelink_data_monitor extends tue_subscriber #(
  .CONFIGURATION  (pzvip_tilelink_configuration ),
  .STATUS         (pzvip_tilelink_status        ),
  .T              (pzvip_tilelink_message_item  )
);
  protected pzvip_tilelink_memory memory;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (status.memory == null) begin
      status.memory = pzvip_tilelink_memory::type_id::create("memory");
      status.memory.set_context(configuration, status);
    end
    memory  = status.memory;
  endfunction

  function void write(pzvip_tilelink_message_item t);
    case (t.opcode)
      PZVIP_TILELINK_PUT_FULL_DATA,
      PZVIP_TILELINK_PUT_PARTIAL_DATA: begin
        do_normal_write(t);
      end
      PZVIP_TILELINK_ARITHMETIC_DATA,
      PZVIP_TILELINK_LOGICAL_DATA: begin
        do_atomic_write(t);
      end
    endcase
  endfunction

  protected function void do_normal_write(pzvip_tilelink_message_item message);
    pzvip_tilelink_mask full_mask = (1 << configuration.byte_width) - 1;
    foreach (message.data[i]) begin
      pzvip_tilelink_mask mask;

      if (message.opcode == PZVIP_TILELINK_PUT_FULL_DATA) begin
        mask  = full_mask;
      end
      else begin
        mask  = message.mask[i];
      end

      memory.put(
        message.data[i],
        mask,
        message.address,
        i,
        message.size
      );
    end
  endfunction

  protected function void do_atomic_write(pzvip_tilelink_message_item message);
  endfunction

  `tue_component_default_constructor(pzvip_tilelink_data_monitor)
  `uvm_component_utils(pzvip_tilelink_data_monitor)
endclass
`endif
