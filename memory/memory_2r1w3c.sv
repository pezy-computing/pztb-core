//========================================
//
// Copyright (c) 2023 PEZY Computing, K.K.
//                    All Rights Reserved.
//
//========================================
interface memory_2r1w3c
  import  pztb_pkg::*;
#(
  parameter   int   DATAW = 32,
  parameter   type  DATAT = logic [DATAW-1:0],
  parameter   int   WORDW = 1024,
  parameter   int   ADDRW = $clog2(WORDW),
  localparam  type  ADDRT = logic [ADDRW-1:0]
)(
  output  var DATAT qb,
  output  var DATAT qc,
  input   var ADDRT adra,
  input   var DATAT da,
  input   var DATAT wema,
  input   var       wea,
  input   var       mea,
  input   var       clka,
  input   var ADDRT adrb,
  input   var       meb,
  input   var       clkb,
  input   var ADDRT adrc,
  input   var       mec,
  input   var       clkc
);
  tb_memory #(
    .DATA_WIDTH    (DATAW),
    .DATA_TYPE     (DATAT),
    .WORD_SIZE     (WORDW),
    .ADDRESS_WIDTH (ADDRW)
  ) u_memory (
    .clka (clka),
    .wea  (wea ),
    .mea  (mea ),
    .adra (adra),
    .da   (da  ),
    .wema (wema),
    .qa   (    ),
    .clkb (clkb),
    .web  ('0  ),
    .meb  (meb ),
    .adrb (adrb),
    .db   ('0  ),
    .wemb ('0  ),
    .qb   (qb  ),
    .clkc (clkc),
    .wec  ('0  ),
    .mec  (mec ),
    .adrc (adrc),
    .dc   ('0  ),
    .wemc ('0  ),
    .qc   (qc  )
  );

  initial begin
    u_memory.memory_type  = "memory_2r1w3c";
  end

  function automatic DATAT get(ADDRT address);
    return u_memory.get(address);
  endfunction

  function automatic void put(ADDRT address, DATAT data);
    u_memory.put(address, data);
  endfunction

  function automatic void initialize(pztb_mem_init initial_value);
    u_memory.initialize(initial_value);
  endfunction

  function automatic void load(
    ref   DATAT data[ADDRT],
    input ADDRT start_address = 0
  );
    u_memory.load(data, start_address);
  endfunction

  function automatic void load_from_file(string filename);
    u_memory.load_from_file(filename);
  endfunction

  function automatic void dump(
    ref   DATAT data[ADDRT],
    input ADDRT start_address = 0
  );
    u_memory.dump(data, start_address);
  endfunction

  function automatic void dump_to_file(string filename);
    u_memory.dump_to_file(filename);
  endfunction
endinterface
