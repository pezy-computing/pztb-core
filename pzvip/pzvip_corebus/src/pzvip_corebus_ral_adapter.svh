`ifndef PZVIP_COREBUS_RAL_ADAPTER_SVH
`define PZVIP_COREBUS_RAL_ADAPTER_SVH
class pzvip_corebus_ral_adapter extends tue_object_base #(
  .BASE           (uvm_reg_adapter              ),
  .CONFIGURATION  (pzvip_corebus_configuration  ),
  .STATUS         (pzvip_corebus_status         )
);
  protected pzvip_corebus_command_type  write_command;

  function new(string name = "pzvip_corebus_ral_adapter");
    super.new(name);
    supports_byte_enable  = 0;
    provides_responses    = 1;
    write_command         = PZVIP_COREBUS_WRITE;
  endfunction

  function void use_non_posted_write();
    write_command = PZVIP_COREBUS_WRITE_NON_POSTED;
  endfunction

  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    pzvip_corebus_master_item item;
    item  = pzvip_corebus_master_item::type_id::create("item");
    item.set_context(configuration, status);
    item.c_valid_start_delay.constraint_mode(0);
    item.c_valid_response_accept_delay.constraint_mode(0);
    if (item.randomize() with {
      if (rw.kind == UVM_WRITE) {
        command         == write_command;
        request_data[0] == rw.data;
      }
      else {
        command == PZVIP_COREBUS_READ;
      }
      address                    == rw.addr;
      start_delay                == 0;
      response_accept_delay.size == 1;
      response_accept_delay[0]   == 0;
      use_response_port          == 1;
    }) begin
      return item;
    end
    else begin
      `uvm_fatal("RNDFLD", "Randomization failed")
    end
  endfunction

  virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    pzvip_corebus_master_item item;
    $cast(item, bus_item);
    rw.addr     = item.address;
    rw.kind     = (item.is_write_request()) ? UVM_WRITE            : UVM_READ;
    rw.data     = (item.is_write_request()) ? item.request_data[0] : item.response_data[0];
    rw.byte_en  = (1 << (configuration.data_width / 8)) - 1;
    if (item.is_non_posted_request()) begin
      rw.status = (item.error[0]) ? UVM_NOT_OK : UVM_IS_OK;
    end
  endfunction

  `uvm_object_utils(pzvip_corebus_ral_adapter)
endclass
`endif
