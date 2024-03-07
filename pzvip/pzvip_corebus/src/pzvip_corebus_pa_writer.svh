`ifndef PZVIP_COREBUS_PA_WRITER_SVH
`define PZVIP_COREBUS_PA_WRITER_SVH
class pzvip_corebus_pa_writer extends pzvip_pa_writer_param_base #(
  .CONFIGURATION  (pzvip_corebus_configuration  ),
  .STATUS         (pzvip_corebus_status         )
);
  protected string  transaction_uid[int];
  protected string  predecessor_uid[int][$];
  protected string  request_data_uid;
  protected int     request_data_index;
  protected string  response_uid;
  protected int     response_index;

  function new(string name = "pzvip_corebus_pa_writer");
    super.new(name);
    protocol_name     = "pzvip_corebus";
    protocol_version  = "1.0";
  endfunction

  function void build(
    uvm_component               parent,
    pzvip_corebus_configuration configuration
  );
    string  if_path;

    if_path = "";
    if (configuration.vif != null) begin
      if_path = configuration.vif.get_hdl_path();
    end

    super.build(parent, configuration.pa_writer, if_path);
    set_configuration(configuration);
    write_bus_info(configuration);
  endfunction

  function void reset();
    transaction_uid.delete();
    predecessor_uid.delete();
    request_data_uid  = "";
    response_uid      = "";
  endfunction

  function void begin_transaction(pzvip_corebus_item item);
    int id  = item.get_inst_id();
    transaction_uid[id] = create_pa_object("pzvip_corebus_transaction", item.get_request_begin_time());
  endfunction

  function void write_transaction(pzvip_corebus_item item);
    int     id  = item.get_inst_id();
    string  uid = transaction_uid[id];

    write_string_value(uid, "command", item.command.name());
    write_bit_vector_value(uid, "bus_id", item.id, configuration.id_width);
    write_bit_vector_value(uid, "address", item.address, configuration.address_width);
    if (configuration.profile != PZVIP_COREBUS_CSR) begin
      if (item.is_message_request()) begin
        write_bit_vector_value(uid, "message_code", item.message_code, configuration.message_code_width);
      end
      else if (!item.is_atomic_request()) begin
        write_int_value(uid, "length", item.length);
        write_int_value(uid, "burst_length", item.get_burst_length());
        write_int_value(uid, "atomic_command", item.atomic_command);
      end
    end
    write_bit_vector_value(uid, "request_info", item.request_info, configuration.request_info_width);

    foreach (item.request_data[i]) begin
      write_bit_vector_value(uid, $sformatf("request_data_%0d", i), item.request_data[i], configuration.data_width);
      if (item.byte_enable.size() > 0) begin
        write_bit_vector_value(uid, $sformatf("byte_enable_%0d", i), item.byte_enable[i], configuration.byte_enable_width);
      end
    end

    foreach (item.error[i]) begin
      if (item.response_data.size() > 0) begin
        write_bit_vector_value(uid, $sformatf("response_data_%0d", i), item.response_data[i], configuration.data_width);
      end
      write_bit_value(uid, $sformatf("error_%0d", i), item.error[i]);
      if (item.response_info.size() > 0) begin
        write_bit_vector_value(uid, $sformatf("response_info_%0d", i), item.response_info[i], configuration.response_info_width);
      end
    end

    write_logical_address(uid, item.address);

    close_pa_object(uid);
    transaction_uid.delete(id);
    predecessor_uid.delete(id);
  endfunction

  function void write_command_item(
    input int                         id,
    ref   pzvip_corebus_command_item  item,
    input int                         stall_cycles
  );
    string  uid;

    uid = create_pa_object("pzvip_corebus_command", item.begin_time, "command", transaction_uid[id], get_predecessor_uid(id));
    predecessor_uid[id].push_back(uid);

    write_string_value(uid, "command", item.command.name());
    write_bit_vector_value(uid, "bus_id", item.id, configuration.id_width);
    write_bit_vector_value(uid, "address", item.address, configuration.address_width);
    if (configuration.profile != PZVIP_COREBUS_CSR) begin
      if (is_message_command(item.command)) begin
        write_bit_vector_value(uid, "message_code", item.message_code, configuration.message_code_width);
      end
      else if (!is_atomic_command(item.command)) begin
        write_int_value(uid, "length", item.length);
        write_int_value(uid, "atomic_command", item.atomic_command);
      end
    end
    write_bit_vector_value(uid, "request_info", item.info, configuration.request_info_width);
    if ((configuration.profile == PZVIP_COREBUS_CSR) && is_write_command(item.command)) begin
      write_bit_vector_value(uid, "data", item.data, configuration.data_width);
      if (configuration.use_byte_enable) begin
        write_bit_vector_value(uid, "byte_enable", item.byte_enable, configuration.byte_enable_width);
      end
    end

    create_bus_activity(uid, "pzvip_corebus_command_bus_activity", item.begin_time, stall_cycles, -1);
    close_pa_object(uid);
  endfunction

  function void write_request_data_item(
    input int                             id,
    ref   pzvip_corebus_request_data_item item,
    input int                             stall_cycles,
    input int                             gap_cycles
  );
    if (request_data_uid.len() == 0) begin
      request_data_uid    = create_pa_object("pzvip_corebus_request_data", item.begin_time, "request_data", transaction_uid[id], get_predecessor_uid(id));
      request_data_index  = 0;
      predecessor_uid[id].push_back(request_data_uid);
    end

    write_bit_vector_value(request_data_uid, $sformatf("request_data_%0d", request_data_index), item.data, configuration.data_width);
    write_bit_vector_value(request_data_uid, $sformatf("byte_enable_%0d", request_data_index), item.byte_enable, configuration.byte_enable_width);
    request_data_index  += 1;

    create_bus_activity(request_data_uid, "pzvip_corebus_request_data_bus_activity", item.begin_time, stall_cycles, gap_cycles);
    if (item.last) begin
      close_pa_object(request_data_uid);
      request_data_uid  = "";
    end
  endfunction

  function void write_response_item(
    input int                         id,
    ref   pzvip_corebus_response_item item,
    input int                         stall_cycles,
    input int                         gap_cycles
  );
    if (response_uid.len() == 0) begin
      response_uid    = create_pa_object("pzvip_corebus_response", item.begin_time, "response", transaction_uid[id], get_predecessor_uid(id));
      response_index  = 0;
      predecessor_uid[id].push_back(response_uid);
    end

    if (response_index == 0) begin
      write_string_value(response_uid, "response_type", item.response_type.name());
      write_bit_vector_value(response_uid, "bus_id", item.id, configuration.id_width);
    end
    write_bit_value(response_uid, $sformatf("error_%0d", response_index), item.error);
    if (item.response_type == PZVIP_COREBUS_RESPONSE_WITH_DATA) begin
      write_bit_vector_value(response_uid, $sformatf("response_data_%0d", response_index), item.data, configuration.data_width);
    end
    write_bit_vector_value(response_uid, $sformatf("response_info_%0d", response_index), item.info, configuration.response_info_width);
    response_index  += 1;

    create_bus_activity(response_uid, "pzvip_corebus_response_bus_activity", item.begin_time, stall_cycles, gap_cycles);
    if ((item.last != '0) || (configuration.profile == PZVIP_COREBUS_CSR)) begin
      close_pa_object(response_uid);
      response_uid  = "";
    end
  endfunction

  protected function void write_bus_info(pzvip_corebus_configuration configuration);
    string  uid;

    uid = create_pa_object("bus_info", 0);
    write_int_value(uid, "data_width", configuration.data_width);
    if (configuration.profile == PZVIP_COREBUS_MEMORY_H) begin
      write_int_value(uid, "unit_data_width", configuration.unit_data_width);
    end
    else begin
      write_int_value(uid, "unit_data_width", configuration.data_width);
    end
    close_pa_object(uid);
  endfunction

  protected function void create_bus_activity(
    string  parent_uid,
    string  name,
    time    begin_time,
    int     stall_cycles,
    int     gap_cycles
  );
    string  uid;
    uid = create_pa_object(name, begin_time, "bus_activity", parent_uid);
    write_int_value(uid, "stall_cycles", stall_cycles);
    if (gap_cycles >= 0) begin
      write_int_value(uid, "gap_cycles", gap_cycles);
    end
    close_pa_object(uid);
  endfunction

  protected function string get_predecessor_uid(int id);
    if (predecessor_uid.exists(id)) begin
      return predecessor_uid[id][$];
    end
    else begin
      return "";
    end
  endfunction

  `uvm_object_utils(pzvip_corebus_pa_writer)
endclass
`endif
