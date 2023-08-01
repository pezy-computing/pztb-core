//========================================
//
// Copyright (c) 2023 PEZY Computing, K.K.
//                    All Rights Reserved.
//
//========================================
`ifndef PZVIP_TILELINK_TYPES_PKG_SV
`define PZVIP_TILELINK_TYPES_PKG_SV
package pzvip_tilelink_types_pkg;
  `include  "pzvip_tilelink_defines.svh"

  typedef enum {
    PZVIP_TILELINK_MASTER_PORT,
    PZVIP_TILELINK_SLAVE_PORT
  } pzvip_tilelink_port_type;

  typedef enum {
    PZVIP_TILELINK_TL_UL,
    PZVIP_TILELINK_TL_UH,
    PZVIP_TILELINK_TL_C
  } pzvip_tilelink_conformance_level;

  typedef enum {
    PZVIP_TILELINK_GET,
    PZVIP_TILELINK_PUT_FULL_DATA,
    PZVIP_TILELINK_PUT_PARTIAL_DATA,
    PZVIP_TILELINK_ACCESS_ACK,
    PZVIP_TILELINK_ACCESS_ACK_DATA,
    PZVIP_TILELINK_ARITHMETIC_DATA,
    PZVIP_TILELINK_LOGICAL_DATA,
    PZVIP_TILELINK_HINT,
    PZVIP_TILELINK_HINT_ACK,
    PZVIP_TILELINK_ACQUIRE_BLOCK,
    PZVIP_TILELINK_ACQUIRE_PERM,
    PZVIP_TILELINK_PROBE,
    PZVIP_TILELINK_PROBE_ACK,
    PZVIP_TILELINK_PROBE_ACK_DATA,
    PZVIP_TILELINK_GRANT,
    PZVIP_TILELINK_GRANT_DATA,
    PZVIP_TILELINK_GRANT_ACK,
    PZVIP_TILELINK_RELEASE,
    PZVIP_TILELINK_RELEASE_DATA,
    PZVIP_TILELINK_RELEASE_ACK
  } pzvip_tilelink_opcode;

  typedef enum {
    PZVIP_TILELINK_MIN,
    PZVIP_TILELINK_MAX,
    PZVIP_TILELINK_MINU,
    PZVIP_TILELINK_MAXU,
    PZVIP_TILELINK_ADD,
    PZVIP_TILELINK_XOR,
    PZVIP_TILELINK_OR,
    PZVIP_TILELINK_AND,
    PZVIP_TILELINK_SWAP
  } pzvip_tilelink_atomic_operation;

  typedef enum {
    PZVIP_TILELINK_PREFETCH_READ,
    PZVIP_TILELINK_PREFETCH_WRITE
  } pzvip_tilelink_hint;

  typedef enum {
    //  Cap
    PZVIP_TILELINK_TO_T,
    PZVIP_TILELINK_TO_B,
    PZVIP_TILELINK_TO_N,
    //  Grow
    PZVIP_TILELINK_N_TO_B,
    PZVIP_TILELINK_N_TO_T,
    PZVIP_TILELINK_B_TO_T,
    //  Shrink
    PZVIP_TILELINK_T_TO_B,
    PZVIP_TILELINK_T_TO_N,
    PZVIP_TILELINK_B_TO_N,
    //  Report
    PZVIP_TILELINK_T_TO_T,
    PZVIP_TILELINK_B_TO_B,
    PZVIP_TILELINK_N_TO_N
  } pzvip_tilelink_permission_transfer;

  typedef enum logic [2:0] {
    PZVIP_TILELINK_A_PUT_FULL_DATA    = 0,
    PZVIP_TILELINK_A_PUT_PARTIAL_DATA = 1,
    PZVIP_TILELINK_A_ARITHMETIC_DATA  = 2,
    PZVIP_TILELINK_A_LOGICAL_DATA     = 3,
    PZVIP_TILELINK_A_GET              = 4,
    PZVIP_TILELINK_A_HINT             = 5,
    PZVIP_TILELINK_A_ACQUIRE_BLOCK    = 6,
    PZVIP_TILELINK_A_ACQUIRE_PERM     = 7
  } pzvip_tilelink_a_opcode;

  typedef enum logic [2:0] {
    PZVIP_TILELINK_B_PUT_FULL_DATA    = 0,
    PZVIP_TILELINK_B_PUT_PARTIAL_DATA = 1,
    PZVIP_TILELINK_B_ARITHMETIC_DATA  = 2,
    PZVIP_TILELINK_B_LOGICAL_DATA     = 3,
    PZVIP_TILELINK_B_GET              = 4,
    PZVIP_TILELINK_B_HINT             = 5,
    PZVIP_TILELINK_B_PROBE            = 6
  } pzvip_tilelink_b_opcode;

  typedef enum logic [2:0] {
    PZVIP_TILELINK_C_ACCESS_ACK       = 0,
    PZVIP_TILELINK_C_ACCESS_ACK_DATA  = 1,
    PZVIP_TILELINK_C_HINT_ACK         = 2,
    PZVIP_TILELINK_C_PROBE_ACK        = 4,
    PZVIP_TILELINK_C_PROBE_ACK_DATA   = 5,
    PZVIP_TILELINK_C_RELEASE          = 6,
    PZVIP_TILELINK_C_RELEASE_DATA     = 7
  } pzvip_tilelink_c_opcode;

  typedef enum logic [2:0] {
    PZVIP_TILELINK_D_ACCESS_ACK       = 0,
    PZVIP_TILELINK_D_ACCESS_ACK_DATA  = 1,
    PZVIP_TILELINK_D_HINT_ACK         = 2,
    PZVIP_TILELINK_D_GRANT            = 4,
    PZVIP_TILELINK_D_GRANT_DATA       = 5,
    PZVIP_TILELINK_D_RELEASE_ACK      = 6
  } pzvip_tilelink_d_opcode;

  typedef logic [2:0] pzvip_tilelink_param;

  typedef logic [`PZVIP_TILELINK_MAX_DATA_WIDTH-1:0]    pzvip_tilelink_data;
  typedef logic [`PZVIP_TILELINK_MAX_DATA_WIDTH/8-1:0]  pzvip_tilelink_mask;

  typedef logic [`PZVIP_TILELINK_MAX_ADDRESS_WIDTH-1:0] pzvip_tilelink_address;

  localparam  int PZVIP_TILELINK_SIZE_WIDTH = $clog2($clog2(`PZVIP_TILELINK_MAX_SIZE));
  typedef logic [PZVIP_TILELINK_SIZE_WIDTH-1:0] pzvip_tilelink_size;

  typedef logic [`PZVIP_TILELINK_MAX_ID_WIDTH-1:0]  pzvip_tilelink_id;
  typedef pzvip_tilelink_id                         pzvip_tilelink_source;
  typedef pzvip_tilelink_id                         pzvip_tilelink_sink;

  typedef struct {
    pzvip_tilelink_a_opcode opcode;
    pzvip_tilelink_param    param;
    pzvip_tilelink_size     size;
    pzvip_tilelink_source   source;
    pzvip_tilelink_address  address;
    pzvip_tilelink_mask     mask;
    pzvip_tilelink_data     data;
    logic                   corrupt;
  } pzvip_tilelink_a_payload;

  typedef struct {
    pzvip_tilelink_b_opcode opcode;
    pzvip_tilelink_param    param;
    pzvip_tilelink_size     size;
    pzvip_tilelink_source   source;
    pzvip_tilelink_address  address;
    pzvip_tilelink_mask     mask;
    pzvip_tilelink_data     data;
    logic                   corrupt;
  } pzvip_tilelink_b_payload;

  typedef struct {
    pzvip_tilelink_c_opcode opcode;
    pzvip_tilelink_param    param;
    pzvip_tilelink_size     size;
    pzvip_tilelink_source   source;
    pzvip_tilelink_address  address;
    pzvip_tilelink_data     data;
    logic                   corrupt;
  } pzvip_tilelink_c_payload;

  typedef struct {
    pzvip_tilelink_d_opcode opcode;
    pzvip_tilelink_param    param;
    pzvip_tilelink_size     size;
    pzvip_tilelink_source   source;
    pzvip_tilelink_sink     sink;
    pzvip_tilelink_data     data;
    logic                   corrupt;
    logic                   denied;
  } pzvip_tilelink_d_payload;

  typedef struct {
    pzvip_tilelink_sink sink;
  } pzvip_tilelink_e_payload;

  function automatic bit is_opcode_having_data(pzvip_tilelink_opcode opcode);
    if (opcode inside {
      PZVIP_TILELINK_PUT_FULL_DATA,
      PZVIP_TILELINK_PUT_PARTIAL_DATA,
      PZVIP_TILELINK_ACCESS_ACK_DATA,
      PZVIP_TILELINK_ARITHMETIC_DATA,
      PZVIP_TILELINK_LOGICAL_DATA,
      PZVIP_TILELINK_PROBE_ACK_DATA,
      PZVIP_TILELINK_GRANT_DATA,
      PZVIP_TILELINK_RELEASE_DATA
    }) begin
      return 1;
    end
    else begin
      return 0;
    end
  endfunction

  function automatic bit is_response_opcode(pzvip_tilelink_opcode opcode);
    if (opcode inside {
      PZVIP_TILELINK_ACCESS_ACK,
      PZVIP_TILELINK_ACCESS_ACK_DATA,
      PZVIP_TILELINK_HINT_ACK,
      PZVIP_TILELINK_PROBE_ACK,
      PZVIP_TILELINK_PROBE_ACK_DATA,
      PZVIP_TILELINK_GRANT,
      PZVIP_TILELINK_GRANT_DATA,
      PZVIP_TILELINK_GRANT_ACK,
      PZVIP_TILELINK_RELEASE_ACK
    }) begin
      return 1;
    end
    else begin
      return 0;
    end
  endfunction
endpackage
`endif
