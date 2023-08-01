`ifndef PZVIP_TILELINK_MONITOR_BASE_SVH
`define PZVIP_TILELINK_MONITOR_BASE_SVH
virtual class pzvip_tilelink_monitor_base #(
  type  VIF       = pzvip_tilelink_a_vif,
  type  ITEM      = pzvip_tilelink_message_item,
  bit   IS_SENDER = 1
) extends tue_param_monitor #(
  .CONFIGURATION  (pzvip_tilelink_configuration ),
  .STATUS         (pzvip_tilelink_status        ),
  .ITEM           (ITEM                         ),
  .ITEM_HANDLE    (pzvip_tilelink_message_item  )
);
  uvm_analysis_port #(pzvip_tilelink_message_item)  request_port;

  protected VIF                         vif;
  protected pzvip_tilelink_message_item current_item;
  protected int                         current_beat;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    vif = get_vif();
    if (!IS_SENDER) begin
      request_port  = new("request_port", this);
    end
  endfunction

  task run_phase(uvm_phase phase);
    forever @(vif.monitor_cb) begin
      if (vif.reset) begin
        do_reset();
      end
      else begin
        if (vif.monitor_cb.valid && (current_item == null)) begin
          current_item  = create_item();
          current_beat  = 0;
          sample_request();
          if (request_port != null) begin
            request_port.write(current_item);
          end
        end
        if (vif.monitor_cb.valid && vif.monitor_cb.ready) begin
          if (current_item.has_data()) begin
            sample_data();
            ++current_beat;
          end
          if (is_last_beat()) begin
            write_item(current_item);
            current_item  = null;
          end
        end
      end
    end
  endtask

  protected virtual function void do_reset();
    if (current_item != null) begin
      end_tr(current_item);
    end
    current_item  = null;
  endfunction

  protected virtual function bit is_last_beat();
    if (current_item.has_data()) begin
      return (current_beat == current_item.number_of_beats()) ? 1 : 0;
    end
    else begin
      return 1;
    end
  endfunction

  protected pure virtual function VIF get_vif();
  protected pure virtual function void sample_request();
  protected pure virtual function void sample_data();

  `tue_component_default_constructor(pzvip_tilelink_monitor_base)
endclass
`endif
