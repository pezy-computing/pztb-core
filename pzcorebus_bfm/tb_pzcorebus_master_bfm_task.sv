//========================================
//
// Copyright (c) 2023 PEZY Computing, K.K.
//                    All Rights Reserved.
//
//========================================
interface automatic tb_pzcrebus_master_bfm_task
  import  pzcorebus_pkg::*;
#(
  parameter pzcorebus_config  BUS_CONFIG              = '0,
  parameter int               API_DATA_WIDTH          = 256,
  parameter bit               USE_NON_POSTED_ID_LOCK  = 1
)(
  input var bit                           i_clk,
  input var bit                           i_rst_n,
  input var bit [BUS_CONFIG.id_width-1:0] i_id_base,
  input var bit [BUS_CONFIG.id_width-1:0] i_id_mask,
  pzcorebus_if.master                     master_if
);
  localparam  bit CSRBUS  = is_csr_profile(BUS_CONFIG);

  typedef bit [BUS_CONFIG.id_width-1:0]                     pzcorebus_id;
  typedef bit [BUS_CONFIG.address_width-1:0]                pzcorebus_addrss;
  typedef bit [get_length_width(BUS_CONFIG, 1)-1:0]         pzcorebus_length;
  typedef bit [get_unpacked_length_width(BUS_CONFIG)-1:0]   pzcorebus_unpacked_length;
  typedef bit [get_request_param_width(BUS_CONFIG, 1)-1:0]  pzcorebus_request_param;
  typedef bit [BUS_CONFIG.data_width-1:0]                   pzcorebus_data;
  typedef bit [get_byte_enable_width(BUS_CONFIG, 1)-1:0]    pzcorebus_byte_enable;

  bit                   command_valid;
  bit                   command_accept;
  pzcorebus_command     command;
  bit                   write_data_valid;
  bit                   write_data_accept;
  pzcorebus_write_data  write_data;
  bit                   response_valid;
  bit                   response_accept;
  pzcorebus_response    response;

  always_comb begin
    command_accept        = master_if.scmd_accept;
    master_if.mcmd_valid  = command_valid;
    master_if.put_command(command);

    if (!CSRBUS) begin
      write_data_accept     = master_if.sdata_accept;
      master_if.mdata_valid = write_data_valid;
      master_if.put_write_data(write_data);
    end
  end

  always_comb begin
    master_if.mresp_accept  = response_accept;
    response_valid          = master_if.sresp_valid;
    response                = master_if.get_response();
  end

  clocking cb @(posedge i_clk);
    input   i_rst_n;
    output  command_valid;
    input   command_accept;
    output  command;
    output  write_data_valid;
    input   write_data_accept;
    output  write_data;
    sequence at_posedge;
      1;
    endsequence
  endclocking

  task wait_for_clock(int cycles, bit use_cb);
    if (use_cb) begin
      repeat (cycles) begin
        @(cb);
      end
    end
    else begin
      repeat (cycles) begin
        @(posedge i_clk);
      end
    end
  endtask

//--------------------------------------------------------------
//  Accept control
//--------------------------------------------------------------
  bit response_accept_default   = 1;
  int response_accept_max_delay = 0;

  always @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      response_accept <= response_accept_default;
    end
    else if (response_valid) begin
      drive_response_accept();
    end
  end

  task drive_response_accept();
    int delay;

    if (response_accept_max_delay > 0) begin
      delay = $urandom_range(1, response_accept_max_delay);
    end

    if (response_accept_default && (delay > 0)) begin
      response_accept <= '0;
      wait_for_clock(delay, 0);
      response_accept <= '1;
    end
    else if (!response_accept_default) begin
      wait_for_clock(delay, 0);
      response_accept <= '1;
      wait_for_clock(delay, 0);
      response_accept <= '0;
    end
  endtask

