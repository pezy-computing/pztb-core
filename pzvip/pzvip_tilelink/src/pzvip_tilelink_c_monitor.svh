`ifndef PZVIP_TILELINK_C_MONITOR_SVH
`define PZVIP_TILELINK_C_MONITOR_SVH
class pzvip_tilelink_c_monitor_base #(
  type  ITEM      = pzvip_tilelink_message_item,
  bit   IS_SENDER = 1
) extends pzvip_tilelink_monitor_base #(
  .VIF        (pzvip_tilelink_c_vif ),
  .ITEM       (ITEM                 ),
  .IS_SENDER  (IS_SENDER            )
);
  protected virtual function pzvip_tilelink_c_vif get_vif();
    return configuration.vif.c;
  endfunction

  protected virtual function void sample_request();
    current_item.opcode               = get_opcode();
    current_item.source               = vif.monitor_cb.payload.source;
    current_item.address              = vif.monitor_cb.payload.address;
    current_item.size                 = 2**vif.monitor_cb.payload.size;
    current_item.corrupt              = 0;  //  TODO
    current_item.permission_transfer  = get_permission_transfer();
    if (current_item.has_data()) begin
      current_item.data = new[current_item.number_of_beats()];
    end
  endfunction

  protected virtual function void sample_data();
    current_item.data[current_beat] = vif.monitor_cb.payload.data;
  endfunction

  local function pzvip_tilelink_opcode get_opcode();
    case (vif.monitor_cb.payload.opcode)
      PZVIP_TILELINK_C_ACCESS_ACK:      return PZVIP_TILELINK_ACCESS_ACK;
      PZVIP_TILELINK_C_ACCESS_ACK_DATA: return PZVIP_TILELINK_ACCESS_ACK_DATA;
      PZVIP_TILELINK_C_HINT_ACK:        return PZVIP_TILELINK_HINT_ACK;
      PZVIP_TILELINK_C_PROBE_ACK:       return PZVIP_TILELINK_PROBE_ACK;
      PZVIP_TILELINK_C_PROBE_ACK_DATA:  return PZVIP_TILELINK_PROBE_ACK_DATA;
      PZVIP_TILELINK_C_RELEASE:         return PZVIP_TILELINK_RELEASE;
      PZVIP_TILELINK_C_RELEASE_DATA:    return PZVIP_TILELINK_RELEASE_DATA;
    endcase
  endfunction

  local function pzvip_tilelink_permission_transfer get_permission_transfer();
    bit [2:0] param = vif.monitor_cb.payload.param;

    if (!(current_item.opcode inside {
      PZVIP_TILELINK_PROBE_ACK,
      PZVIP_TILELINK_PROBE_ACK_DATA,
      PZVIP_TILELINK_RELEASE,
      PZVIP_TILELINK_RELEASE_DATA
    })) begin
      return pzvip_tilelink_permission_transfer'(0);
    end
    else if (param <= 5) begin
      case (param)
        0:  return PZVIP_TILELINK_T_TO_B;
        1:  return PZVIP_TILELINK_T_TO_N;
        2:  return PZVIP_TILELINK_B_TO_N;
        3:  return PZVIP_TILELINK_T_TO_T;
        4:  return PZVIP_TILELINK_B_TO_B;
        5:  return PZVIP_TILELINK_N_TO_N;
      endcase
    end
    else begin
      //  TODO
    end
  endfunction

  `tue_component_default_constructor(pzvip_tilelink_c_monitor_base)
endclass

class pzvip_tilelink_c_sender_monitor extends pzvip_tilelink_c_monitor_base #(
  .ITEM       (pzvip_tilelink_sender_message_item ),
  .IS_SENDER  (1                                  )
);
  `tue_component_default_constructor(pzvip_tilelink_c_sender_monitor)
  `uvm_component_utils(pzvip_tilelink_c_sender_monitor)
endclass

class pzvip_tilelink_c_receiver_monitor extends pzvip_tilelink_c_monitor_base #(
  .ITEM       (pzvip_tilelink_receiver_message_item ),
  .IS_SENDER  (0                                    )
);
  `tue_component_default_constructor(pzvip_tilelink_c_receiver_monitor)
  `uvm_component_utils(pzvip_tilelink_c_receiver_monitor)
endclass
`endif
