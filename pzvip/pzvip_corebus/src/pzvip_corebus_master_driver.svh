`ifndef PZVIP_COREBUS_MASTER_DRIVER_SVH
`define PZVIP_COREBUS_MASTER_DRIVER_SVH
typedef tue_driver #(
  .CONFIGURATION  (pzvip_corebus_configuration  ),
  .STATUS         (pzvip_corebus_status         ),
  .REQ            (pzvip_corebus_master_item    )
) pzvip_corebus_master_driver_base;

typedef tue_fifo #(
  .T  (pzvip_corebus_item )
) pzvip_corebus_request_fifo;

class pzvip_corebus_master_driver extends pzvip_corebus_component_base #(
  .BASE (pzvip_corebus_master_driver_base )
);
  protected pzvip_corebus_request_fifo    command_fifo;
  protected pzvip_corebus_request_fifo    write_data_fifo;
  protected pzvip_corebus_payload_storage response_storages[int][$];
  protected int                           response_accept_delay[int][$];

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    command_fifo  = new("command_fifo", PZVIP_COREBUS_MAX_ACCEPTABLE_REQUESTS);
    if (profile != PZVIP_COREBUS_CSR) begin
      write_data_fifo = new("write_data_fifo", PZVIP_COREBUS_MAX_ACCEPTABLE_REQUESTS);
    end
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      do_reset();
      if (configuration.profile == PZVIP_COREBUS_CSR) begin
        fork
          queue_request();
          drive_command();
          drive_response_accept();
          monitor_response();
          @(negedge vif.reset_n);
        join_any
      end
      else begin
        fork
          queue_request();
          drive_command();
          drive_write_data();
          drive_response_accept();
          monitor_response();
          @(negedge vif.reset_n);
        join_any
      end
      disable fork;
    end
  endtask

  protected task end_item(pzvip_corebus_item item, time end_time = 0);
    super.end_item(item, end_time);
    if (item.use_response_port) begin
      pzvip_corebus_master_item master_item;
      void'($cast(master_item, item));
      seq_item_port.put(master_item);
    end
  endtask

  protected task do_reset();
    pzvip_corebus_item  item;

    while (!command_fifo.is_empty()) begin
      void'(command_fifo.try_get(item));
      if (!item.ended()) begin
        end_tr(item);
      end
    end

    if (write_data_fifo != null) begin
      while (!write_data_fifo.is_empty()) begin
        void'(write_data_fifo.try_get(item));
        if (!item.ended()) begin
          end_tr(item);
        end
      end
    end

    foreach (response_storages[i, j]) begin
      if (!response_storages[i][j].item.ended()) begin
        end_tr(response_storages[i][j].item);
      end
    end
    response_storages.delete();
    response_accept_delay.delete();

    if (configuration.reset_by_agent) begin
      vif.reset_master();
    end

    @(posedge vif.reset_n);
  endtask

  protected task queue_request();
    pzvip_corebus_master_item     item;
    pzvip_corebus_payload_storage storage;

    forever begin
      seq_item_port.get(item);
      accept_item(item);

      command_fifo.put(item);
      if ((profile != PZVIP_COREBUS_CSR) && item.is_request_with_data()) begin
        write_data_fifo.put(item);
      end

      if (item.is_non_posted_request()) begin
        storage = new(item);
        response_storages[item.id].push_back(storage);

        foreach (item.response_accept_delay[i]) begin
          response_accept_delay[item.id].push_back(item.response_accept_delay[i]);
        end
      end
    end
  endtask

  protected task drive_command();
    pzvip_corebus_item  item;

    forever begin
      get_next_command_item(item);

      consume_delay(item.start_delay);
      begin_command(item);

      vif.master_cb.mcmd_valid  <= '1;
      vif.master_cb.mcmd        <= item.command;
      vif.master_cb.mid         <= item.id;
      vif.master_cb.maddr       <= item.address;
      vif.master_cb.mlength     <= get_mlength(item);
      vif.master_cb.minfo       <= get_minfo(item);
      if (configuration.profile == PZVIP_COREBUS_CSR) begin
        vif.master_cb.mdata <= item.request_data[0];
        if (configuration.use_byte_enable) begin
          vif.master_cb.mdata_byteen  <= item.byte_enable[0];
        end
      end

      do begin
        @(vif.master_cb);
      end while (!vif.master_cb.scmd_accept);

      vif.master_cb.mcmd_valid  <= '0;
      end_command(item);
    end
  endtask

  protected task get_next_command_item(ref pzvip_corebus_item item);
    command_fifo.get(item);
    if (!vif.at_master_cb.triggered) begin
      @(vif.at_master_cb);
    end
  endtask

  protected function pzvip_corebus_length get_mlength(pzvip_corebus_item item);
    if (profile == PZVIP_COREBUS_CSR) begin
      return '0;
    end
    else if (item.is_message_request()) begin
      return item.message_code;
    end
    else begin
      return item.pack_length();
    end
  endfunction

  protected function pzvip_corebus_request_info get_minfo(pzvip_corebus_item item);
    if (configuration.request_info_width > 0) begin
      return item.request_info;
    end
    else begin
      return '0;
    end
  endfunction

  protected task drive_write_data();
    pzvip_corebus_item  item;
    int                 burst_length;

    forever begin
      get_next_write_data_item(item);
      burst_length  = item.get_burst_length();

      foreach (item.request_data[i]) begin
        consume_delay(item.data_delay[i]);
        if (i == 0) begin
          begin_data(item);
        end

        vif.master_cb.mdata_valid   <= '1;
        vif.master_cb.mdata         <= item.request_data[i];
        vif.master_cb.mdata_byteen  <= item.byte_enable[i];
        vif.master_cb.mdata_last    <= i == (burst_length - 1);

        do begin
          @(vif.master_cb);
        end while (!vif.master_cb.sdata_accept);

        vif.master_cb.mdata_valid <= '0;
        if (i == (burst_length - 1)) begin
          end_data(item);
        end
      end
    end
  endtask

  protected task get_next_write_data_item(ref pzvip_corebus_item item);
    write_data_fifo.get(item);
    if (!vif.at_master_cb.triggered) begin
      @(vif.at_master_cb);
    end
  endtask

  protected task drive_response_accept();
    pzvip_corebus_id  id;
    int               delay;

    forever @(vif.master_cb) begin
      if (configuration.force_response_accept_low) begin
        vif.master_cb.mresp_accept  <= '0;
      end
      else if (vif.master_cb.sresp_valid) begin
        id  = vif.master_cb.sid & id_mask;
        if (response_accept_delay.exists(id) && (response_accept_delay[id].size() > 0)) begin
          delay = response_accept_delay[id].pop_front();
        end
        else begin
          delay = 0;
        end

        if (configuration.default_response_accept) begin
          if (!vif.master_cb.mresp_accept) begin
            vif.master_cb.mresp_accept  <= '1;
            consume_delay(1);
          end
          vif.master_cb.mresp_accept  <= '0;
          consume_delay(delay);
          vif.master_cb.mresp_accept  <= '1;
        end
        else begin
          consume_delay(delay);
          vif.master_cb.mresp_accept  <= '1;
          consume_delay(1);
          vif.master_cb.mresp_accept  <= '0;
        end
      end
    end
  endtask

  protected task monitor_response();
    pzvip_corebus_payload_storage storage;
    time                          begin_time;

    begin_time  = `tue_current_time;
    forever @(vif.monitor_cb) begin
      if (vif.monitor_cb.sresp_valid) begin
        while (!vif.monitor_cb.mresp_accept) begin
          @(vif.monitor_cb);
        end
        sample_response(begin_time, storage);
      end

      begin_time  = `tue_current_time;
    end
  endtask

  protected task sample_response(
    input time                          begin_time,
    ref   pzvip_corebus_payload_storage storage
  );
    pzvip_corebus_response_item response_item;

    sample_response_item(response_item);
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
    if (response_item.last != '0) begin
      if (response_item.last[0]) begin
        end_response(storage.pack_response());
        void'(response_storages[response_item.id].pop_front());
      end
      storage = null;
    end
  endtask

  protected function void sample_response_item(ref pzvip_corebus_response_item item);
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
    if (response_storages.exists(id) && (response_storages[id].size() > 0)) begin
      return response_storages[id][0];
    end
    else begin
      return null;
    end
  endfunction


  protected task consume_delay(int delay);
    repeat (delay) begin
      @(vif.master_cb);
    end
  endtask

  `tue_component_default_constructor(pzvip_corebus_master_driver)
  `uvm_component_utils(pzvip_corebus_master_driver)
endclass
`endif