//--------------------------------------------------------------
//  BFM implementation
//--------------------------------------------------------------
  class tb_response_receiver;
    event           done;
    bit             complete;
    pzcorebus_data  data[$];

    task wait_for_done();
      @(done);
    endtask

    function void put_response(const ref pzcorebus_response response);
      if (response.response == PZCOREBUS_RESPONSE) begin
        complete  = 1;
        ->done;
      end
      else begin
        data.push_back(response.data[0+:BUS_CONFIG.data_width]);
        if (CSRBUS || response.last[0]) begin
          complete  = 1;
          ->done;
        end
      end
    endfunction
  endclass

  tb_response_receiver  response_receiver[pzcorebus_id][$];

  always @(negedge i_rst_n) begin
    command_valid     <= '0;
    write_data_valid  <= '0;
  end

  always @(posedge i_clk) begin
    if (response_valid && response_accept) begin
      receive_response(response);
    end
  end

  function void receive_response(const ref pzcorebus_response response);
    pzcorebus_id          id;
    tb_response_receiver  receiver;
    id        = response.id & i_id_mask;
    receiver  = response_receiver[id][0];
    if (receiver != null) begin
      receiver.put_response(response);
      if (receiver.complete) begin
        void'(response_receiver[id].pop_front());
      end
    end
    else begin
      $warning("receive unexpected response: id %h (%m)", response.id);
    end
  endfunction

  task send_command(
    pzcorebus_command_type  command_type,
    pzcorebus_id            id,
    pzcorebus_addrss        address,
    int                     burst_length,
    pzcorebus_request_param param,
    pzcorebus_data          data,
    pzcorebus_byte_enable   byte_enable
  );
    pzcorebus_command command;

    command.command     = command_type;
    command.id          = (id & i_id_mask) | i_id_base;
    command.address     = address;
    command.length      = calc_length(command_type, address, burst_length);
    command.param       = param;
    command.data        = data;
    command.byte_enable = byte_enable;

    cb.command_valid  <= '1;
    cb.command        <= command;

    do begin
      wait_for_clock(1, 1);
    end while (!cb.command_accept);

    cb.command_valid  <= '0;
  endtask

  localparam  int BYTE_WIDTH        = BUS_CONFIG.data_width / 8;
  localparam  int UNIT_BYTE_WIDTH   = BUS_CONFIG.unit_data_width / 8;
  localparam  int API_BYTE_WIDTH    = API_DATA_WIDTH / 8;
  localparam  int API_DATA_UNITS    = API_BYTE_WIDTH / UNIT_BYTE_WIDTH;
  localparam  int DATA_RATIO        = BYTE_WIDTH     / API_BYTE_WIDTH;

  function int calc_burst_offset(pzcorebus_addrss address);
    if (BUS_CONFIG.data_width > API_DATA_WIDTH) begin
      return (address % BYTE_WIDTH) / API_BYTE_WIDTH;
    end
    else begin
      return 0;
    end
  endfunction

  function pzcorebus_length calc_length(
    pzcorebus_command_type  command_type,
    pzcorebus_addrss        address,
    int                     burst_length
  );
    if (command_type inside {PZCOREBUS_MESSAGE, PZCOREBUS_MESSAGE_NON_POSTED}) begin
      return burst_length;  //  message code
    end

    if (is_memory_profile(BUS_CONFIG)) begin
      int offset;
      offset  = (address % API_BYTE_WIDTH) / UNIT_BYTE_WIDTH;
      return burst_length * API_DATA_UNITS - offset;
    end
    else begin
      return burst_length;
    end
  endfunction

  task send_write_data(
    input     pzcorebus_addrss          address,
    const ref bit [API_DATA_WIDTH-1:0]  data[$],
    const ref bit [API_BYTE_WIDTH-1:0]  byte_enable[$]
  );
    pzcorebus_write_data  write_data;
    int                   index;

    index       = calc_burst_offset(address);
    write_data  = '{default: '0};

    cb.write_data_valid <= '1;
    foreach (data[i]) begin
      write_data.data[API_DATA_WIDTH*index+:API_DATA_WIDTH]         = data[i];
      write_data.byte_enable[API_BYTE_WIDTH*index+:API_BYTE_WIDTH]  = byte_enable[i];
      write_data.last                                               = i == (data.size() - 1);

      index += 1;
      if ((index == DATA_RATIO) || write_data.last) begin
        cb.write_data <= write_data;
        do begin
          wait_for_clock(1, 1);
        end while (!cb.write_data_accept);

        index       = 0;
        write_data  = '{default: '0};
      end
    end
    cb.write_data_valid <= '0;
  endtask

  function tb_response_receiver get_response_receiver(pzcorebus_id id);
    tb_response_receiver  receiver;
    pzcorebus_id          id_masked;
    receiver  = new();
    id_masked = id & i_id_mask;
    response_receiver[id_masked].push_back(receiver);
    return receiver;
  endfunction

  semaphore bus_access_lock;
  semaphore non_posted_access_lock[pzcorebus_id];

  initial begin
    bus_access_lock = new(1);
  end

  task get_bus_access(bit non_posted, int id);
    if (non_posted) begin
      get_non_posted_access(id);
    end
    bus_access_lock.get(1);

    while ((!cb.at_posedge.triggered) || (!cb.i_rst_n)) begin
      wait_for_clock(1, 1);
    end
  endtask

  task get_non_posted_access(int id);
    if (USE_NON_POSTED_ID_LOCK) begin
      pzcorebus_id  id_masked = id & i_id_mask;
      if (!non_posted_access_lock.exists(id_masked)) begin
        non_posted_access_lock[id_masked]  = new(1);
      end
      non_posted_access_lock[id_masked].get(1);
    end
  endtask

  function void release_bus_access();
    bus_access_lock.put(1);
  endfunction

  function void release_non_posted_id(int id);
    if (USE_NON_POSTED_ID_LOCK) begin
      pzcorebus_id  id_masked = id & i_id_mask;
      non_posted_access_lock[id_masked].put(1);
    end
  endfunction

