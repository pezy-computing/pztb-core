`ifndef PZVIP_COREBUS_SLAVE_DRIVER_SVH
`define PZVIP_COREBUS_SLAVE_DRIVER_SVH
typedef tue_driver #(
  .CONFIGURATION  (pzvip_corebus_configuration  ),
  .STATUS         (pzvip_corebus_status         ),
  .REQ            (pzvip_corebus_slave_item     )
) pzvip_corebus_slave_driver_base;

typedef struct {
  pzvip_corebus_item              item;
  tue_fifo #(pzvip_corebus_item)  queue;
} pzvip_corebus_start_delay_item;

typedef class pzvip_corebus_slave_driver;

class pzvip_corebus_slave_driver_start_delay_queue;
  protected pzvip_corebus_slave_driver                  driver;
  protected tue_fifo #(pzvip_corebus_start_delay_item)  delay_queue[int];
  protected event                                       notifier[2];

  function new(pzvip_corebus_slave_driver driver);
    this.driver = driver;
  endfunction

  task put(
    pzvip_corebus_item              item,
    int                             queue_id,
    tue_fifo #(pzvip_corebus_item)  response_queue
  );
    pzvip_corebus_start_delay_item  delay_item;

    delay_item.item   = item;
    delay_item.queue  = response_queue;
    if (!delay_queue.exists(queue_id)) begin
      start_delay_thread(queue_id);
    end
    delay_queue[queue_id].put(delay_item);
  endtask

  task wait_for_active_response();
    @(notifier[0]);
  endtask

  task do_reset();
    ->notifier[1];
  endtask

  protected task start_delay_thread(int id);
    delay_queue[id] = new("delay_queue", 0);
    fork
      automatic int __id  = id;
      delay_thread(__id);
    join_none
  endtask

  protected task delay_thread(int id);
    pzvip_corebus_start_delay_item              delay_item;
    tue_fifo #(pzvip_corebus_start_delay_item)  queue;

    queue = delay_queue[id];
    forever begin
      fork
        forever begin
          queue.get(delay_item);
          consume_start_delay(delay_item);
        end
        @(notifier[1]);
      join_any
      disable fork;

      if ((delay_item.item != null) && (!delay_item.item.ended())) begin
        driver.end_tr(delay_item.item);
      end

      while (queue.try_get(delay_item)) begin
        if (!delay_item.item.ended()) begin
          driver.end_tr(delay_item.item);
        end
      end
    end
  endtask

  protected task consume_start_delay(ref pzvip_corebus_start_delay_item delay_item);
    delay_item.item.wait_for_request_done();
    driver.consume_delay(delay_item.item.start_delay);
    delay_item.queue.put(delay_item.item);
    ->notifier[0];
  endtask
endclass

