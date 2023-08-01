`ifndef PZVIP_COREBUS_PAYLOAD_STORAGE_SVH
`define PZVIP_COREBUS_PAYLOAD_STORAGE_SVH
class pzvip_corebus_payload_storage;
  pzvip_corebus_item              item;
  pzvip_corebus_request_data_item request_data_items[$];
  pzvip_corebus_response_item     response_items[$];

  function new(pzvip_corebus_item item);
    this.item = item;
  endfunction

  function void put_request_data_item(ref pzvip_corebus_request_data_item item);
    request_data_items.push_back(item);
  endfunction

  function void put_response_item(ref pzvip_corebus_response_item item);
    response_items.push_back(item);
  endfunction

  function bit is_empty();
    return (request_data_items.size() == 0) && (response_items.size() == 0);
  endfunction

  function bit is_filled();
    if (is_empty()) begin
      return 0;
    end
    else if (request_data_items.size() > 0) begin
      return request_data_items.size() == item.get_burst_length();
    end
    else if (item.needs_response_data()) begin
      return response_items.size() == item.get_burst_length();
    end
    else begin
      return response_items.size() == 1;
    end
  endfunction

  function pzvip_corebus_item pack_request();
    item.put_request_data(request_data_items);
    return item;
  endfunction

  function pzvip_corebus_item pack_response();
    item.put_response(response_items);
    return item;
  endfunction
endclass
`endif
