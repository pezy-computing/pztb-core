//========================================
//
// Copyright (c) 2023 PEZY Computing, K.K.
//
//========================================
interface automatic tb_pzcorebus_slave_ram_bfm
  import  `PZCOREBUS_COMMON_PKG::*;
#(
  parameter pzcorebus_config  BUS_CONFIG    = '0,
  parameter type              MCMD          = logic,
  parameter type              MDATA         = logic,
  parameter type              SRESP         = logic,
  parameter int               ADDRESS_WIDTH = BUS_CONFIG.address_width,
  parameter longint           RAM_SIZE      = -1
)(
  input   var bit   i_clk,
  input   var bit   i_rst_n,
  output  var logic o_scmd_accept,
  input   var logic i_mcmd_valid,
  input   var MCMD  i_mcmd,
  output  var logic o_sdata_accept,
  input   var logic i_mdata_valid,
  input   var MDATA i_mdata,
  input   var logic i_mresp_accept,
  output  var logic o_sresp_valid,
  output  var SRESP o_sresp
);
  localparam  int UNIT_ENABLE_WIDTH = get_signal_width(BUS_CONFIG.sresp_info.sresp_uniten.width, 1);

  typedef bit [BUS_CONFIG.id_width-1:0]       pzcorebus_id;
  typedef bit [BUS_CONFIG.address_width-1:0]  pzcorebus_addrss;
  typedef bit [BUS_CONFIG.data_width-1:0]     pzcorebus_data;
  typedef bit [BUS_CONFIG.data_width/8-1:0]   pzcorebus_byte_enable;
  typedef bit [UNIT_ENABLE_WIDTH-1:0]         pzcorebus_unit_enable;

  localparam  int     BYTE_WIDTH      = BUS_CONFIG.data_width / 8;
  localparam  int     DATA_SIZE       = BUS_CONFIG.data_width / BUS_CONFIG.unit_data_width;
  localparam  int     UNIT_BYTE_WIDTH = BUS_CONFIG.unit_data_width / 8;
  localparam  int     MAX_BYTE_WIDTH  = BUS_CONFIG.max_data_width / 8;
  localparam  int     MAX_DATA_SIZE   = BUS_CONFIG.max_data_width / BUS_CONFIG.unit_data_width;
  localparam  int     POINTER_LSB     = $clog2(BYTE_WIDTH);
  localparam  longint SIZE            = (RAM_SIZE > 0) ? RAM_SIZE : 2**(ADDRESS_WIDTH - POINTER_LSB);
  localparam  int     POINTER_WIDTH   = $clog2(SIZE);

  localparam  bit IS_CSR  = is_csr_profile(BUS_CONFIG);
  localparam  bit IS_MEM  = is_mem_profile(BUS_CONFIG);

  localparam  int FILE_WORD_WIDTH = 32;
  localparam  int FILE_DATA_WORDS = BUS_CONFIG.data_width / FILE_WORD_WIDTH;

  pzcorebus_utils #(BUS_CONFIG) u_utils();

  int max_non_posted_requests;
  int start_delay;
  bit random_response;

  bit   scmd_accept;
  bit   mcmd_valid;
  bit   mcmd_ack;
  MCMD  mcmd;
  bit   sdata_accept;
  bit   mdata_valid;
  bit   mdata_ack;
  MDATA mdata;
  bit   mresp_accept;
  bit   sresp_valid;
  bit   sresp_ack;
  SRESP sresp;
  int   np_request_count;

  always_comb begin
    mcmd_ack  = scmd_accept && mcmd_valid;
    mdata_ack = sdata_accept && mdata_valid;
    sresp_ack = mresp_accept && sresp_valid;
  end

  always_comb begin
    if ((max_non_posted_requests <= 0) || (np_request_count < max_non_posted_requests)) begin
      o_scmd_accept = scmd_accept;
      mcmd_valid    = i_mcmd_valid;
    end
    else begin
      o_scmd_accept = '0;
      mcmd_valid    = '0;
    end
    mcmd  = i_mcmd;

    if (IS_MEM) begin
      o_sdata_accept  = sdata_accept;
      mdata_valid     = i_mdata_valid;
    end
    else begin
      o_sdata_accept  = '0;
      mdata_valid     = '0;
    end
    mdata = i_mdata;
  end

  always_comb begin
    mresp_accept  = i_mresp_accept;
    o_sresp_valid = sresp_valid;
    o_sresp       = sresp;
  end

  always @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      np_request_count  <= 0;
    end
    else if (mcmd_ack || sresp_ack) begin
      np_request_count  <=
        update_np_request_count(
          np_request_count,
          mcmd_ack, mcmd, sresp_ack, sresp
        );
    end
  end

  function automatic int update_np_request_count(
    int   current_count,
    logic mcmd_ack,
    MCMD  mcmd,
    logic sresp_ack,
    SRESP sresp
  );
    int next_count  = current_count;

    if (mcmd_ack && is_np_access(mcmd)) begin
      next_count  += 1;
    end
    if (sresp_ack && is_last_response(sresp)) begin
      next_count  -= 1;
    end

    return next_count;
  endfunction

  task wait_for_clock(int cycles);
    repeat (cycles) begin
      @(posedge i_clk);
    end
  endtask

  function bit is_write_access(MCMD mcmd);
    pzcorebus_mcmd_kind mcmd_kind = pzcorebus_mcmd_kind'(mcmd.mcmd);
    return mcmd_kind inside {
      PZCOREBUS_WRITE_COMMAND, PZCOREBUS_FULL_WRITE_COMMAND,
      PZCOREBUS_BROADCAST_COMMAND
    };
  endfunction

  function bit is_np_access(MCMD mcmd);
    return mmcd.mcmd[NON_POSTED_BIT];
  endfunction

  function bit is_last_response(SRESP sresp);
    return IS_CSR || (sresp.sresp == PZCOREBUS_RESPONSE) || sresp.sresp_last[0];
  endfunction

//--------------------------------------------------------------
//  Accept control
//--------------------------------------------------------------
  bit scmd_accept_default     = 1;
  int scmd_accept_max_delay   = 0;
  int scmd_accept_delay       = 0;
  bit sdata_accept_default    = 1;
  int sdata_accept_max_delay  = 0;
  int sdata_accept_delay      = 0;

  always @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      scmd_accept <= scmd_accept_default;
    end
    else if (mcmd_valid) begin
      if (scmd_accept_max_delay > 0) begin
        scmd_accept_delay = $urandom_range(1, scmd_accept_max_delay);
      end
      else begin
        scmd_accept_delay = 0;
      end

      if (scmd_accept_default && (scmd_accept_delay > 0)) begin
        scmd_accept <= '0;
        wait_for_clock(scmd_accept_delay);
        scmd_accept <= '1;
      end
      else if (!scmd_accept_default) begin
        wait_for_clock(scmd_accept_delay);
        scmd_accept <= '1;
        wait_for_clock(1);
        scmd_accept <= '0;
      end
      drive_request_accept(
        1, scmd_accept_default, scmd_accept_max_delay
      );
    end
  end

  always @(posedge i_clk iff IS_MEM, negedge i_rst_n) begin
    if (!i_rst_n) begin
      sdata_accept  <= sdata_accept_default;
    end
    else if (mdata_valid) begin
      if (sdata_accept_max_delay > 0) begin
        sdata_accept_delay  = $urandom_range(1, sdata_accept_max_delay);
      end
      else begin
        sdata_accept_delay  = 0;
      end

      if (sdata_accept_default && (sdata_accept_delay > 0)) begin
        sdata_accept  <= '0;
        wait_for_clock(sdata_accept_delay);
        sdata_accept  <= '1;
      end
      else if (!sdata_accept_default) begin
        wait_for_clock(sdata_accept_delay);
        sdata_accept  <= '1;
        wait_for_clock(1);
        sdata_accept  <= '0;
      end
    end
  end

//--------------------------------------------------------------
//  Memory
//--------------------------------------------------------------
  tb_memory_model #(
    .DATA_WIDTH     (BUS_CONFIG.data_width  ),
    .DATA_TYPE      (pzcorebus_data         ),
    .WORD_SIZE      (SIZE                   ),
    .ADDRESS_WIDTH  (POINTER_WIDTH          )
  ) u_memory();

  MCMD                    write_request_queue[$];
  MDATA                   write_data_queue[$];
  bit                     write_busy;
  bit [POINTER_WIDTH-1:0] write_pointer;

  always @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      write_busy  = 0;
      write_request_queue.delete();
      write_data_queue.delete();
    end
    else begin
      if (mcmd_ack && is_write_access(mcmd)) begin
        write_request_queue.push_back(mcmd);
      end
      if (mdata_ack) begin
        write_data_queue.push_back(mdata);
      end
      update_memory();
    end
  end

  task update_memory();
    while ((write_request_queue.size() > 0) && (IS_CSR || (write_data_queue.size() > 0))) begin
      MDATA write_data;

      if (!write_busy) begin
        write_busy    = 1;
        write_pointer = write_requests[0].maddr[POINTER_LSB+:POINTER_WIDTH];
      end

      if (IS_MEM) begin
        write_data  = write_data_queue.pop_front();
      end
      else begin
        write_data.mdata      = write_request_queue[0].mdata;
        write_data.mdata_last = '1;
        if (BUS_CONFIG.use_byte_enable) begin
          write_data.mdata_byteen = write_request_queue[0].mdata_byteen;
        end
        else begin
          write_data.mdata_byteen = '1;
        end
      end
      put(write_pointer, write_data.mdata, write_data.mdata_byteen, 1);

      if (write_data.mdata_last) begin
        write_busy  = 0;
        void'(write_request_queue.pop_front());
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
    pzcorebus_sresp         sresp;
    pzcorebus_id            sid;
    pzcorebus_data          sdata[$];
    pzcorebus_unit_enable   sresp_uniten[$];

    function new(MCMD mcmd);
      sid = mcmd.mid;
      if (mcmd.mcmd inside {PZCOREBUS_READ, PZCOREBUS_ATOMIC_NP}) begin
        sresp = PZCOREBUS_RESPONSE_WITH_DATA;
      end
      else begin
        sresp = PZCOREBUS_RESPONSE;
      end

      if (sresp == PZCOREBUS_RESPONSE_WITH_DATA) begin
        create_response(mcmd);
      end
    endfunction

    function SRESP get_sresp();
      SRESP response;

      response.sresp        = sresp;
      response.sid          = sid;
      response.serror       = '0;
      response.sdata        = get_response_data();
      response.sinfo        = '0;
      response.sresp_uniten = get_unit_enable();
      response.sresp_last   = get_last();

      return response;
    endfunction

    function void pop();
      if (sdata.size() > 0) begin
        void'(sdata.pop_front());
      end
      if (sresp_uniten.size() > 0) begin
        void'(sresp_uniten.pop_front());
      end
    endfunction

    function bit done();
      return sdata.size() == 0;
    endfunction

    local function void create_response(MCMD request);
      int                     length;
      int                     unit_offset;
      int                     count;
      bit [POINTER_WIDTH-1:0] pointer;

      length      = get_response_length(mcmd);
      unit_offset = get_initial_offset(mcmd);
      count       = 0;
      pointer     = mcmd.maddr[POINTER_LSB+:POINTER_WIDTH];
      while (count < length) begin
        int             remainings;
        int             size;
        pzcorebus_data  data;

        remainings  = length - count;
        size        = calc_response_size(remainings, unit_offset);

        if (mcmd.mcmd == PZCOREBUS_READ) begin
          data  = get(pointer, 1);
        end
        else begin
          void'(std::randomize(data));
        end
        sdata.push_back(data);

        if ((mcmd.mcmd == PZCOREBUS_READ) && (BUS_CONFIG.profile == PZCOREBUS_MEMORY_H)) begin
          pzcorebus_unit_enable enable;
          enable  = ((1 << size) - 1) << unit_offset;
          sresp_uniten.push_back(enable);
        end

        count   += size;
        pointer += 1;
      end
    endfunction

    local function int get_response_length(MCMD mcmd);
      if (mcmd.mcmd != PZCOREBUS_READ) begin
        return BUS_CONFIG.data_size;
      end
      else if (mcmd.mlength != 0) begin
        return mcmd.mlength;
      end
      else begin
        return BUS_CONFIG.max_length;
      end
    endfunction

    local function int get_initial_offset(MCMD mcmd);
      localparam  int OFFSET_LSB    = $clog2(BUS_CONFIG.unit_data_width) - 3;
      localparam  int OFFSET_WIDTH  = (BUS_CONFIG.max_data_size > 1) ? $clog2(BUS_CONFIG.max_data_size) : 1;

      if (BUS_CONFIG.profile != PZCOREBUS_MEMORY_H) begin
        return 0;
      end
      else if (BUS_CONFIG.max_data_size == 1) begin
        return 0;
      end
      else if (mcmd.mcmd != PZCOREBUS_READ) begin
        return 0;
      end
      else begin
        return mcmd.maddr[OFFSET_LSB+:OFFSET_WIDTH];
      end
    endfunction

    local function int calc_response_size(
      int response_size,
      int current_offset
    );
      localparam  int SELECT_WIDTH  = (BUS_CONFIG.data_size > 1) ? $clog2(BUS_CONFIG.data_size) : 1;

      if (BUS_CONFIG.profile != PZCOREBUS_MEMORY_H) begin
        return 1;
      end
      else if (BUS_CONFIG.data_size == 1) begin
        return 1;
      end
      else begin
        int offset;
        int size;

        offset  = SELECT_WIDTH'(current_offset);
        size    = BUS_CONFIG.data_size - offset;
        if (size < remaining_size) begin
          return size;
        end
        else begin
          return remaining_size;
        end
      end
    endfunction

    local function pzcorebus_data get_response_data();
      if (sdata.size() > 0) begin
        return sdata[0];
      end
      else begin
        return '0;
      end
    endfunction

    local function pzcorebus_unit_enable get_unit_enable();
      if (sresp_uniten.size() > 0) begin
        return sresp_uniten[0];
      end
      else begin
        return '0;
      end
    endfunction

    local function logic [1:0] get_last();
      if (sdata.size() > 1) begin
        return 2'b00;
      end
      else if (BUS_CONFIG.profile == PZCOREBUS_MEMORY_H) begin
        return 2'b11;
      end
      else begin
        return 2'b01;
      end
    endfunction
  endclass

  tb_pzcorebus_response response_queue[$];
  int                   response_index  = -1;

  always @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      response_queue.delete();
      response_index  = -1;
    end
    else if (mcmd_ack && is_np_access(mcmd)) begin
      tb_pzcorebus_response response;
      response  = new(mcmd);
      fork
        automatic tb_pzcorebus_response __response  = response;
        consume_start_delay(__response);
      join_none
    end
  end

  task consume_start_delay(tb_pzcorebus_response response);
    fork
      begin
        wait_for_clock(start_delay);
        response_queue.push_back(response);
      end
      @(negedge i_rst_n);
    join_any
    disable fork;
  endtask

  always @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      sresp_valid <= '0;
      response_index  = -1;
    end
    else begin
      if (sresp_ack) begin
        sresp_valid <= '0;
        if (response_index >= 0) begin
          response_queue[response_index].pop();
          if (response_queue[response_index].done()) begin
            response_queue.delete(response_index);
            response_index  = -1;
          end
        end
      end

      if (response_queue.size() > 0) begin
        if (response_index < 0) begin
          if (random_response) begin
            response_index  = $urandom_range(0, (response_queue.size() - 1));
          end
          else begin
            response_index  = 0;
          end
        end

        sresp_valid <= '1;
        sresp       <= response_queue[response_index].get_sresp();
      end
    end
  end

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

    for (int i = 0;i < BYTE_WIDTH;++i) begin
      mask[8*i+:8]  = {8{byte_enable[i]}};
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