class pzvip_corebus_slave_driver_response;
  pzvip_corebus_item          item;
  int                         size;
  int                         burst_index;
  int                         burst_offset;
  int                         unit_index;
  int                         unit_offset;
  pzvip_corebus_configuration configuration;

  function new(pzvip_corebus_item item, pzvip_corebus_configuration configuration);
    this.item           = item;
    this.configuration  = configuration;
    this.burst_offset   = calc_burst_offset();
    this.unit_offset    = calc_unit_offset();
  endfunction

  function logic get_error();
    return item.error[burst_index];
  endfunction

  function pzvip_corebus_data get_data();
    if (item.response_type == PZVIP_COREBUS_RESPONSE_WITH_DATA) begin
      return item.response_data[burst_index];
    end
    else begin
      return '0;
    end
  endfunction

  function pzvip_corebus_response_info get_info();
    if (configuration.response_info_width > 0) begin
      return item.response_info[burst_index];
    end
    else begin
      return '0;
    end
  endfunction

  function pzvip_corebus_unit_enable get_unit_enable();
    if (configuration.profile != PZVIP_COREBUS_MEMORY_H) begin
      return '0;
    end
    else if (item.response_type == PZVIP_COREBUS_RESPONSE) begin
      return '0;
    end
    else begin
      int unit_size;
      int unit_position;
      unit_size     = get_unit_size();
      unit_position = (unit_offset + unit_index) % configuration.max_data_size;
      return ((1 << unit_size) - 1) << unit_position;
    end
  endfunction

  function logic [1:0] get_last();
    bit [1:0] last;

    if (configuration.profile == PZVIP_COREBUS_CSR) begin
      return '0;
    end

    if (item.response_type == PZVIP_COREBUS_RESPONSE) begin
      last  = 2'b11;
    end
    else begin
      last[1] = size == 1;
      last[0] = (burst_index + 1) == item.get_burst_length();
    end

    if (configuration.profile == PZVIP_COREBUS_MEMORY_H) begin
      return last;
    end
    else begin
      return last[0];
    end
  endfunction

  function int get_delay();
    return item.response_delay[burst_index];
  endfunction

  function bit is_last_response_done();
    if (configuration.profile == PZVIP_COREBUS_CSR) begin
      return 1;
    end
    else if (item.response_type == PZVIP_COREBUS_RESPONSE) begin
      return 1;
    end
    else begin
      return burst_index == item.get_burst_length();
    end
  endfunction

  function void next();
    size        -= 1;
    burst_index += 1;
    if (configuration.profile == PZVIP_COREBUS_MEMORY_H) begin
      unit_index  += get_unit_size();
    end
  endfunction

  protected function int calc_burst_offset();
    if (configuration.profile == PZVIP_COREBUS_MEMORY_H) begin
      int max_byte_size;
      int byte_size;
      max_byte_size = configuration.max_data_width / 8;
      byte_size     = configuration.data_width / 8;
      return (item.address % max_byte_size) / byte_size;
    end
    else begin
      return 0;
    end
  endfunction

  protected function int calc_unit_offset();
    if (configuration.profile == PZVIP_COREBUS_MEMORY_H) begin
      return calc_initial_offset(configuration, item.command, item.address, 0);
    end
    else begin
      return 0;
    end
  endfunction

  protected function int get_unit_size();
    if (item.is_atomic_request()) begin
      return configuration.data_size;
    end
    else begin
      int data_size;
      int unit_size[2];
      data_size     = configuration.data_size;
      unit_size[0]  = data_size - ((unit_offset + unit_index) % data_size);
      unit_size[1]  = item.length - unit_index;
      if (unit_size[0] < unit_size[1]) begin
        return unit_size[0];
      end
      else begin
        return unit_size[1];
      end
    end
  endfunction
endclass

