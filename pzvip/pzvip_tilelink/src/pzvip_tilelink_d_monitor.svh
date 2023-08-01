`ifndef PZVIP_TILELINK_D_MONITOR_SVH
`define PZVIP_TILELINK_D_MONITOR_SVH
class pzvip_tilelink_d_monitor_base #(
  type  ITEM      = pzvip_tilelink_message_item,
  bit   IS_SENDER = 1
) extends pzvip_tilelink_monitor_base #(
  .VIF        (pzvip_tilelink_d_vif ),
  .ITEM       (ITEM                 ),
  .IS_SENDER  (IS_SENDER            )
);
  protected virtual function pzvip_tilelink_d_vif get_vif();
    return configuration.vif.d;
  endfunction

  protected virtual function void sample_request();
    current_item.opcode               = get_opcode();
    current_item.source               = vif.monitor_cb.payload.source;
    current_item.sink                 = vif.monitor_cb.payload.sink;
    current_item.size                 = 2**vif.monitor_cb.payload.size;
    current_item.permission_transfer  = get_permission_transfer();
    current_item.corrupt              = 0;  //  TODO
    current_item.denied               = 0;  //  TODO
    if (current_item.has_data()) begin
      current_item.data = new[current_item.number_of_beats()];
    end
  endfunction

  protected virtual function void sample_data();
    current_item.data[current_beat] = vif.monitor_cb.payload.data;
  endfunction

  local function pzvip_tilelink_opcode get_opcode();
    case (vif.monitor_cb.payload.opcode)
      PZVIP_TILELINK_D_ACCESS_ACK:      return PZVIP_TILELINK_ACCESS_ACK;
      PZVIP_TILELINK_D_ACCESS_ACK_DATA: return PZVIP_TILELINK_ACCESS_ACK_DATA;
      PZVIP_TILELINK_D_HINT_ACK:        return PZVIP_TILELINK_HINT_ACK;
      PZVIP_TILELINK_D_GRANT:           return PZVIP_TILELINK_GRANT;
      PZVIP_TILELINK_D_GRANT_DATA:      return PZVIP_TILELINK_GRANT_DATA;
      PZVIP_TILELINK_D_RELEASE_ACK:     return PZVIP_TILELINK_RELEASE_ACK;
    endcase
  endfunction

  local function pzvip_tilelink_permission_transfer get_permission_transfer();
    bit [2:0] param = vif.monitor_cb.payload.param;
    if (!(current_item.opcode inside {
      PZVIP_TILELINK_GRANT,
      PZVIP_TILELINK_GRANT_DATA
    })) begin
      return pzvip_tilelink_permission_transfer'(0);
    end
    else if (param <= 2) begin
      case (param)
        0:  return PZVIP_TILELINK_TO_T;
        1:  return PZVIP_TILELINK_TO_B;
        2:  return PZVIP_TILELINK_TO_N;
      endcase
    end
    else begin
      //  Print warning or error message
    end
  endfunction

  `tue_component_default_constructor(pzvip_tilelink_d_monitor_base)
endclass

class pzvip_tilelink_d_sender_monitor extends pzvip_tilelink_d_monitor_base #(
  .ITEM       (pzvip_tilelink_sender_message_item ),
  .IS_SENDER  (1                                  )
);
  `tue_component_default_constructor(pzvip_tilelink_d_sender_monitor)
  `uvm_component_utils(pzvip_tilelink_d_sender_monitor)
endclass

class pzvip_tilelink_d_receiver_monitor extends pzvip_tilelink_d_monitor_base #(
  .ITEM       (pzvip_tilelink_receiver_message_item ),
  .IS_SENDER  (0                                    )
);
  `tue_component_default_constructor(pzvip_tilelink_d_receiver_monitor)
  `uvm_component_utils(pzvip_tilelink_d_receiver_monitor)
endclass
`endif
