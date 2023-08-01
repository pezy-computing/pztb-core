`ifndef PZVIP_TILELINK_MESSAGE_WAITER_SVH
`define PZVIP_TILELINK_MESSAGE_WAITER_SVH
class pzvip_tilelink_message_waiter extends tue_subscriber #(
  .CONFIGURATION  (pzvip_tilelink_configuration ),
  .STATUS         (pzvip_tilelink_status        ),
  .T              (pzvip_tilelink_message_item  )
);
  class message_waiter extends uvm_event;
    pzvip_tilelink_opcode target_opcode[$];
    int                   target_id;

    function new(
      ref   pzvip_tilelink_opcode target_opcode[$],
      input int                   target_id
    );
      super.new();
      foreach (target_opcode[i]) begin
        this.target_opcode.push_back(target_opcode[i]);
      end
      this.target_id  = target_id;
    endfunction

    function bit is_target_message(
      pzvip_tilelink_opcode opcode,
      int                   id
    );
      if (!(opcode inside {target_opcode})) begin
        return 0;
      end
      else if ((target_id >= 0) && (id != target_id)) begin
        return 0;
      end
      else begin
        return 1;
      end
    endfunction
  endclass

  protected message_waiter  waiters[$];
  protected message_waiter  source_waiters[$];
  protected message_waiter  sink_waiters[$];

  function void write(pzvip_tilelink_message_item t);
    int matched_index[$];

    matched_index = waiters.find_index() with (
      item.is_target_message(t.opcode, -1)
    );
    while (matched_index.size() > 0) begin
      int i = matched_index.pop_front();
      waiters[i].trigger(t);
      waiters.delete(i);
    end

    matched_index = source_waiters.find_index() with (
      item.is_target_message(t.opcode, t.source)
    );
    while (matched_index.size() > 0) begin
      int i = matched_index.pop_front();
      source_waiters[i].trigger(t);
      source_waiters.delete(i);
    end

    matched_index = sink_waiters.find_index() with (
      item.is_target_message(t.opcode, t.sink)
    );
    while (matched_index.size() > 0) begin
      int i = matched_index.pop_front();
      sink_waiters[i].trigger(t);
      sink_waiters.delete(i);
    end
  endfunction

  task get_message(
    input pzvip_tilelink_opcode       target_opcode[$],
    ref   pzvip_tilelink_message_item message
  );
    message_waiter  waiter;
    uvm_object      trigger_data;

    waiter  = new(target_opcode, -1);
    waiters.push_back(waiter);

    waiter.wait_on();
    trigger_data  = waiter.get_trigger_data();
    $cast(message, trigger_data);
  endtask

  task get_message_by_source(
    input pzvip_tilelink_opcode       target_opcode[$],
    input int                         source,
    ref   pzvip_tilelink_message_item message
  );
    message_waiter  waiter;
    uvm_object      trigger_data;

    waiter  = new(target_opcode, source);
    source_waiters.push_back(waiter);

    waiter.wait_on();
    trigger_data  = waiter.get_trigger_data();
    $cast(message, trigger_data);
  endtask

  task get_message_by_sink(
    input pzvip_tilelink_opcode       target_opcode[$],
    input int                         sink,
    ref   pzvip_tilelink_message_item message
  );
    message_waiter  waiter;
    uvm_object      trigger_data;

    waiter  = new(target_opcode, sink);
    sink_waiters.push_back(waiter);

    waiter.wait_on();
    trigger_data  = waiter.get_trigger_data();
    $cast(message, trigger_data);
  endtask

  `tue_component_default_constructor(pzvip_tilelink_message_waiter)
endclass
`endif
