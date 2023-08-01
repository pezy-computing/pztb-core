`ifndef PZVIP_TILELINK_SENDER_DRIVER_BASE_SVH
`define PZVIP_TILELINK_SENDER_DRIVER_BASE_SVH
virtual class pzvip_tilelink_sender_driver_base #(
  type  VIF = pzvip_tilelink_a_vif
) extends tue_driver #(
  .CONFIGURATION  (pzvip_tilelink_configuration ),
  .STATUS         (pzvip_tilelink_status        ),
  .REQ            (pzvip_tilelink_message_item  )
);
  typedef struct {
    pzvip_tilelink_message_item response;
    int                         delay;
  } delay_buffer_item;

  protected VIF                         vif;
  protected delay_buffer_item           delay_buffer[int][$];
  protected pzvip_tilelink_message_item request_queue[$];
  protected pzvip_tilelink_message_item response_queue[$];
  protected pzvip_tilelink_message_item current_message;
  protected int                         current_beat;
  protected int                         gap_delay;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    vif = get_vif();
  endfunction

  task run_phase(uvm_phase phase);
    forever @(vif.sender_cb, posedge vif.reset) begin
      if (vif.reset) begin
        do_reset();
      end
      else begin
        if (vif.monitor_cb.valid && vif.monitor_cb.ready) begin
          finish_beat();
        end

        uvm_wait_for_nba_region();
        update_delay_buffer();

        if (
          (current_message == null) &&
          (gap_delay       == 0   ) &&
          ((request_queue.size() > 0) || (response_queue.size() > 0))
        ) begin
          get_next_message();
        end

        if ((current_message != null) && (gap_delay == 0)) begin
          vif.sender_cb.valid <= '1;
          drive_message();
        end
        else begin
          vif.sender_cb.valid <= '0;
          drive_idle();
        end

        if (gap_delay > 0) begin
          --gap_delay;
        end
      end
    end
  endtask

  protected pure virtual function VIF get_vif();

  protected virtual task do_reset();
    if (current_message != null) begin
      end_tr(current_message);
    end
    foreach (request_queue[i]) begin
      end_tr(request_queue[i]);
    end
    foreach (response_queue[i]) begin
      end_tr(response_queue[i]);
    end
    foreach (delay_buffer[i, j]) begin
      end_tr(delay_buffer[i][j].response);
    end

    current_message   = null;
    current_beat      = 0;
    gap_delay         = 0;
    request_queue.delete();
    response_queue.delete();
    delay_buffer.delete();

    if (configuration.reset_by_agent) begin
      vif.reset_sender();
    end
  endtask

  protected virtual task update_delay_buffer();
    consume_response_start_delay();
    get_message_from_port();
    push_response_to_qeueu();
  endtask

  protected virtual function void consume_response_start_delay();
    foreach (delay_buffer[i, j]) begin
      if (!(
        delay_buffer[i][j].response.enable_early_response ||
        delay_buffer[i][j].response.related_request.end_event.is_on()
      )) begin
        continue;
      end
      if (delay_buffer[i][j].delay <= 0) begin
        continue;
      end
      --delay_buffer[i][j].delay;
    end
  endfunction

  protected virtual task get_message_from_port();
    if (seq_item_port.has_do_available()) begin
      pzvip_tilelink_message_item message;

      seq_item_port.get_next_item(message);
      accept_tr(message);
      seq_item_port.item_done();

      if (message.is_request()) begin
        request_queue.push_back(message);
      end
      else begin
        delay_buffer_item buffer_item;
        int               id;
        buffer_item.response  = message;
        buffer_item.delay     = message.response_start_delay;
        id                    = get_id(message);
        delay_buffer[id].push_back(buffer_item);
      end
    end
  endtask

  protected virtual function void push_response_to_qeueu();
    foreach (delay_buffer[i]) begin
      if (delay_buffer[i].size == 0) begin
        continue;
      end
      if (delay_buffer[i][0].delay > 0) begin
        continue;
      end
      if (!(
        delay_buffer[i][0].response.enable_early_response ||
        delay_buffer[i][0].response.related_request.end_event.is_on()
      )) begin
        continue;
      end

      response_queue.push_back(delay_buffer[i][0].response);
      void'(delay_buffer[i].pop_front());
    end
  endfunction

  protected virtual function int get_id(pzvip_tilelink_message_item response);
    return 0;
  endfunction

  protected virtual task get_next_message();
    if ((request_queue.size() > 0) && (response_queue.size() > 0)) begin
      randcase
        1:  current_message = request_queue.pop_front();
        1:  current_message = response_queue.pop_front();
      endcase
    end
    else if (request_queue.size() > 0) begin
      current_message = request_queue.pop_front();
    end
    else begin
      current_message = response_queue.pop_front();
    end
    current_beat  = 0;
    gap_delay     = 0;
    void'(begin_tr(current_message));
  endtask

  protected pure virtual task drive_message();

  protected virtual task drive_idle();
  endtask

  protected virtual task finish_beat();
    gap_delay     = current_message.gap_delay[current_beat];
    current_beat  = current_beat + 1;
    if (!(
      current_message.has_data() &&
      (current_beat < current_message.number_of_beats())
    )) begin
      end_tr(current_message);
      current_message = null;
    end
  endtask

  `tue_component_default_constructor(pzvip_tilelink_sender_driver_base)
endclass
`endif
