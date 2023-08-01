`ifndef PZVIP_TILELINK_C_SENDER_DRIVER_SVH
`define PZVIP_TILELINK_C_SENDER_DRIVER_SVH
class pzvip_tilelink_c_sender_driver extends pzvip_tilelink_sender_driver_base #(
  pzvip_tilelink_c_vif
);
  protected virtual function pzvip_tilelink_c_vif get_vif();
    return configuration.vif.c;
  endfunction

  protected virtual function int get_id(pzvip_tilelink_message_item response);
    return response.source;
  endfunction

  protected virtual task drive_message();
    vif.sender_cb.payload.opcode  <= get_opcode();
    vif.sender_cb.payload.param   <= get_param();
    vif.sender_cb.payload.size    <= $clog2(current_message.size);
    vif.sender_cb.payload.source  <= current_message.source;
    vif.sender_cb.payload.address <= current_message.address;
    vif.sender_cb.payload.corrupt <= '0;  //  TODO
    if (current_message.has_data()) begin
      vif.sender_cb.payload.data  <= current_message.data[current_beat];
    end
  endtask

  protected virtual function pzvip_tilelink_c_opcode get_opcode();
    case (current_message.opcode)
      PZVIP_TILELINK_ACCESS_ACK:      return PZVIP_TILELINK_C_ACCESS_ACK;
      PZVIP_TILELINK_ACCESS_ACK_DATA: return PZVIP_TILELINK_C_ACCESS_ACK_DATA;
      PZVIP_TILELINK_HINT_ACK:        return PZVIP_TILELINK_C_HINT_ACK;
      PZVIP_TILELINK_PROBE_ACK:       return PZVIP_TILELINK_C_PROBE_ACK;
      PZVIP_TILELINK_PROBE_ACK_DATA:  return PZVIP_TILELINK_C_PROBE_ACK_DATA;
      PZVIP_TILELINK_RELEASE:         return PZVIP_TILELINK_C_RELEASE;
      PZVIP_TILELINK_RELEASE_DATA:    return PZVIP_TILELINK_C_RELEASE_DATA;
    endcase
  endfunction

  protected virtual function bit [2:0] get_param();
    bit [2:0] param = 0;
    if (current_message.opcode inside {
      PZVIP_TILELINK_PROBE_ACK,
      PZVIP_TILELINK_PROBE_ACK_DATA,
      PZVIP_TILELINK_RELEASE,
      PZVIP_TILELINK_RELEASE_DATA
    }) begin
      case (current_message.permission_transfer)
        PZVIP_TILELINK_T_TO_B:  param = 0;
        PZVIP_TILELINK_T_TO_N:  param = 1;
        PZVIP_TILELINK_B_TO_N:  param = 2;
        PZVIP_TILELINK_T_TO_T:  param = 3;
        PZVIP_TILELINK_B_TO_B:  param = 4;
        PZVIP_TILELINK_N_TO_N:  param = 5;
      endcase
    end
    return param;
  endfunction

  `tue_component_default_constructor(pzvip_tilelink_c_sender_driver)
  `uvm_component_utils(pzvip_tilelink_c_sender_driver)
endclass
`endif
