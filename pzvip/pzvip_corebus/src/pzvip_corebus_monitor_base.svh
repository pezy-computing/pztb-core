`ifndef PZVIP_COREBUS_MONITOR_BASE_SVH
`define PZVIP_COREBUS_MONITOR_BASE_SVH
class pzvip_corebus_monitor_base #(
  type  BASE  = uvm_monitor,
  type  ITEM  = uvm_sequence_item
) extends pzvip_corebus_component_base #(BASE);
  uvm_analysis_port #(pzvip_corebus_item) command_item_port;
  uvm_analysis_port #(pzvip_corebus_item) request_item_port;
  uvm_analysis_port #(pzvip_corebus_item) response_item_port;

  protected pzvip_corebus_payload_storage write_data_storages[2][$];
  protected pzvip_corebus_payload_storage response_storages[int][$];
  protected pzvip_corebus_pa_writer       pa_writer;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    command_item_port   = new("command_item_port" , this);
    request_item_port   = new("request_item_port" , this);
    response_item_port  = new("response_item_port", this);
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      do_reset();
      if (configuration.profile == PZVIP_COREBUS_CSR) begin
        fork
          monitor_command();
          monitor_response();
          @(negedge vif.monitor_cb.reset_n);
        join_any
      end
      else begin
        fork
          monitor_command();
          monitor_request_data();
          monitor_response();
          @(negedge vif.monitor_cb.reset_n);
        join_any
      end
      disable fork;
    end
  endtask

  function void connect_pa_writer(pzvip_corebus_pa_writer pa_writer);
    this.pa_writer  = pa_writer;
  endfunction

  protected virtual task begin_request(pzvip_corebus_item item, time begin_time = 0);
    super.begin_request(item, begin_time);
    if (pa_writer != null) begin
      pa_writer.begin_transaction(item);
    end
  endtask

  protected virtual task end_request(pzvip_corebus_item item, time end_time = 0);
    super.end_request(item, end_time);
    request_item_port.write(item);
  endtask

  protected virtual task end_command(pzvip_corebus_item item, time end_time = 0);
    super.end_command(item, end_time);
    command_item_port.write(item);
  endtask

  protected virtual task end_response(pzvip_corebus_item item, time end_time = 0);
    super.end_response(item, end_time);
    response_item_port.write(item);
  endtask

  protected virtual task end_item(pzvip_corebus_item item, time end_time = 0);
    super.end_item(item, end_time);
    item_port.write(item);
    if (pa_writer != null) begin
      pa_writer.write_transaction(item);
    end
  endtask

  protected task do_reset();
    if (pa_writer != null) begin
      pa_writer.reset();
    end

    foreach (write_data_storages[i, j]) begin
      if (!write_data_storages[i][j].item.ended()) begin
        end_tr(write_data_storages[i][j].item);
      end
    end
    write_data_storages[0].delete();
    write_data_storages[1].delete();

    foreach (response_storages[i, j]) begin
      if (!response_storages[i][j].item.ended()) begin
        end_tr(response_storages[i][j].item);
      end
    end
    response_storages.delete();

    @(posedge vif.monitor_cb.reset_n);
  endtask

  protected task monitor_command();
    pzvip_corebus_command_item  command_item;
    pzvip_corebus_item          request_item;
    time                        begin_time;
    int                         stall_cycles;

    begin_time  = `tue_current_time;
    forever @(vif.monitor_cb) begin
      if (vif.monitor_cb.mcmd_valid) begin
        sample_command(begin_time, command_item, request_item);

        stall_cycles  = 0;
        while (!vif.monitor_cb.scmd_accept) begin
          @(vif.monitor_cb);
          stall_cycles  += 1;
        end
        if (pa_writer != null) begin
          pa_writer.write_command_item(request_item.get_inst_id(), command_item, stall_cycles);
        end

        end_command(request_item);
      end

      begin_time  = `tue_current_time;
    end
  endtask

  protected task sample_command(
    input time                        begin_time,
    ref   pzvip_corebus_command_item  command_item,
    ref   pzvip_corebus_item          request_item
  );
    sample_command_item(begin_time, command_item);
    get_request_item_by_command_item(request_item, command_item);
    request_item.put_command(command_item);
    begin_command(request_item, begin_time);
  endtask

  protected function void sample_command_item(
    input time                        begin_time,
    ref   pzvip_corebus_command_item  item
  );
    item.begin_time   = begin_time;
    item.command      = vif.monitor_cb.mcmd;
    item.id           = vif.monitor_cb.mid & id_mask;
    item.address      = vif.monitor_cb.maddr & address_mask;
    if (profile == PZVIP_COREBUS_CSR) begin
      item.length       = 1;
      item.message_code = '0;
      if (is_write_command(item.command)) begin
        item.data = vif.monitor_cb.mdata & data_mask;
        if (configuration.use_byte_enable) begin
          item.byte_enable  = vif.monitor_cb.mdata_byteen & byte_enable_mask;
        end
      end
    end
    else if (is_message_command(item.command)) begin
      item.length       = 0;
      item.message_code = vif.monitor_cb.mlength;
    end
    else begin
      item.length = vif.monitor_cb.mlength & length_mask;
      if (item.length == 0) begin
        item.length = configuration.max_length;
      end
      item.message_code = '0;
    end
    if (configuration.request_info_width > 0) begin
      item.info = vif.monitor_cb.minfo & request_info_mask;
    end
  endfunction

  protected function void get_request_item_by_command_item(
    ref pzvip_corebus_item          request_item,
    ref pzvip_corebus_command_item  command_item
  );
    pzvip_corebus_item            item;
    pzvip_corebus_payload_storage storage;

    if ((profile == PZVIP_COREBUS_CSR) || is_no_data_command(command_item.command)) begin
      item  = create_monitor_item();
    end
    else begin
      if (write_data_storages[1].size() == 0) begin
        item    = create_monitor_item();
        storage = new(item);
        write_data_storages[0].push_back(storage);
      end
      else begin
        item  = write_data_storages[1][0].item;
        void'(write_data_storages[1].pop_front());
      end
    end

    if (is_non_posted_command(command_item.command)) begin
      storage = new(item);
      response_storages[command_item.id].push_back(storage);
    end

    request_item  = item;
  endfunction

  protected task monitor_request_data();
    pzvip_corebus_payload_storage storage;
    time                          begin_time;
    int                           stall_cycles;
    int                           gap_cycles;

    begin_time    = `tue_current_time;
    stall_cycles  = 0;
    gap_cycles    = 0;
    forever @(vif.monitor_cb) begin
      if (vif.monitor_cb.mdata_valid) begin
        sample_request_data(begin_time, storage);

        stall_cycles  = 0;
        while (!vif.monitor_cb.sdata_accept) begin
          @(vif.monitor_cb);
          stall_cycles  += 1;
        end
        if (pa_writer != null) begin
          pa_writer.write_request_data_item(
            storage.item.get_inst_id(),
            storage.request_data_items[$],
            stall_cycles, gap_cycles
          );
        end

        if (storage.request_data_items[$].last) begin
          end_data(storage.pack_request());
          storage = null;
        end
        gap_cycles  = 0;
      end
      else if (storage != null) begin
        gap_cycles  += 1;
      end

      begin_time  = `tue_current_time;
    end
  endtask

  protected task sample_request_data(
    input time                          begin_time,
    ref   pzvip_corebus_payload_storage storage
  );
    pzvip_corebus_request_data_item request_data_item;
    if (storage == null) begin
      get_write_data_storage(storage);
      begin_data(storage.item, begin_time);
    end
    sample_request_data_item(begin_time, request_data_item);
    storage.put_request_data_item(request_data_item);
  endtask

  protected function pzvip_corebus_payload_storage get_write_data_storage(ref pzvip_corebus_payload_storage storage);
    if (write_data_storages[0].size() > 0) begin
      storage = write_data_storages[0].pop_front();
    end
    else begin
      pzvip_corebus_item  item;
      item    = create_monitor_item();
      storage = new(item);
      write_data_storages[1].push_back(storage);
    end
  endfunction

  protected function void sample_request_data_item(
    input time                            begin_time,
    ref   pzvip_corebus_request_data_item item
  );
    item.begin_time   = begin_time;
    item.data         = vif.monitor_cb.mdata & data_mask;
    item.byte_enable  = vif.monitor_cb.mdata_byteen & byte_enable_mask;
    item.last         = vif.monitor_cb.mdata_last;
  endfunction

  protected task monitor_response();
    pzvip_corebus_payload_storage storage;
    pzvip_corebus_id              id;
    pzvip_corebus_response_last   last;
    time                          begin_time;
    int                           stall_cycles;
    int                           gap_cycles;

    begin_time    = `tue_current_time;
    stall_cycles  = 0;
    gap_cycles    = 0;
    forever @(vif.monitor_cb) begin
      if (vif.monitor_cb.sresp_valid) begin
        sample_response(begin_time, storage);
        if (storage == null) begin
          begin_time =  `tue_current_time;
          continue;
        end

        stall_cycles  = 0;
        while (!vif.monitor_cb.mresp_accept) begin
          @(vif.monitor_cb);
          stall_cycles  += 1;
        end
        if (pa_writer != null) begin
          pa_writer.write_response_item(
            storage.item.get_inst_id(),
            storage.response_items[$],
            stall_cycles, gap_cycles
          );
        end

        id    = storage.response_items[$].id;
        last  = storage.response_items[$].last;
        if (last != '0) begin
          if (last[0]) begin
            end_response(storage.pack_response());
            void'(response_storages[id].pop_front());
          end
          storage = null;
        end

        gap_cycles  = 0;
      end
      else if (storage != null) begin
        gap_cycles  += 1;
      end

      begin_time  = `tue_current_time;
    end
  endtask

  protected task sample_response(
    input time                          begin_time,
    ref   pzvip_corebus_payload_storage storage
  );
    pzvip_corebus_response_item response_item;

    sample_response_item(begin_time, response_item);
    if (storage == null) begin
      storage = get_response_storage(response_item.id);
      if (storage == null) begin
        `uvm_warning("UNEXPECTED_RESPONSE", $sformatf("unexpected response: id %h", response_item.id))
        return;
      end
      else if (storage.is_empty()) begin
        begin_response(storage.item, begin_time);
      end
    end

    storage.put_response_item(response_item);
  endtask

  protected function void sample_response_item(
    input time                        begin_time,
    ref   pzvip_corebus_response_item item
  );
    item.begin_time     = begin_time;
    item.response_type  = vif.monitor_cb.sresp;
    item.id             = vif.monitor_cb.sid & id_mask;
    item.error          = vif.monitor_cb.serror;
    if (item.response_type == PZVIP_COREBUS_RESPONSE_WITH_DATA) begin
      item.data = vif.monitor_cb.sdata & data_mask;
    end
    if (configuration.response_info_width > 0) begin
      item.info = vif.monitor_cb.sinfo & response_info_mask;
    end
    case (profile)
      PZVIP_COREBUS_CSR:      item.last = 2'b01;
      PZVIP_COREBUS_MEMORY_L: item.last = 2'(vif.monitor_cb.sresp_last[0]);
      PZVIP_COREBUS_MEMORY_H: item.last = vif.monitor_cb.sresp_last;
    endcase
  endfunction

  protected function pzvip_corebus_payload_storage get_response_storage(pzvip_corebus_id id);
    pzvip_corebus_payload_storage storage;

    if (response_storages.exists(id)) begin
      while (response_storages[id].size() > 0) begin
        if (!is_response_dropped(response_storages[id][0].item)) begin
          storage = response_storages[id][0];
          break;
        end
        else begin
          void'(response_storages[id].pop_front());
        end
      end
    end

    return storage;
  endfunction

  protected function bit is_response_dropped(pzvip_corebus_item item);
    return item.drop_response || configuration.drop_response;
  endfunction

  protected function pzvip_corebus_item create_monitor_item();
    pzvip_corebus_item  item;
    item  = ITEM::type_id::create("monitor_item");
    item.set_context(configuration, status);
    return item;
  endfunction

  `tue_component_default_constructor(pzvip_corebus_monitor_base)
endclass
`endif
