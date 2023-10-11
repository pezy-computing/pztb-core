//========================================
//
// Copyright (c) 2023 PEZY Computing, K.K.
//                    All Rights Reserved.
//
//========================================
interface automatic tb_pzcorebus_slave_ram_bfm
  import  pzcorebus_pkg::*;
#(
  parameter pzcorebus_config  BUS_CONFIG    = '0,
  parameter int               ADDRESS_WIDTH = BUS_CONFIG.address_width,
  parameter longint           RAM_SIZE      = -1
)(
  input var bit       i_clk,
  input var bit       i_rst_n,
  pzcorebus_if.slave  slave_if
);
  typedef bit [BUS_CONFIG.id_width-1:0]                   pzcorebus_id;
  typedef bit [BUS_CONFIG.address_width-1:0]              pzcorebus_addrss;
  typedef bit [BUS_CONFIG.data_width-1:0]                 pzcorebus_data;
  typedef bit [get_length_width(BUS_CONFIG, 1)-1:0]       pzcorebus_length;
  typedef bit [get_byte_enable_width(BUS_CONFIG, 1)-1:0]  pzcorebus_byte_enable;
  typedef bit [get_unit_enable_width(BUS_CONFIG, 1)-1:0]  pzcorebus_unit_enable;

  localparam  bit     CSRBUS          = is_csr_profile(BUS_CONFIG);
  localparam  int     BYTE_WIDTH      = BUS_CONFIG.data_width / 8;
  localparam  int     DATA_SIZE       = BUS_CONFIG.data_width / BUS_CONFIG.unit_data_width;
  localparam  int     UNIT_BYTE_WIDTH = BUS_CONFIG.unit_data_width / 8;
  localparam  int     MAX_BYTE_WIDTH  = BUS_CONFIG.max_data_width / 8;
  localparam  int     MAX_DATA_SIZE   = BUS_CONFIG.max_data_width / BUS_CONFIG.unit_data_width;
  localparam  int     POINTER_LSB     = $clog2(BYTE_WIDTH);
  localparam  longint SIZE            = (RAM_SIZE > 0) ? RAM_SIZE : 2**(ADDRESS_WIDTH - POINTER_LSB);
  localparam  int     POINTER_WIDTH   = $clog2(SIZE);

  localparam  int FILE_WORD_WIDTH = 32;
  localparam  int FILE_DATA_WORDS = BUS_CONFIG.data_width / FILE_WORD_WIDTH;

  pzcorebus_utils #(BUS_CONFIG) u_utils();

  int max_non_posted_requests;
  int start_delay;
  bit random_response;

  bit                   command_valid;
  bit                   command_accept;
  bit                   command_ack;
  pzcorebus_command     command;
  bit                   write_data_valid;
  bit                   write_data_accept;
  bit                   write_data_ack;
  pzcorebus_write_data  write_data;
  bit                   response_valid;
  bit                   response_accept;
  bit                   response_ack;
  pzcorebus_response    response;
  int                   non_posted_request_count;

  always_comb begin
    if (is_command_acceptable()) begin
      slave_if.scmd_accept  = command_accept;
      command_valid         = slave_if.mcmd_valid;
    end
    else begin
      slave_if.scmd_accept  = '0;
      command_valid         = '0;
    end
    command = slave_if.get_command();

    if (is_memory_profile(BUS_CONFIG)) begin
      slave_if.sdata_accept = write_data_accept;
      write_data_valid      = slave_if.mdata_valid;
      write_data            = slave_if.get_write_data();
    end
  end

  function bit is_command_acceptable();
    if (max_non_posted_requests <= 0) begin
      return 1;
    end
    else if (non_posted_request_count < max_non_posted_requests) begin
      return 1;
    end
    else begin
      return 0;
    end
  endfunction

  always_comb begin
    response_accept       = slave_if.mresp_accept;
    slave_if.sresp_valid  = response_valid;
    slave_if.put_response(response);
  end

  always_comb begin
    command_ack     = command_valid    && command_accept;
    write_data_ack  = write_data_valid && write_data_accept;
    response_ack    = response_valid   && response_accept;
  end

  always @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      non_posted_request_count  <= 0;
    end
    else if (command_ack || response_ack) begin
      non_posted_request_count  <=
        non_posted_request_count
        + ((command_ack  && is_non_posted_access(command)) ? 1 : 0)
        - ((response_ack && is_last_response(response)   ) ? 1 : 0);
    end
  end

  task wait_for_clock(int cycles);
    repeat (cycles) begin
      @(posedge i_clk);
    end
  endtask

  function bit is_write_access(const ref pzcorebus_command command);
    return
      pzcorebus_command_kind'(command.command) inside {
        PZCOREBUS_WRITE_COMMAND, PZCOREBUS_FULL_WRITE_COMMAND,
        PZCOREBUS_BROADCAST_COMMAND
      };
  endfunction

  function bit is_non_posted_access(const ref pzcorebus_command command);
    return command.command[PZCOREBUS_NON_POSTED_BIT];
  endfunction

  function bit is_last_response(const ref pzcorebus_response response);
    return CSRBUS || (response.response == PZCOREBUS_RESPONSE) || response.last[0];
  endfunction

