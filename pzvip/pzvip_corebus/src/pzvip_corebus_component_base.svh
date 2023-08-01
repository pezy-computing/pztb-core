`ifndef PZVIP_COREBUS_COMPONENT_BASE_SVH
`define PZVIP_COREBUS_COMPONENT_BASE_SVH
class pzvip_corebus_component_base #(
  type  BASE  = uvm_component
) extends BASE;
  protected pzvip_corebus_vif           vif;
  protected pzvip_corebus_profile       profile;
  protected int                         data_size;
  protected int                         address_shift;
  protected pzvip_corebus_id            id_mask;
  protected pzvip_corebus_address       address_mask;
  protected pzvip_corebus_length        length_mask;
  protected pzvip_corebus_request_info  request_info_mask;
  protected pzvip_corebus_data          data_mask;
  protected pzvip_corebus_data          unit_data_mask;
  protected pzvip_corebus_byte_enable   byte_enable_mask;
  protected pzvip_corebus_unit_enable   unit_enable_mask;
  protected pzvip_corebus_response_info response_info_mask;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    vif     = configuration.vif;
    profile = configuration.profile;
    if (configuration.mask_unused_bits) begin
      id_mask               = `pzvip_corebus_get_mask(configuration.id_width);
      address_mask          = `pzvip_corebus_get_mask(configuration.address_width);
      length_mask           = `pzvip_corebus_get_mask(configuration.length_width);
      request_info_mask     = `pzvip_corebus_get_mask(configuration.request_info_width);
      data_mask             = `pzvip_corebus_get_mask(configuration.data_width);
      byte_enable_mask      = `pzvip_corebus_get_mask(configuration.byte_enable_width);
      unit_enable_mask      = `pzvip_corebus_get_mask(configuration.unit_enable_width);
      response_info_mask    = `pzvip_corebus_get_mask(configuration.response_info_width);
    end
    else begin
      id_mask               = (configuration.id_width            > 0) ? '1 : '0;
      address_mask          = (configuration.address_width       > 0) ? '1 : '0;
      length_mask           = (configuration.length_width        > 0) ? '1 : '0;
      request_info_mask     = (configuration.request_info_width  > 0) ? '1 : '0;
      data_mask             = (configuration.data_width          > 0) ? '1 : '0;
      byte_enable_mask      = (configuration.byte_enable_width   > 0) ? '1 : '0;
      unit_enable_mask      = (configuration.unit_enable_width   > 0) ? '1 : '0;
      response_info_mask    = (configuration.response_info_width > 0) ? '1 : '0;
    end
  endfunction

  protected virtual task begin_command(pzvip_corebus_item item, time begin_time = 0);
    item.begin_command(begin_time);
    if (!item.began()) begin
      begin_request(item, begin_time);
    end
  endtask

  protected virtual task end_command(pzvip_corebus_item item, time end_time = 0);
    item.end_command(end_time);
    if (item.request_ended()) begin
      end_request(item, end_time);
    end
  endtask

  protected virtual task begin_data(pzvip_corebus_item item, time begin_time = 0);
    item.begin_data(begin_time);
    if (!item.began()) begin
      begin_request(item, begin_time);
    end
  endtask

  protected virtual task end_data(pzvip_corebus_item item, time end_time = 0);
    item.end_data(end_time);
    if (item.request_ended()) begin
      end_request(item, end_time);
    end
  endtask

  protected virtual task begin_request(pzvip_corebus_item item, time begin_time = 0);
    begin_item(item, begin_time);
  endtask

  protected virtual task end_request(pzvip_corebus_item item, time end_time = 0);
    if (item.is_posted_request()) begin
      end_item(item, end_time);
    end
  endtask

  protected virtual task begin_response(pzvip_corebus_item item, time begin_time = 0);
    if (item.is_non_posted_request()) begin
      item.begin_response(begin_time);
    end
  endtask

  protected virtual task end_response(pzvip_corebus_item item, time end_time = 0);
    if (item.is_non_posted_request()) begin
      item.end_response(end_time);
      end_item(item, end_time);
    end
  endtask

  protected virtual task accept_item(pzvip_corebus_item item, time accept_time = 0);
    if (accept_time == 0) begin
      accept_time = `tue_current_time;
    end
    accept_tr(.tr(item), .accept_time(accept_time));
  endtask

  protected virtual task begin_item(pzvip_corebus_item item, time begin_time = 0);
    if (begin_time == 0) begin
      begin_time  = `tue_current_time;
    end
    void'(begin_tr(.tr(item), .begin_time(begin_time)));
  endtask

  protected virtual task end_item(pzvip_corebus_item item, time end_time = 0);
    if (end_time == 0) begin
      end_time  = `tue_current_time;
    end
    end_tr(.tr(item), .end_time(end_time));
  endtask

  `tue_component_default_constructor(pzvip_corebus_component_base)
endclass
`endif
