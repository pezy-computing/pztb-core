//========================================
//
// Copyright (c) 2023 PEZY Computing, K.K.
//                    All Rights Reserved.
//
//========================================
interface memory_1rw1c
  import  pztb_pkg::*;
#(
  parameter   int   DATAW = 32,
  parameter   type  DATAT = logic [DATAW-1:0],
  parameter   int   WORDW = 1024,
  parameter   int   ADDRW = $clog2(WORDW),
  localparam  type  ADDRT = logic [ADDRW-1:0]
)(
  input   var       clk,
  input   var       me,
  input   var       we,
  input   var DATAT wem,
  input   var DATAT d,
  input   var ADDRT adr,
  output  var DATAT q
);
  logic mea;
  logic meb;

  assign  mea = (me &&   we ) ? '1 : '0;
  assign  meb = (me && (!we)) ? '1 : '0;

  tb_memory #(
    .DATA_WIDTH    (DATAW),
    .DATA_TYPE     (DATAT),
    .WORD_SIZE     (WORDW),
    .ADDRESS_WIDTH (ADDRW)
  ) u_memory (
    .clka (clk),
    .wea  (we ),
    .mea  (mea),
    .adra (adr),
    .da   (d  ),
    .wema (wem),
    .qa   (   ),
    .clkb (clk),
    .web  ('0 ),
    .meb  (meb),
    .adrb (adr),
    .db   ('0 ),
    .wemb ('0 ),
    .qb   (q  ),
    .clkc ('0 ),
    .wec  ('0 ),
    .mec  ('0 ),
    .adrc ('0 ),
    .dc   ('0 ),
    .wemc ('0 ),
    .qc   (   )
  );

  initial begin
    u_memory.memory_type  = "memory_1rw1c";
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
