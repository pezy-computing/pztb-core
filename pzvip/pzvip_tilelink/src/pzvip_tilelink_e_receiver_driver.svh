`ifndef PZVIP_TILELINK_E_RECEIVER_DRIVER_SVH
`define PZVIP_TILELINK_E_RECEIVER_DRIVER_SVH
class pzvip_tilelink_e_receiver_driver extends pzvip_tilelink_receiver_driver_base #(
  pzvip_tilelink_e_vif
);
  protected virtual function pzvip_tilelink_e_vif get_vif();
    return configuration.vif.e;
  endfunction

  protected virtual function int get_default_ready();
    return configuration.e_default_ready;
  endfunction

  protected virtual function bit has_data();
    return 0;
  endfunction

  protected virtual function int get_size();
    return 0;
  endfunction

  `tue_component_default_constructor(pzvip_tilelink_e_receiver_driver)
  `uvm_component_utils(pzvip_tilelink_e_receiver_driver)
endclass
`endif
