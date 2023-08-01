`ifndef PZVIP_TILELINK_E_SENDER_DRIVER_SVH
`define PZVIP_TILELINK_E_SENDER_DRIVER_SVH
class pzvip_tilelink_e_sender_driver extends pzvip_tilelink_sender_driver_base #(
  pzvip_tilelink_e_vif
);
  protected virtual function pzvip_tilelink_e_vif get_vif();
    return configuration.vif.e;
  endfunction

  protected virtual function int get_id(pzvip_tilelink_message_item response);
    return response.sink;
  endfunction

  protected virtual task drive_message();
    vif.sender_cb.payload.sink  <= current_message.sink;
  endtask

  `tue_component_default_constructor(pzvip_tilelink_e_sender_driver)
  `uvm_component_utils(pzvip_tilelink_e_sender_driver)
endclass
`endif