//--------------------------------------------------------------
//  Accept control
//--------------------------------------------------------------
  bit command_accept_default      = 1;
  int command_accept_max_delay    = 0;
  bit write_data_accept_default   = 1;
  int write_data_accept_max_delay = 0;

  always @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      command_accept  <= command_accept_default;
    end
    else if (command_valid) begin
      drive_request_accept(
        1, command_accept_default, command_accept_max_delay
      );
    end
  end

  always @(posedge i_clk iff !CSRBUS, negedge i_rst_n) begin
    if (!i_rst_n) begin
      write_data_accept <= write_data_accept_default;
    end
    else if (write_data_valid) begin
      drive_request_accept(
        0, write_data_accept_default, write_data_accept_max_delay
      );
    end
  end

  task drive_request_accept(
    bit is_command,
    bit accept_default,
    int max_delay
  );
    int delay;

    if (delay > 0) begin
      delay = $urandom_range(1, max_delay);
    end

    if (accept_default && (delay > 0)) begin
      drive_request_accept_signal(is_command, 0);
      wait_for_clock(delay);
      drive_request_accept_signal(is_command, 1);
    end
    else if (!accept_default) begin
      wait_for_clock(delay);
      drive_request_accept_signal(is_command, 1);
      wait_for_clock(1);
      drive_request_accept_signal(is_command, 0);
    end
  endtask

  task drive_request_accept_signal(bit is_command, bit value);
    if (is_command) begin
      command_accept  <= value;
    end
    else begin
      write_data_accept <= value;
    end
  endtask