//--------------------------------------------------------------
//  API
//--------------------------------------------------------------
  task cfg_write(
    pzcorebus_addrss  address,
    bit [31:0]        data,
    bit [3:0]         byte_enable = '1
  );
    get_bus_access(0, 0);
    send_command(PZCOREBUS_WRITE, 0, address, 1, 0, data, byte_enable);
    release_bus_access();
  endtask

  task cfg_read(
    input pzcorebus_id      id,
    input pzcorebus_addrss  address,
    ref   bit [31:0]        data
  );
    tb_response_receiver  receiver;

    receiver  = get_response_receiver(id);

    get_bus_access(1, id);
    send_command(PZCOREBUS_READ, id, address, 1, 0, 0, 0);
    release_bus_access();

    receiver.wait_for_done();
    release_non_posted_id(id);

    data  = receiver.data[0];
  endtask

  task mem_write(
    input     pzcorebus_addrss          address,
    const ref bit [API_DATA_WIDTH-1:0]  data[$],
    const ref bit [API_BYTE_WIDTH-1:0]  byte_enable[$]
  );
    get_bus_access(0, 0);
    fork
      send_command(PZCOREBUS_WRITE, 0, address, data.size(), 0, 0, 0);
      send_write_data(address, data, byte_enable);
    join
    release_bus_access();
  endtask

  task mem_write_non_posted(
    input     pzcorebus_id              id,
    input     pzcorebus_addrss          address,
    const ref bit [API_DATA_WIDTH-1:0]  data[$],
    const ref bit [API_BYTE_WIDTH-1:0]  byte_enable[$]
  );
    tb_response_receiver  receiver;

    receiver  = get_response_receiver(id);
    get_bus_access(1, id);
    fork
      send_command(PZCOREBUS_WRITE_NON_POSTED, id, address, data.size(), 0, 0, 0);
      send_write_data(address, data, byte_enable);
    join
    release_bus_access();

    receiver.wait_for_done();
    release_non_posted_id(id);
  endtask

  task send_mem_write_non_posted_request(
    input     pzcorebus_id              id,
    input     pzcorebus_addrss          address,
    const ref bit [API_DATA_WIDTH-1:0]  data[$],
    const ref bit [API_BYTE_WIDTH-1:0]  byte_enable[$]
  );
    tb_response_receiver  receiver;

    receiver  = get_response_receiver(id);
    get_bus_access(1, id);
    fork
      send_command(PZCOREBUS_WRITE_NON_POSTED, id, address, data.size(), 0, 0, 0);
      send_write_data(address, data, byte_enable);
    join
    release_bus_access();

    fork
      begin
        receiver.wait_for_done();
        release_non_posted_id(id);
      end
    join_none
  endtask

  task mem_single_write(
    input pzcorebus_addrss  address,
    input bit [31:0]        data
  );
    int                       shift;
    bit [API_DATA_WIDTH-1:0]  write_data[$];
    bit [API_BYTE_WIDTH-1:0]  byte_enable[$];
    shift = (address % API_BYTE_WIDTH) / 4;
    write_data.push_back(data << (32 * shift));
    byte_enable.push_back(4'hF << (4 * shift));
    mem_write(address, write_data, byte_enable);
  endtask

  task mem_read(
    input pzcorebus_id              id,
    input pzcorebus_addrss          address,
    input int                       burst_length,
    ref   bit [API_DATA_WIDTH-1:0]  data[$]
  );
    tb_response_receiver  receiver;
    int                   firsst_index;

    receiver  = get_response_receiver(id);

    get_bus_access(1, id);
    send_command(PZCOREBUS_READ, id, address, burst_length, 0, 0, 0);
    release_bus_access();

    receiver.wait_for_done();
    release_non_posted_id(id);

    firsst_index  = calc_burst_offset(address);
    foreach (receiver.data[i]) begin
      for (int j = (i == 0) ? firsst_index : 0;j < DATA_RATIO;++j) begin
        data.push_back(receiver.data[i][API_DATA_WIDTH*j+:API_DATA_WIDTH]);
        if (data.size() == burst_length) begin
          return;
        end
      end
    end
  endtask

  task send_mem_read_command(
    pzcorebus_id      id,
    pzcorebus_addrss  address,
    int               burst_length
  );
    tb_response_receiver  receiver;

    receiver  = get_response_receiver(id);

    get_bus_access(1, id);
    send_command(PZCOREBUS_READ, id, address, burst_length, 0, 0, 0);
    release_bus_access();

    fork
      begin
        receiver.wait_for_done();
        release_non_posted_id(id);
      end
    join_none
  endtask

  task mem_single_read(
    input pzcorebus_id      id,
    input pzcorebus_addrss  address,
    ref   bit [31:0]        data
  );
    int                       shift;
    bit [API_DATA_WIDTH-1:0]  read_data[$];
    mem_read(id, address, 1, read_data);
    shift = (address % API_BYTE_WIDTH) / 4;
    data  = read_data[0][32*shift+:32];
  endtask

  task atomic_posted(
    pzcorebus_addrss          address,
    pzcorebus_request_param   command,
    bit [API_DATA_WIDTH-1:0]  data
  );
    bit [API_DATA_WIDTH-1:0]  data_queue[$];
    bit [API_BYTE_WIDTH-1:0]  byte_enable_queue[$];

    data_queue.push_back(data);
    byte_enable_queue.push_back('0);

    get_bus_access(0, 0);
    fork
      send_command(PZCOREBUS_ATOMIC, 0, address, 1, command, 0, 0);
      send_write_data(0, data_queue, byte_enable_queue);
    join
    release_bus_access();
  endtask

  task atomic_non_posted(
    input pzcorebus_id              id,
    input pzcorebus_addrss          address,
    input pzcorebus_request_param   command,
    input bit [API_DATA_WIDTH-1:0]  data,
    ref   bit [API_DATA_WIDTH-1:0]  result
  );
    bit [API_DATA_WIDTH-1:0]  data_queue[$];
    bit [API_BYTE_WIDTH-1:0]  byte_enable_queue[$];
    tb_response_receiver      receiver;

    data_queue.push_back(data);
    byte_enable_queue.push_back('0);

    receiver  = get_response_receiver(id);
    get_bus_access(1, id);
    fork
      send_command(PZCOREBUS_ATOMIC_NON_POSTED, id, address, 1, command, 0, 0);
      send_write_data(0, data_queue, byte_enable_queue);
    join
    release_bus_access();

    receiver.wait_for_done();
    release_non_posted_id(id);

    result  = receiver.data[0];
  endtask

  task send_atomic_non_posted_request(
    input pzcorebus_id              id,
    input pzcorebus_addrss          address,
    input pzcorebus_request_param   command,
    input bit [API_DATA_WIDTH-1:0]  data
  );
    bit [API_DATA_WIDTH-1:0]  data_queue[$];
    bit [API_BYTE_WIDTH-1:0]  byte_enable_queue[$];
    tb_response_receiver      receiver;

    data_queue.push_back(data);
    byte_enable_queue.push_back('0);

    receiver  = get_response_receiver(id);
    get_bus_access(1, id);
    fork
      send_command(PZCOREBUS_ATOMIC_NON_POSTED, id, address, 1, command, 0, 0);
      send_write_data(0, data_queue, byte_enable_queue);
    join
    release_bus_access();

    fork
      begin
        receiver.wait_for_done();
        release_non_posted_id(id);
      end
    join_none
  endtask

  task message_posted(
    pzcorebus_addrss  address,
    int               message_code
  );
    get_bus_access(0, 0);
    send_command(PZCOREBUS_MESSAGE, 0, address, 0, message_code, 0, 0);
    release_bus_access();
  endtask

  task message_non_posted(
    pzcorebus_id      id,
    pzcorebus_addrss  address,
    int               message_code
  );
    tb_response_receiver  receiver;

    receiver  = get_response_receiver(id);
    get_bus_access(1, id);
    send_command(PZCOREBUS_MESSAGE_NON_POSTED, id, address, 0, message_code, 0, 0);
    release_bus_access();

    receiver.wait_for_done();
    release_non_posted_id(id);
  endtask
endinterface
