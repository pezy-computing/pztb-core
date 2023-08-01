class pzvip_stream_monitor extends tue_param_monitor #(
  .CONFIGURATION  (pzvip_stream_configuration ),
  .STATUS         (pzvip_stream_status        ),
  .ITEM           (pzvip_stream_item          )
);
  uvm_analysis_port #(pzvip_stream_unit_item) unit_item_port;

  protected pzvip_stream_vif        vif;
  protected pzvip_stream_item       current_item;
  protected pzvip_stream_unit_item  unit_buffer[$];

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    vif             = configuration.vif;
    unit_item_port  = new("unit_item_port", this);
  endfunction

  task run_phase(uvm_phase phase);
    forever @(vif.monitor_cb) begin
      if (!vif.i_rst_n) begin
        do_reset();
      end
      else if (vif.monitor_cb.valid) begin
        do_sample();
      end
    end
  endtask

  protected task do_reset();
    if (current_item != null) begin
      end_tr(current_item);
    end
    current_item  = null;
    unit_buffer.delete();
  endtask

  protected task do_sample();
    if (current_item == null) begin
      current_item  = create_item("item");
    end

    if (vif.monitor_cb.ready) begin
      pzvip_stream_unit_item  unit_item;

      unit_item             = pzvip_stream_unit_item::type_id::create("unit_item");
      unit_item.data        = vif.monitor_cb.data;
      unit_item.byte_enable = vif.monitor_cb.byte_enable;
      unit_item.last        = vif.monitor_cb.last;
      unit_buffer.push_back(unit_item);
      unit_item_port.write(unit_item);

      if (unit_item.last) begin
        current_item.put(unit_buffer);
        write_item(current_item);
        current_item  = null;
        unit_buffer.delete();
      end
    end
  endtask

  `tue_component_default_constructor(pzvip_stream_monitor)
  `uvm_component_utils(pzvip_stream_monitor)
endclass
