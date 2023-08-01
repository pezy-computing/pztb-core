`ifndef PZVIP_TILELINK_D_SENDER_DRIVER_SVH
`define PZVIP_TILELINK_D_SENDER_DRIVER_SVH
class pzvip_tilelink_d_sender_driver extends pzvip_tilelink_sender_driver_base #(
  pzvip_tilelink_d_vif
);
  protected virtual function pzvip_tilelink_d_vif get_vif();
    return configuration.vif.d;
  endfunction

  protected virtual function int get_id(pzvip_tilelink_message_item response);
    return response.source;
  endfunction

  protected virtual task drive_message();
    vif.sender_cb.payload.opcode  <= get_opcode();
    vif.sender_cb.payload.param   <= get_param();
    vif.sender_cb.payload.size    <= $clog2(current_message.size);
    vif.sender_cb.payload.source  <= current_message.source;
    vif.sender_cb.payload.sink    <= current_message.sink;
    vif.sender_cb.payload.corrupt <= '0;  //  TODO
    vif.sender_cb.payload.denied  <= '0;  //  TODO
    if (current_message.has_data()) begin
      vif.sender_cb.payload.data  <= current_message.data[current_beat];
    end
  endtask

  protected virtual function pzvip_tilelink_d_opcode get_opcode();
    case (current_message.opcode)
      PZVIP_TILELINK_ACCESS_ACK:      return PZVIP_TILELINK_D_ACCESS_ACK;
      PZVIP_TILELINK_ACCESS_ACK_DATA: return PZVIP_TILELINK_D_ACCESS_ACK_DATA;
      PZVIP_TILELINK_HINT_ACK:        return PZVIP_TILELINK_D_HINT_ACK;
      PZVIP_TILELINK_GRANT:           return PZVIP_TILELINK_D_GRANT;
      PZVIP_TILELINK_GRANT_DATA:      return PZVIP_TILELINK_D_GRANT_DATA;
      PZVIP_TILELINK_RELEASE_ACK:     return PZVIP_TILELINK_D_RELEASE_ACK;
    endcase
  endfunction

  protected virtual function bit [2:0] get_param();
    bit [2:0] param = 0;
    if (current_message.opcode inside {
      PZVIP_TILELINK_GRANT, PZVIP_TILELINK_GRANT_DATA
    }) begin
      case (current_message.permission_transfer)
        PZVIP_TILELINK_TO_T:  param = 0;
        PZVIP_TILELINK_TO_B:  param = 1;
        PZVIP_TILELINK_TO_N:  param = 2;
      endcase
    end
    return param;
  endfunction

  `tue_component_default_constructor(pzvip_tilelink_d_sender_driver)
  `uvm_component_utils(pzvip_tilelink_d_sender_driver)
endclass
`endif
