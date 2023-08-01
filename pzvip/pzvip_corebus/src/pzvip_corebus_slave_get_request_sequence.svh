`ifndef PZVIP_COREBUS_SLAVE_GET_REQUEST_SEQUENCE_SVH
`define PZVIP_COREBUS_SLAVE_GET_REQUEST_SEQUENCE_SVH
class pzvip_corebus_slave_get_request_sequence extends pzvip_corebus_slave_sequence;
  rand  int                       id;
  rand  bit                       command_only;
        pzvip_corebus_slave_item  request;

  constraint c_valid_id {
    (id == -1) || ((id >> this.configuration.id_width) == 0);
  }

  constraint c_default_id {
    soft id == -1;
  }

  constraint c_default_command_only {
    soft command_only == 0;
  }

  task body();
    if (command_only && (id >= 0)) begin
      p_sequencer.get_command_item_by_id(id, request);
    end
    else if (command_only) begin
      p_sequencer.get_command_item(request);
    end
    else if (id >= 0) begin
      p_sequencer.get_request_item_by_id(id, request);
    end
    else begin
      p_sequencer.get_request_item(request);
    end
  endtask

  `tue_object_default_constructor(pzvip_corebus_slave_get_request_sequence)
  `uvm_object_utils_begin(pzvip_corebus_slave_get_request_sequence)
    `uvm_field_int(id, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(command_only, UVM_DEFAULT | UVM_BIN)
    `uvm_field_object(request, UVM_DEFAULT)
  `uvm_object_utils_end
endclass
`endif
