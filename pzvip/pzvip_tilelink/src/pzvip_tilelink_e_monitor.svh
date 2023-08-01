`ifndef PZVIP_TILELINK_E_MONITOR_SVH
`define PZVIP_TILELINK_E_MONITOR_SVH
class pzvip_tilelink_e_monitor_base #(
  type  ITEM      = pzvip_tilelink_message_item,
  bit   IS_SENDER = 1
) extends pzvip_tilelink_monitor_base #(
  .VIF        (pzvip_tilelink_e_vif ),
  .ITEM       (ITEM                 ),
  .IS_SENDER  (IS_SENDER            )
);
  protected virtual function pzvip_tilelink_e_vif get_vif();
    return configuration.vif.e;
  endfunction

  protected virtual function void sample_request();
    current_item.opcode = PZVIP_TILELINK_GRANT_ACK;
    current_item.sink   = vif.monitor_cb.payload.sink;
  endfunction

  protected virtual function void sample_data();
  endfunction

  `tue_component_default_constructor(pzvip_tilelink_e_monitor_base)
endclass

class pzvip_tilelink_e_sender_monitor extends pzvip_tilelink_e_monitor_base #(
  .ITEM       (pzvip_tilelink_sender_message_item ),
  .IS_SENDER  (1                                  )
);
  `tue_component_default_constructor(pzvip_tilelink_e_sender_monitor)
  `uvm_component_utils(pzvip_tilelink_e_sender_monitor)
endclass

class pzvip_tilelink_e_receiver_monitor extends pzvip_tilelink_e_monitor_base #(
  .ITEM       (pzvip_tilelink_receiver_message_item ),
  .IS_SENDER  (0                                    )
);
  `tue_component_default_constructor(pzvip_tilelink_e_receiver_monitor)
  `uvm_component_utils(pzvip_tilelink_e_receiver_monitor)
endclass
`endif
