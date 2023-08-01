//========================================
//
// Copyright (c) 2023 PEZY Computing, K.K.
//                    All Rights Reserved.
//
//========================================
interface tb_memory_model
  import  pztb_pkg::*;
#(
  parameter   int     DATA_WIDTH    = 32,
  parameter   type    DATA_TYPE     = logic [DATA_WIDTH-1:0],
  parameter   longint WORD_SIZE     = 1024,
  parameter   int     ADDRESS_WIDTH = $clog2(WORD_SIZE),
  parameter   int     KEY_LSB       = 0,
  localparam  type    ADDRESS_TYPE  = logic [ADDRESS_WIDTH-1:0]
);
  localparam  longint KEY_WIDTH = ADDRESS_WIDTH - KEY_LSB;
  localparam  type    KEY_TYPE  = logic [KEY_WIDTH-1:0];

  DATA_TYPE memory[KEY_TYPE];

  function automatic KEY_TYPE get_key(ADDRESS_TYPE address);
    return address[KEY_LSB+:KEY_WIDTH];
  endfunction

  function automatic DATA_TYPE get(ADDRESS_TYPE address);
    KEY_TYPE  key = get_key(address);
    if (memory.exists(key)) begin
      return memory[key];
    end
    else begin
      return get_default_data();
    end
  endfunction

  function automatic void put(ADDRESS_TYPE address, DATA_TYPE data, DATA_TYPE bit_mask = '1);
    KEY_TYPE  key           = get_key(address);
    DATA_TYPE current_data  = get(address);
    memory[key] = (data & bit_mask) | (current_data & (~bit_mask));
  endfunction

  function automatic void nb_put(ADDRESS_TYPE address, DATA_TYPE data, DATA_TYPE bit_mask = '1);
    KEY_TYPE  key           = get_key(address);
    DATA_TYPE current_data  = get(address);
    memory[key] <= (data & bit_mask) | (current_data & (~bit_mask));
  endfunction

  pztb_mem_init default_value = PZTB_MEM_INIT_X;

  function automatic DATA_TYPE get_default_data();
    DATA_TYPE data;
    case (default_value)
      PZTB_MEM_INIT_X:      data = 'x;
      PZTB_MEM_INIT_0:      data = '0;
      PZTB_MEM_INIT_1:      data = '1;
      PZTB_MEM_INIT_RANDOM: void'(std::randomize(data));
    endcase
    return data;
  endfunction

  function automatic void initialize(pztb_mem_init initial_value);
    default_value = initial_value;
    for (int i = 0;i < WORD_SIZE;++i) begin
      put(i << KEY_LSB, get_default_data());
    end
  endfunction

  function automatic void load(
    ref   DATA_TYPE data[KEY_TYPE],
    input KEY_TYPE  start_key = 0
  );
    foreach (data[i]) begin
      memory[start_key+i] = data[i];
    end
  endfunction

  function automatic void load_from_file(string  filename);
    DATA_TYPE data[KEY_TYPE];
    $readmemh(filename, data);
    load(data);
  endfunction

  function automatic void dump(
    ref   DATA_TYPE   data[KEY_TYPE],
    input KEY_TYPE    start_key = 0
  );
    foreach (memory[i]) begin
      if (i >= start_key) begin
        data[i] = memory[i];
      end
    end
  endfunction

  function automatic void dump_to_file(string filename);
    DATA_TYPE data[KEY_TYPE];
    dump(data);
    $writememh(filename, data);
  endfunction
endinterface
