`ifndef PZVIP_TILELINK_A_SENDER_DRIVER_SVH
`define PZVIP_TILELINK_A_SENDER_DRIVER_SVH
class pzvip_tilelink_a_sender_driver extends pzvip_tilelink_sender_driver_base #(
  pzvip_tilelink_a_vif
);
  protected virtual function pzvip_tilelink_a_vif get_vif();
    return configuration.vif.a;
  endfunction

  protected virtual task drive_message();
    vif.sender_cb.payload.opcode  <= get_opcode();
    vif.sender_cb.payload.param   <= get_param();
    vif.sender_cb.payload.size    <= $clog2(current_message.size);
    vif.sender_cb.payload.source  <= current_message.source;
    vif.sender_cb.payload.address <= current_message.address;
    vif.sender_cb.payload.corrupt <= '0;  //  TODO
    vif.sender_cb.payload.mask    <= current_message.mask[current_beat];
    if (current_message.has_data()) begin
      vif.sender_cb.payload.data  <= current_message.data[current_beat];
    end
  endtask

  protected virtual function pzvip_tilelink_a_opcode get_opcode();
    case (current_message.opcode)
      PZVIP_TILELINK_PUT_FULL_DATA:     return PZVIP_TILELINK_A_PUT_FULL_DATA;
      PZVIP_TILELINK_PUT_PARTIAL_DATA:  return PZVIP_TILELINK_A_PUT_PARTIAL_DATA;
      PZVIP_TILELINK_ARITHMETIC_DATA:   return PZVIP_TILELINK_A_ARITHMETIC_DATA;
      PZVIP_TILELINK_LOGICAL_DATA:      return PZVIP_TILELINK_A_LOGICAL_DATA;
      PZVIP_TILELINK_GET:               return PZVIP_TILELINK_A_GET;
      PZVIP_TILELINK_HINT:              return PZVIP_TILELINK_A_HINT;
      PZVIP_TILELINK_ACQUIRE_BLOCK:     return PZVIP_TILELINK_A_ACQUIRE_BLOCK;
      PZVIP_TILELINK_ACQUIRE_PERM:      return PZVIP_TILELINK_A_ACQUIRE_PERM;
    endcase
  endfunction

  protected virtual function bit [2:0] get_param();
    bit [2:0] param = 0;
    if (current_message.opcode == PZVIP_TILELINK_ARITHMETIC_DATA) begin
      case (current_message.atomic_operation)
        PZVIP_TILELINK_MIN:   param = 0;
        PZVIP_TILELINK_MAX:   param = 1;
        PZVIP_TILELINK_MINU:  param = 2;
        PZVIP_TILELINK_MAXU:  param = 3;
        PZVIP_TILELINK_ADD:   param = 4;
      endcase
    end
    else if (current_message.opcode == PZVIP_TILELINK_LOGICAL_DATA) begin
      case (current_message.atomic_operation)
        PZVIP_TILELINK_XOR:   param = 0;
        PZVIP_TILELINK_OR:    param = 1;
        PZVIP_TILELINK_AND:   param = 2;
        PZVIP_TILELINK_SWAP:  param = 3;
      endcase
    end
    else if (current_message.opcode == PZVIP_TILELINK_HINT) begin
      case (current_message.hint)
        PZVIP_TILELINK_PREFETCH_READ:   param = 0;
        PZVIP_TILELINK_PREFETCH_WRITE:  param = 1;
      endcase
    end
    else if (current_message.opcode inside {
      PZVIP_TILELINK_ACQUIRE_BLOCK, PZVIP_TILELINK_ACQUIRE_PERM
    }) begin
      case (current_message.permission_transfer)
        PZVIP_TILELINK_N_TO_B:  param = 0;
        PZVIP_TILELINK_N_TO_T:  param = 1;
        PZVIP_TILELINK_B_TO_T:  param = 2;
      endcase
    end
    return param;
  endfunction

  `tue_component_default_constructor(pzvip_tilelink_a_sender_driver)
  `uvm_component_utils(pzvip_tilelink_a_sender_driver)
endclass
`endif
