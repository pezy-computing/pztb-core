`ifndef PZVIP_TILELINK_B_MONITOR_SVH
`define PZVIP_TILELINK_B_MONITOR_SVH
class pzvip_tilelink_b_monitor_base #(
  type  ITEM      = pzvip_tilelink_message_item,
  bit   IS_SENDER = 1
) extends pzvip_tilelink_monitor_base #(
  .VIF        (pzvip_tilelink_b_vif ),
  .ITEM       (ITEM                 ),
  .IS_SENDER  (IS_SENDER            )
);
  protected virtual function bit is_sender();
    return configuration.is_slave_port();
  endfunction

  protected virtual function pzvip_tilelink_b_vif get_vif();
    return configuration.vif.b;
  endfunction

  protected virtual function void sample_request();
    current_item.opcode               = get_opcode();
    current_item.source               = vif.monitor_cb.payload.source;
    current_item.address              = vif.monitor_cb.payload.address;
    current_item.size                 = 2**vif.monitor_cb.payload.size;
    current_item.corrupt              = 0;  //  TODO
    current_item.atomic_operation     = get_atomic_operation();
    current_item.hint                 = get_hint();
    current_item.permission_transfer  = get_permission_transfer();
    if (current_item.has_data()) begin
      current_item.mask = new[current_item.number_of_beats()];
      current_item.data = new[current_item.number_of_beats()];
    end
    else begin
      current_item.mask     = new[1];
      current_item.mask[0]  = vif.monitor_cb.payload.mask;
    end
  endfunction

  protected virtual function void sample_data();
    current_item.mask[current_beat] = vif.monitor_cb.payload.mask;
    current_item.data[current_beat] = vif.monitor_cb.payload.data;
  endfunction

  local function pzvip_tilelink_opcode get_opcode();
    case (vif.monitor_cb.payload.opcode)
      PZVIP_TILELINK_B_PUT_FULL_DATA:     return PZVIP_TILELINK_PUT_FULL_DATA;
      PZVIP_TILELINK_B_PUT_PARTIAL_DATA:  return PZVIP_TILELINK_PUT_PARTIAL_DATA;
      PZVIP_TILELINK_B_ARITHMETIC_DATA:   return PZVIP_TILELINK_ARITHMETIC_DATA;
      PZVIP_TILELINK_B_LOGICAL_DATA:      return PZVIP_TILELINK_LOGICAL_DATA;
      PZVIP_TILELINK_B_GET:               return PZVIP_TILELINK_GET;
      PZVIP_TILELINK_B_HINT:              return PZVIP_TILELINK_HINT;
      PZVIP_TILELINK_B_PROBE:             return PZVIP_TILELINK_PROBE;
    endcase
  endfunction

  local function pzvip_tilelink_atomic_operation get_atomic_operation();
    bit [2:0] param = vif.monitor_cb.payload.param;

    if (!(current_item.opcode inside {
      PZVIP_TILELINK_ARITHMETIC_DATA,
      PZVIP_TILELINK_LOGICAL_DATA
    })) begin
      return pzvip_tilelink_atomic_operation'(0);
    end
    else if ((current_item.opcode == PZVIP_TILELINK_ARITHMETIC_DATA) && (param <= 4)) begin
      case (param)
        0:  return PZVIP_TILELINK_MIN;
        1:  return PZVIP_TILELINK_MAX;
        2:  return PZVIP_TILELINK_MINU;
        3:  return PZVIP_TILELINK_MAXU;
        4:  return PZVIP_TILELINK_ADD;
      endcase
    end
    else if ((current_item.opcode == PZVIP_TILELINK_LOGICAL_DATA) && (param <= 3)) begin
      case (param)
        0:  return PZVIP_TILELINK_XOR;
        1:  return PZVIP_TILELINK_OR;
        2:  return PZVIP_TILELINK_AND;
        3:  return PZVIP_TILELINK_SWAP;
      endcase
    end
    else begin
      //  Print warning or error message
    end
  endfunction

  local function pzvip_tilelink_hint get_hint();
    bit [2:0] param = vif.monitor_cb.payload.param;
    if (current_item.opcode == PZVIP_TILELINK_HINT) begin
      if (param == 0) begin
        return PZVIP_TILELINK_PREFETCH_READ;
      end
      else if (param == 1) begin
        return PZVIP_TILELINK_PREFETCH_WRITE;
      end
      else begin
        //  Print warning or error message
      end
    end
    else begin
      return pzvip_tilelink_hint'(0);
    end
  endfunction

  local function pzvip_tilelink_permission_transfer get_permission_transfer();
    bit [2:0] param = vif.monitor_cb.payload.param;
    if (current_item.opcode != PZVIP_TILELINK_PROBE) begin
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
      //  Print warning message
    end
  endfunction

  `tue_component_default_constructor(pzvip_tilelink_b_monitor_base)
endclass

class pzvip_tilelink_b_sender_monitor extends pzvip_tilelink_b_monitor_base #(
  .ITEM       (pzvip_tilelink_sender_message_item ),
  .IS_SENDER  (1                                  )
);
  `tue_component_default_constructor(pzvip_tilelink_b_sender_monitor)
  `uvm_component_utils(pzvip_tilelink_b_sender_monitor)
endclass

class pzvip_tilelink_b_receiver_monitor extends pzvip_tilelink_b_monitor_base #(
  .ITEM       (pzvip_tilelink_receiver_message_item ),
  .IS_SENDER  (0                                    )
);
  `tue_component_default_constructor(pzvip_tilelink_b_receiver_monitor)
  `uvm_component_utils(pzvip_tilelink_b_receiver_monitor)
endclass
`endif