class pzvip_corebus_slave_driver extends pzvip_corebus_component_base #(
  .BASE (pzvip_corebus_slave_driver_base  )
);
  protected pzvip_corebus_access_count                    access_count;
  protected pzvip_corebus_slave_driver_start_delay_queue  start_delay_queue;
  protected tue_fifo #(pzvip_corebus_item)                response_queue[int];
  protected pzvip_corebus_slave_driver_response           active_responses[$];
  protected int                                           active_ids[$];
  protected int                                           current_response_index;
  protected int                                           accept_delay_queue[2][$];
  protected int                                           preceded_accept_delay[2];

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    start_delay_queue = new(this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    access_count  = status.access_count;
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      do_reset();
      fork
        main();
        @(negedge vif.reset_n);
      join_any
      disable fork;
    end
  endtask

  protected task do_reset();
    start_delay_queue.do_reset();

    foreach (response_queue[i]) begin
      pzvip_corebus_item  item;
      while (response_queue[i].try_get(item)) begin
        if (!item.ended()) begin
          end_tr(item);
        end
      end
    end

    foreach (active_responses[i]) begin
      if (!active_responses[i].item.ended()) begin
        end_tr(active_responses[i].item);
      end
    end
    active_responses.delete();
    active_ids.delete();

    accept_delay_queue[0].delete();
    accept_delay_queue[1].delete();
    preceded_accept_delay[0]  = 0;
    preceded_accept_delay[1]  = 0;

    if (configuration.reset_by_agent) begin
      vif.reset_slave();
    end

    @(posedge vif.reset_n);
  endtask

  protected task main();
    fork
      queue_item();
      drive_command_accept();
      drive_data_accept();
      drive_response();
    join
  endtask

  protected task queue_item();
    pzvip_corebus_slave_item  item;
    forever begin
      seq_item_port.get_next_item(item);
      accept_item(item);

      accept_delay_queue[0].push_back(item.command_accept_delay);
      if ((profile != PZVIP_COREBUS_CSR) && item.is_request_with_data()) begin
        foreach (item.data_accept_delay[i]) begin
          accept_delay_queue[1].push_back(item.data_accept_delay[i]);
        end
      end

      if (item.is_non_posted_request() && (!is_response_dropped(item))) begin
        put_start_delay_queue(item);
      end

      seq_item_port.item_done();
    end
  endtask

  protected function bit is_response_dropped(pzvip_corebus_item item);
    return item.drop_response || configuration.drop_response;
  endfunction

  protected task put_start_delay_queue(pzvip_corebus_item item);
    int queue_id;

    case (configuration.response_order)
      PZVIP_COREBUS_IN_ORDER_RESPONSE:  queue_id  = 0;
      default:                          queue_id  = item.id;
    endcase

    if (!response_queue.exists(queue_id)) begin
      response_queue[queue_id]  = new("response_queue", 0);
    end

    start_delay_queue.put(item, queue_id, response_queue[queue_id]);
  endtask

  protected task drive_command_accept();
    int delay;

    forever @(vif.slave_cb) begin
      if (force_command_accept_low()) begin
        vif.slave_cb.scmd_accept  <= '0;
      end
      else if (vif.slave_cb.mcmd_valid) begin
        get_accept_delay(0, configuration.command_accept_delay, delay);
        if (configuration.default_command_accept) begin
          if (!vif.slave_cb.scmd_accept) begin
            vif.slave_cb.scmd_accept  <= '1;
            consume_delay(1);
          end
          vif.slave_cb.scmd_accept  <= '0;
          consume_delay(delay);
          vif.slave_cb.scmd_accept  <= '1;
        end
        else begin
          consume_delay(delay);
          vif.slave_cb.scmd_accept  <= '1;
          consume_delay(1);
          vif.slave_cb.scmd_accept  <= '0;
        end
      end
    end
  endtask

  protected function bit force_command_accept_low();
    return
      configuration.force_command_accept_low ||
      ((configuration.outstanding_non_posted_accesses > 0) && (access_count.ongoing_non_posted_access_count >= configuration.outstanding_non_posted_accesses));
  endfunction

  protected task drive_data_accept();
    int delay;

    if (profile == PZVIP_COREBUS_CSR) begin
      return;
    end

    forever @(vif.slave_cb) begin
      if (configuration.force_data_accept_low) begin
        vif.sdata_accept  <= '0;
      end
      else if (vif.slave_cb.mdata_valid) begin
        get_accept_delay(1, configuration.data_accept_delay, delay);
        if (configuration.default_data_accept) begin
          if (!vif.slave_cb.sdata_accept) begin
            vif.slave_cb.sdata_accept <= '1;
            consume_delay(1);
          end
          vif.slave_cb.sdata_accept <= '0;
          consume_delay(delay);
          vif.slave_cb.sdata_accept <= '1;
        end
        else begin
          consume_delay(delay);
          vif.slave_cb.sdata_accept <= '1;
          consume_delay(1);
          vif.slave_cb.sdata_accept <= '0;
        end
      end
    end
  endtask

  protected task get_accept_delay(
    input int                       index,
    input pzvip_delay_configuration delay_configuration,
    ref   int                       delay
  );
    if (accept_delay_queue[index].size() == 0) begin
      uvm_wait_for_nba_region();
    end

    if (accept_delay_queue[index].size() > 0) begin
      while (preceded_accept_delay[index] > 0) begin
        preceded_accept_delay[index]  -= 1;
        void'(accept_delay_queue[index].pop_front());
      end
      delay = accept_delay_queue[index].pop_front();
    end
    else begin
      preceded_accept_delay[index]  += 1;
      delay = randomize_accept_delay(delay_configuration);
    end
  endtask

  protected function int randomize_accept_delay(pzvip_delay_configuration delay_configuration);
    int delay;
    if (!std::randomize(delay) with {
      `pzvip_delay_constraint(delay, delay_configuration)
    }) begin
      `uvm_fatal("RNDFLD", "Randomization failed")
    end
  endfunction

  protected task drive_response();
    pzvip_corebus_slave_driver_response response_item;
    int                                 size;

    forever begin
      get_next_response_item(response_item);
      if (response_item != null) begin
        while (configuration.block_sending_response) begin
          consume_delay(1);
        end

        response_item.size  = get_response_size(response_item);
        execute_response_item(response_item);

        if (response_item.is_last_response_done()) begin
          active_responses.delete(current_response_index);
          active_ids.delete(current_response_index);
        end
      end
    end
  endtask

  protected task get_next_response_item(ref pzvip_corebus_slave_driver_response response_item);
    pzvip_corebus_slave_driver_response new_response;
    pzvip_corebus_item                  new_item;

    if (no_response()) begin
      start_delay_queue.wait_for_active_response();
      wait_for_clock_edge();
    end

    foreach (response_queue[i]) begin
      if (!is_response_acceptable(i)) begin
        continue;
      end

      response_queue[i].get(new_item);
      new_response  = new(new_item, configuration);
      active_responses.push_back(new_response);
      active_ids.push_back(i);
    end

    if (active_responses.size() == 0) begin
      response_item = null;
      return;
    end

    current_response_index  = select_response_index();
    response_item           = active_responses[current_response_index];
  endtask

  protected function bit no_response();
    if (active_responses.size() > 0) begin
      return 0;
    end
    foreach (response_queue[i]) begin
      if (response_queue[i].used() > 0) begin
        return 0;
      end
    end
    return 1;
  endfunction

  protected function bit is_response_acceptable(int id);
    if (response_queue[id].used() == 0) begin
      return 0;
    end
    else if (id inside {active_ids}) begin
      return 0;
    end
    else if (configuration.outstanding_responses > 0) begin
      return active_responses.size() < configuration.outstanding_responses;
    end
    else begin
      return 1;
    end
  endfunction

  protected function int select_response_index();
    if (configuration.response_order == PZVIP_COREBUS_OUT_OF_ORDER_RESPONSE) begin
      foreach (active_ids[i]) begin
        randcase
          1:  return i;
          1:  ;
        endcase
      end
    end

    return 0;
  endfunction

  protected function int get_response_size(pzvip_corebus_slave_driver_response response_item);
    if (response_item.item.response_type == PZVIP_COREBUS_RESPONSE) begin
      return 1;
    end
    else if (!configuration.enable_response_interleaving) begin
      return response_item.item.get_burst_length();
    end
    else if (response_item.item.is_atomic_request()) begin
      return response_item.item.get_burst_length();
    end
    else begin
      return randomize_response_size(response_item);
    end
  endfunction

  protected function int randomize_response_size(pzvip_corebus_slave_driver_response response_item);
    int size;
    int burst_index;
    int burst_offset;
    int burst_boundary;
    int min_size;
    int max_size;
    int remainings;

    burst_index     = response_item.burst_index;
    burst_offset    = response_item.burst_offset;
    burst_boundary  = configuration.max_data_width / configuration.data_width;
    min_size        = configuration.min_interleave_size;
    max_size        = configuration.max_interleave_size;
    remainings      = response_item.item.get_burst_length() - burst_index;
    if (std::randomize(size) with {
      size inside {[1:remainings]};
      (size == remainings) || (((burst_offset + burst_index + size) % burst_boundary) == 0);
      if ((max_size > 0) && (remainings > max_size)) {
        size <= max_size;
      }
      if (remainings > min_size) {
        size >= min_size;
      }
    }) begin
      return size;
    end
    else begin
      `uvm_fatal("RNDFLD", "Randomization failed")
    end
  endfunction

  protected virtual task execute_response_item(
    pzvip_corebus_slave_driver_response response_item
  );
    while (response_item.size > 0) begin
      drive_active_response(response_item);
    end
  endtask

  protected task drive_active_response(pzvip_corebus_slave_driver_response response_item);
    consume_delay(response_item.get_delay());
    if (!response_item.item.response_began()) begin
      begin_response(response_item.item);
    end

    vif.slave_cb.sresp_valid  <= '1;
    vif.slave_cb.sresp        <= response_item.item.response_type;
    vif.slave_cb.sid          <= response_item.item.id;
    vif.slave_cb.serror       <= response_item.get_error();
    vif.slave_cb.sdata        <= response_item.get_data();
    vif.slave_cb.sinfo        <= response_item.get_info();
    vif.slave_cb.sresp_uniten <= response_item.get_unit_enable();
    vif.slave_cb.sresp_last   <= response_item.get_last();

    do begin
      consume_delay(1);
    end while (!vif.slave_cb.mresp_accept);
    vif.slave_cb.sresp_valid  <= '0;

    response_item.next();
    if (response_item.is_last_response_done()) begin
      end_response(response_item.item);
    end
  endtask

  virtual task consume_delay(int delay);
    repeat (delay) begin
      @(vif.slave_cb);
    end
  endtask

  virtual task wait_for_clock_edge();
    if (!vif.at_slave_cb.triggered) begin
      @(vif.at_slave_cb);
    end
  endtask

  `tue_component_default_constructor(pzvip_corebus_slave_driver)
  `uvm_component_utils(pzvip_corebus_slave_driver)
endclass
`endif
