`ifndef PZVIP_TILELINK_RECEIVER_DRIVER_BASE_SVH
`define PZVIP_TILELINK_RECEIVER_DRIVER_BASE_SVH
virtual class pzvip_tilelink_receiver_driver_base #(
  type  VIF = pzvip_tilelink_a_vif
) extends tue_driver #(
  .CONFIGURATION  (pzvip_tilelink_configuration ),
  .STATUS         (pzvip_tilelink_status        ),
  .REQ            (pzvip_tilelink_message_item  )
);
  protected VIF vif;
  protected bit default_ready;
  protected int ready_delay;
  protected int ready_delay_queue[$];

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    vif           = get_vif();
    default_ready = get_default_ready();
  endfunction

  task run_phase(uvm_phase phase);
    forever @(vif.receiver_cb, posedge vif.reset) begin
      if (vif.reset) begin
        do_reset();
      end
      else begin
        if (
          vif.monitor_cb.valid && (ready_delay < 0) && (ready_delay_queue.size() == 0)
        ) begin
          uvm_wait_for_nba_region();
          get_ready_delay();
        end

        drive_ready();
      end
    end
  endtask

  protected pure virtual function VIF get_vif();
  protected pure virtual function int get_default_ready();

  protected virtual task do_reset();
    ready_delay = -1;
    ready_delay_queue.delete();
    if (configuration.reset_by_agent) begin
      vif.reset_receiver();
    end
  endtask

  protected virtual task get_ready_delay();
    pzvip_tilelink_message_item items[$];

    while (seq_item_port.has_do_available()) begin
      pzvip_tilelink_message_item item;
      seq_item_port.get_next_item(item);
      items.push_back(item);
      seq_item_port.item_done();
    end

    if ((items.size() > 0) && (items[$].get_begin_time() == $time)) begin
      foreach (items[$].ready_delay[i]) begin
        ready_delay_queue.push_back(items[$].ready_delay[i]);
      end
    end
    else begin
      repeat (number_of_beat()) begin
        ready_delay_queue.push_back(0);
      end
    end
  endtask

  protected function int number_of_beat();
    if (has_data()) begin
      int size        = 2**get_size();
      int byte_width  = configuration.data_width / 8;
      return (size +  byte_width - 1) / byte_width;
    end
    else begin
      return 1;
    end
  endfunction

  protected pure virtual function bit has_data();
  protected pure virtual function int get_size();

  protected virtual task drive_ready();
    bit ready;

    if ((ready_delay < 0) && (ready_delay_queue.size() > 0)) begin
      if (vif.monitor_cb.valid && (vif.monitor_cb.ready == default_ready)) begin
        ready_delay = ready_delay_queue.pop_front();
      end
    end

    vif.receiver_cb.ready <= (
      ((default_ready == 1) && (ready_delay <= 0)) ||
      ((default_ready == 0) && (ready_delay == 0))
    ) ? '1 : '0;

    if (ready_delay >= 0) begin
      --ready_delay;
    end
  endtask

  `tue_component_default_constructor(pzvip_tilelink_receiver_driver_base)
endclass
`endif
