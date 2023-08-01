class pzvip_stream_driver extends tue_driver #(
  .CONFIGURATION  (pzvip_stream_configuration ),
  .STATUS         (pzvip_stream_status        ),
  .REQ            (pzvip_stream_item          )
);
  protected pzvip_stream_vif  vif;
  protected pzvip_stream_item current_item;
  protected int               index;
  protected int               delay;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    vif = configuration.vif;
  endfunction

  task run_phase(uvm_phase phase);
    forever @(vif.master_cb, negedge vif.i_rst_n) begin
      if (!vif.i_rst_n) begin
        do_reset();
      end
      else begin
        if ((current_item != null) && vif.master_cb.ack) begin
          finish_data();
        end

        if (current_item == null) begin
          get_next_item();
        end

        do_drive();
      end
    end
  endtask

  protected task do_reset();
    if (configuration.reset_by_agent) begin
      vif.reset_master();
    end

    if (current_item != null) begin
      end_tr(current_item);
    end
    current_item  = null;
  endtask

  protected task finish_data();
    if (index == (current_item.length - 1)) begin
      end_tr(current_item);
      seq_item_port.item_done();
      current_item  = null;
    end
    else begin
      ++index;
      delay = -1;
    end
  endtask

  protected task get_next_item();
    uvm_wait_for_nba_region();
    if (seq_item_port.has_do_available()) begin
      seq_item_port.get_next_item(current_item);
      void'(begin_tr(current_item));
      index = 0;
      delay = -1;
    end
  endtask

  protected task do_drive();
    bit valid;

    valid = 0;
    if (current_item != null) begin
      if (delay < 0) begin
        delay = current_item.delay[index];
      end
      if (delay > 0) begin
        --delay;
      end
      valid = (delay == 0);
    end

    if (valid) begin
      vif.master_cb.valid       <= 1;
      vif.master_cb.data        <= current_item.data[index];
      vif.master_cb.byte_enable <= current_item.byte_enable[index];
      vif.master_cb.last        <= (index == (current_item.length - 1));
    end
    else begin
      vif.master_cb.valid       <= 0;
      vif.master_cb.data        <= 'x;
      vif.master_cb.byte_enable <= 'x;
      vif.master_cb.last        <= 'x;
    end
  endtask

  `tue_component_default_constructor(pzvip_stream_driver)
  `uvm_component_utils(pzvip_stream_driver)
endclass
