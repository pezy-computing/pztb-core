//========================================
//
// Copyright (c) 2023 PEZY Computing, K.K.
//                    All Rights Reserved.
//
//========================================
interface tb_memory
  import  pztb_pkg::*;
#(
  parameter   int   DATA_WIDTH    = 32,
  parameter   type  DATA_TYPE     = logic [DATA_WIDTH-1:0],
  parameter   int   WORD_SIZE     = 1024,
  parameter   int   ADDRESS_WIDTH = $clog2(WORD_SIZE),
  parameter   int   KEY_LSB       = 0,
  localparam  type  ADDRESS_TYPE  = logic [ADDRESS_WIDTH-1:0]
)(
  input   var               clka,
  input   var               wea,
  input   var               mea,
  input   var ADDRESS_TYPE  adra,
  input   var DATA_TYPE     da,
  input   var DATA_TYPE     wema,
  output  var DATA_TYPE     qa,
  input   var               clkb,
  input   var               web,
  input   var               meb,
  input   var ADDRESS_TYPE  adrb,
  input   var DATA_TYPE     db,
  input   var DATA_TYPE     wemb,
  output  var DATA_TYPE     qb,
  input   var               clkc,
  input   var               wec,
  input   var               mec,
  input   var ADDRESS_TYPE  adrc,
  input   var DATA_TYPE     dc,
  input   var DATA_TYPE     wemc,
  output  var DATA_TYPE     qc
);
  localparam  int   KEY_WIDTH = ADDRESS_WIDTH - KEY_LSB;
  localparam  type  KEY_TYPE  = logic [KEY_WIDTH-1:0];

  tb_memory_model #(
    .DATA_WIDTH     (DATA_WIDTH     ),
    .DATA_TYPE      (DATA_TYPE      ),
    .WORD_SIZE      (WORD_SIZE      ),
    .ADDRESS_WIDTH  (ADDRESS_WIDTH  ),
    .KEY_LSB        (KEY_LSB        )
  ) u_memory_model ();

  always @(posedge clka) begin
    if (wea && mea) begin
      nb_put(adra, da, wema);
    end
  end

  always @(posedge clkb) begin
    if (web && meb) begin
      nb_put(adrb, db, wemb);
    end
  end

  always @(posedge clkc) begin
    if (wec && mec) begin
      nb_put(adrc, dc, wemc);
    end
  end

  always @(posedge clka) begin
    if (mea) begin
      qa <= get(adra);
    end
  end

  always @(posedge clkb) begin
    if (meb) begin
      qb <= get(adrb);
    end
  end

  always @(posedge clkc) begin
    if (mec) begin
      qc <= get(adrc);
    end
  end

  function automatic DATA_TYPE get(ADDRESS_TYPE address);
    return u_memory_model.get(address);
  endfunction

  function automatic void put(ADDRESS_TYPE address, DATA_TYPE data, DATA_TYPE bit_mask = '1);
    u_memory_model.put(address, data, bit_mask);
  endfunction

  function automatic void nb_put(ADDRESS_TYPE address, DATA_TYPE data, DATA_TYPE bit_mask = '1);
    u_memory_model.nb_put(address, data, bit_mask);
  endfunction

  function automatic void initialize(pztb_mem_init initial_value);
    u_memory_model.initialize(initial_value);
  endfunction

  function automatic void load(
    ref   DATA_TYPE data[KEY_TYPE],
    input KEY_TYPE  start_key = 0
  );
    u_memory_model.load(data, start_key);
  endfunction

  function automatic void load_from_file(string  filename);
    u_memory_model.load_from_file(filename);
  endfunction

  function automatic void dump(
    ref   DATA_TYPE   data[KEY_TYPE],
    input KEY_TYPE    start_key = 0
  );
    u_memory_model.dump(data, start_key);
  endfunction

  function automatic void dump_to_file(string filename);
    u_memory_model.dump_to_file(filename);
  endfunction

  property p_write_and_read_address_should_differ_clka;
    @(posedge clka)
    (((mea && meb) |-> (adra != adrb)) and ((mea && mec) |-> (adra != adrc)) and ((meb && mec) |-> (adrb != adrc)));
  endproperty

  property p_write_and_read_address_should_differ_clkb;
    @(posedge clkb)
    (((mea && meb) |-> (adra != adrb)) and ((mea && mec) |-> (adra != adrc)) and ((meb && mec) |-> (adrb != adrc)));
  endproperty

  property p_write_and_read_address_should_differ_clkc;
    @(posedge clkc)
    (((mea && meb) |-> (adra != adrb)) and ((mea && mec) |-> (adra != adrc)) and ((meb && mec) |-> (adrb != adrc)));
  endproperty

`ifdef _PZ_UVM_
  import    uvm_pkg::*;
  `include  "uvm_macros.svh"

  function automatic void handle_error(string memory_type);
    `uvm_error(
      "MEMCOLLISION",
      $sformatf(
        {
          "%s same address access error !!!\n",
          "module :%m"
        },
        memory_type
      )
    )
  endfunction
`else
  function void handle_error(string memory_type);
    $display("=========================================");
    $display("%s same address access error!!!", memory_type);
    $display("sim time %t", $time);
    $display("module %m");
    $display("=========================================");
    $stop();
  endfunction
`endif

  localparam  bit ENABLE_COLLISION_CHECK  =
    `ifndef _PZ_DISABLE_MEM_COLLISION_CHECK_ 1 `else 0 `endif;

  string  memory_type = "tb_memory";
  if (ENABLE_COLLISION_CHECK) begin : g_address_collision_check
    asm_write_and_read_address_should_differ_clka:
    assume property(p_write_and_read_address_should_differ_clka)
    else handle_error(memory_type);
    asm_write_and_read_address_should_differ_clkb:
    assume property(p_write_and_read_address_should_differ_clkb)
    else handle_error(memory_type);
    asm_write_and_read_address_should_differ_clkc:
    assume property(p_write_and_read_address_should_differ_clkc)
    else handle_error(memory_type);
  end

  localparam  bit ENABLE_MEMORY_INITIALIZATION  =
    `ifdef _PZ_ENABLE_MEM_INIT_ 1 `else 0 `endif;

  localparam  pztb_mem_init MEMORY_INITIALE_VALUE =
    `ifdef _PZ_ENABLE_MEM_INIT_ `_PZ_ENABLE_MEM_INIT_ `else PZTB_MEM_INIT_X `endif;

  if (ENABLE_MEMORY_INITIALIZATION) begin : g_memory_initialization
    initial begin
      initialize(MEMORY_INITIALE_VALUE);
    end
  end
endinterface