//--------------------------------------------------------------
//  Memory
//--------------------------------------------------------------
  tb_memory_model #(
    .DATA_WIDTH     (BUS_CONFIG.data_width  ),
    .DATA_TYPE      (pzcorebus_data         ),
    .WORD_SIZE      (SIZE                   ),
    .ADDRESS_WIDTH  (POINTER_WIDTH          )
  ) u_memory();

  pzcorebus_command       write_requests[$];
  pzcorebus_write_data    write_data_queue[$];
  bit                     write_busy;
  bit [POINTER_WIDTH-1:0] write_pointer;

  always @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      write_busy  = 0;
      write_requests.delete();
      write_data_queue.delete();
    end
    else begin
      if (command_ack && is_write_access(command)) begin
        write_requests.push_back(command);
      end
      if (write_data_ack) begin
        write_data_queue.push_back(write_data);
      end
      update_memory();
    end
  end

  task update_memory();
    while ((write_requests.size() > 0) && (CSRBUS || (write_data_queue.size() > 0))) begin
      bit last;

      if (!write_busy) begin
        write_busy    = 1;
        write_pointer = write_requests[0].address[POINTER_LSB+:POINTER_WIDTH];
      end

      if (CSRBUS) begin
        put(write_pointer, write_requests[0].data, '1, 1);
        last  = 1;
      end
      else begin
        put(write_pointer, write_data_queue[0].data, write_data_queue[0].byte_enable, 1);
        last  = write_data_queue[0].last;
        void'(write_data_queue.pop_front());
      end

      if (last) begin
        write_busy  = 0;
        void'(write_requests.pop_front());
      end
      else begin
        write_pointer += 1;
      end
    end
  endtask

//--------------------------------------------------------------
//  Response
//--------------------------------------------------------------
  class tb_pzcorebus_response;
    pzcorebus_response_type response_type;
    pzcorebus_id            id;
    pzcorebus_data          response_data[$];
    pzcorebus_unit_enable   unit_enable[$];

    function new(pzcorebus_command request);
      id            = request.id;
      response_type = u_utils.get_sresp(request.command);
      if (request.command inside {PZCOREBUS_READ, PZCOREBUS_ATOMIC_NON_POSTED}) begin
        create_response(request);
      end
    endfunction

    function pzcorebus_response get_response();
      pzcorebus_response  response;

      response.response     = response_type;
      response.id           = id;
      response.error        = '0;
      response.data         = get_response_data();
      response.info         = '0;
      response.unit_enable  = get_unit_enable();
      response.last         = get_last();

      return response;
    endfunction

    function bit done();
      return response_data.size() == 0;
    endfunction

    local function void create_response(pzcorebus_command request);
      int                     length;
      int                     unit_offset;
      int                     count;
      bit [POINTER_WIDTH-1:0] pointer;

      length      = u_utils.get_response_length(request.command, request.length);
      unit_offset = u_utils.get_initial_offset(request.command, request.address);
      count       = 0;
      pointer     = request.address[POINTER_LSB+:POINTER_WIDTH];
      while (count < length) begin
        int             remainings;
        int             size;
        pzcorebus_data  data;

        remainings  = length - count;
        size        = u_utils.calc_response_size(remainings, unit_offset);

        if (request.command == PZCOREBUS_READ) begin
          data  = get(pointer, 1);
        end
        else begin
          void'(std::randomize(data));
        end
        response_data.push_back(data);

        if ((request.command == PZCOREBUS_READ) && is_memory_h_profile(BUS_CONFIG)) begin
          pzcorebus_unit_enable enable;
          enable  = ((1 << size) - 1) << unit_offset;
          unit_enable.push_back(enable);
        end

        count   += size;
        pointer += 1;
      end
    endfunction

    local function pzcorebus_data get_response_data();
      if (response_data.size() > 0) begin
        return response_data.pop_front();
      end
      else begin
        return '0;
      end
    endfunction

    local function pzcorebus_unit_enable get_unit_enable();
      if (unit_enable.size() > 0) begin
        return unit_enable.pop_front();
      end
      else begin
        return '0;
      end
    endfunction

    local function logic [1:0] get_last();
      if (response_data.size() > 0) begin
        return 2'b00;
      end
      else if (is_memory_h_profile(BUS_CONFIG)) begin
        return 2'b11;
      end
      else begin
        return 2'b01;
      end
    endfunction
  endclass

  tb_pzcorebus_response response_queue[$];
  event                 push_response_event;

  always @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      response_queue.delete();
    end
    else if (command_ack && is_non_posted_access(command)) begin
      tb_pzcorebus_response response;
      response  = new(command);
      fork
        automatic tb_pzcorebus_response __response  = response;
        consume_start_delay(__response);
      join_none
    end
  end

  task consume_start_delay(tb_pzcorebus_response response);
    fork
      begin
        response_queue.push_back(response);
        wait_for_clock(start_delay);
        ->push_response_event;
      end
      @(negedge i_rst_n);
    join_any
    disable fork;
  endtask

  always @(negedge i_rst_n) begin
    if (!i_rst_n) begin
      response_valid  <= '0;
    end
  end

  always begin
    if (response_queue.size() == 0) begin
      @(push_response_event);
      wait_for_clock(1);
    end
    fork
      send_response();
      @(negedge i_rst_n);
    join_any
    disable fork;
  end

  task send_response();
    int idx;

    if (response_queue.size() == 0) begin
      return;
    end

    if (random_response) begin
      idx = $urandom_range(0, response_queue.size() - 1);
    end
    else begin
      idx = 0;
    end

    response_valid  <= '1;
    do begin
      response  <= response_queue[idx].get_response();
      do begin
        wait_for_clock(1);
      end while (!response_accept);
    end while (!response_queue[idx].done());
    response_valid  <= '0;

    response_queue.delete(idx);
  endtask

//--------------------------------------------------------------
//  API
//--------------------------------------------------------------
  function void set_max_non_posted_requests(int requests);
    max_non_posted_requests = requests;
  endfunction

  function void set_start_delay(int delay);
    if (delay >= 0) begin
      start_delay = delay;
    end
  endfunction

  function void set_random_response(bit value);
    random_response = value;
  endfunction

  function void set_default_value(pztb_pkg::pztb_mem_init default_value);
    u_memory.default_value  = default_value;
  endfunction

  function void put(
    pzcorebus_addrss      address_or_pointer,
    pzcorebus_data        data,
    pzcorebus_byte_enable byte_enable = '1,
    bit                   is_pointer  = '0
  );
    pzcorebus_data          mask;
    bit [POINTER_WIDTH-1:0] pointer;

    if (CSRBUS) begin
      mask  = '1;
    end
    else begin
      for (int i = 0;i < BYTE_WIDTH;++i) begin
        mask[8*i+:8]  = {8{byte_enable[i]}};
      end
    end

    if (is_pointer) begin
      pointer = address_or_pointer[POINTER_WIDTH-1:0];
    end
    else begin
      pointer = address_or_pointer[POINTER_LSB+:POINTER_WIDTH];
    end

    u_memory.put(pointer, data, mask);
  endfunction

  function pzcorebus_data get(
    pzcorebus_addrss  address_or_pointer,
    bit               is_pointer  = '0
  );
    bit [POINTER_WIDTH-1:0] pointer;

    if (is_pointer) begin
      pointer = address_or_pointer[POINTER_WIDTH-1:0];
    end
    else begin
      pointer = address_or_pointer[POINTER_LSB+:POINTER_WIDTH];
    end

    return u_memory.get(pointer);
  endfunction

  function void load(string filename, pzcorebus_addrss base = '0);
    bit [FILE_WORD_WIDTH-1:0] load_data[longint];
    int                       word_index;
    bit [POINTER_WIDTH-1:0]   pointer;
    pzcorebus_data            mask;
    pzcorebus_data            data;

    $readmemh(filename, load_data, base >> ($clog2(FILE_WORD_WIDTH) - 3));
    foreach (load_data[i]) begin
      word_index  = i % FILE_DATA_WORDS;
      pointer     = i / FILE_DATA_WORDS;
      mask        = {FILE_WORD_WIDTH{1'b1}} << (FILE_WORD_WIDTH * word_index);
      data        = {FILE_DATA_WORDS{load_data[i]}};
      u_memory.put(pointer, data, mask);
    end
  endfunction
endinterface
