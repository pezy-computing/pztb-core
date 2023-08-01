`ifndef PZVIP_TILELINK_B_RECEIVER_DRIVER_SVH
`define PZVIP_TILELINK_B_RECEIVER_DRIVER_SVH
class pzvip_tilelink_b_receiver_driver extends pzvip_tilelink_receiver_driver_base #(
  pzvip_tilelink_b_vif
);
  protected virtual function pzvip_tilelink_b_vif get_vif();
    return configuration.vif.b;
  endfunction

  protected virtual function int get_default_ready();
    return configuration.b_default_ready;
  endfunction

  protected virtual function bit has_data();
    if (vif.monitor_cb.payload.opcode inside {
      PZVIP_TILELINK_B_PUT_FULL_DATA,
      PZVIP_TILELINK_B_PUT_PARTIAL_DATA,
      PZVIP_TILELINK_B_ARITHMETIC_DATA,
      PZVIP_TILELINK_B_LOGICAL_DATA
    }) begin
      return 1;
    end
    else begin
      return 0;
    end
  endfunction

  protected virtual function int get_size();
    return vif.monitor_cb.payload.size;
  endfunction

  `tue_component_default_constructor(pzvip_tilelink_b_receiver_driver)
  `uvm_component_utils(pzvip_tilelink_b_receiver_driver)
endclass
`endif
