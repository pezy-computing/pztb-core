`ifndef PZVIP_TILELINK_SLAVE_RESPOND_GET_PUT_SEQUENCE_SVH
`define PZVIP_TILELINK_SLAVE_RESPOND_GET_PUT_SEQUENCE_SVH
class pzvip_tilelink_slave_respond_get_put_sequence extends pzvip_tilelink_slave_sequence;
  task body();
    forever begin
      pzvip_tilelink_receiver_message_item  request;
      wait_for_request(request);
      fork
        send_response(request);
      join_none
    end
  endtask

  local task wait_for_request(ref pzvip_tilelink_receiver_message_item request);
    pzvip_tilelink_receiver_message_item  message;
    get_put_get_message(message);
    $cast(request, message.clone());
    receive_request(request);
  endtask

  local task receive_request(pzvip_tilelink_receiver_message_item request);
    request.set_sequencer(a_sequencer);
    `uvm_rand_send(request)
  endtask

  local task send_response(pzvip_tilelink_receiver_message_item request);
    pzvip_tilelink_sender_message_item  response;
    pzvip_tilelink_data                 read_data[$];
    bit                                 read_data_existence[$];

    if (request.opcode == PZVIP_TILELINK_GET) begin
      int beats = request.number_of_beats();
      for (int i = 0;i < beats;++i) begin
        if (exists_read_data(request, i)) begin
          read_data_existence.push_back(1);
          read_data.push_back(get_read_data(request, i));
        end
        else begin
          read_data_existence.push_back(0);
          read_data.push_back(0);
        end
      end
    end

    `uvm_create_on(response, d_sequencer);
    response.related_request  = request;
    `uvm_rand_send_with(response, {
      if (response.opcode == PZVIP_TILELINK_ACCESS_ACK_DATA) {
        foreach (data[i]) {
          if (read_data_existence[i]) {
            data[i] == read_data[i];
          }
        }
      }
    })
  endtask

  protected virtual function bit exists_read_data(
    pzvip_tilelink_receiver_message_item  request,
    int                                   beat
  );
    return status.memory.exists(request.address, beat, request.size);
  endfunction

  protected virtual function pzvip_tilelink_data get_read_data(
    pzvip_tilelink_receiver_message_item  request,
    int                                   beat
  );
    return status.memory.get(request.address, beat, request.size);
  endfunction

  `tue_object_default_constructor(pzvip_tilelink_slave_respond_get_put_sequence)
  `uvm_object_utils(pzvip_tilelink_slave_respond_get_put_sequence)
endclass
`endif
