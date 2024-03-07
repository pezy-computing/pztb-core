//========================================
//
// Copyright (c) 2023 PEZY Computing, K.K.
//                    All Rights Reserved.
//
//========================================
`ifndef PZVIP_COREBUS_TYPES_PKG_SV
`define PZVIP_COREBUS_TYPES_PKG_SV
package pzvip_corebus_types_pkg;
  typedef enum {
    PZVIP_COREBUS_CSR,
    PZVIP_COREBUS_MEMORY_L,
    PZVIP_COREBUS_MEMORY_H
  } pzvip_corebus_profile;

  typedef enum bit [3:0] {
    PZVIP_COREBUS_NULL                  = 4'b0_000,
    PZVIP_COREBUS_READ                  = 4'b1_001,
    PZVIP_COREBUS_WRITE                 = 4'b0_100,
    PZVIP_COREBUS_WRITE_NON_POSTED      = 4'b1_100,
    PZVIP_COREBUS_FULL_WRITE            = 4'b0_101,
    PZVIP_COREBUS_FULL_WRITE_NON_POSTED = 4'b1_101,
    PZVIP_COREBUS_BROADCAST             = 4'b0_110,
    PZVIP_COREBUS_BROADCAST_NON_POSTED  = 4'b1_110,
    PZVIP_COREBUS_ATOMIC                = 4'b0_111,
    PZVIP_COREBUS_ATOMIC_NON_POSTED     = 4'b1_111,
    PZVIP_COREBUS_MESSAGE               = 4'b0_010,
    PZVIP_COREBUS_MESSAGE_NON_POSTED    = 4'b1_010
  } pzvip_corebus_command_type;

  localparam  int PZVIP_COREBUS_COMMAND_DATA_BIT        = 2;
  localparam  int PZVIP_COREBUS_COMMAND_NON_POSTED_BIT  = PZVIP_COREBUS_COMMAND_DATA_BIT + 1;

  typedef enum bit {
    PZVIP_COREBUS_RESPONSE            = 1'b0,
    PZVIP_COREBUS_RESPONSE_WITH_DATA  = 1'b1
  } pzvip_corebus_response_type;

  `ifndef PZVIP_COREBUS_MAX_ID_WIDTH
    `define PZVIP_COREBUS_MAX_ID_WIDTH  20
  `endif

  `ifndef PZVIP_COREBUS_MAX_ADDRESS_WIDTH
    `define PZVIP_COREBUS_MAX_ADDRESS_WIDTH 64
  `endif

  `ifndef PZVIP_COREBUS_MAX_LENGTH
    `define PZVIP_COREBUS_MAX_LENGTH  1024
  `endif

  `ifndef PZVIP_COREBUS_MAX_LENGTH_WIDTH
    `define PZVIP_COREBUS_MAX_LENGTH_WIDTH \
      ((`PZVIP_COREBUS_MAX_LENGTH == 1) ? 1 : $clog2(`PZVIP_COREBUS_MAX_LENGTH))
  `endif

  `ifndef PZVIP_COREBUS_MAX_ATOMIC_COMMAND_WIDTH
    `define PZVIP_COREBUS_MAX_ATOMIC_COMMAND_WIDTH  8
  `endif

  `ifndef PZVIP_COREBUS_MAX_MESSAGE_CODE_WIDTH
    `define PZVIP_COREBUS_MAX_MESSAGE_CODE_WIDTH  1
  `endif

  `ifndef PZVIP_COREBUS_MAX_REQUEST_PARAM_INFO
    `define PZVIP_COREBUS_MAX_REQUEST_PARAM_INFO \
      ((`PZVIP_COREBUS_MAX_ATOMIC_COMMAND_WIDTH > `PZVIP_COREBUS_MAX_MESSAGE_CODE_WIDTH) ? \
        `PZVIP_COREBUS_MAX_ATOMIC_COMMAND_WIDTH : `PZVIP_COREBUS_MAX_MESSAGE_CODE_WIDTH)
  `endif

  `ifndef PZVIP_COREBUS_MAX_REQUEST_INFO_WIDTH
    `define PZVIP_COREBUS_MAX_REQUEST_INFO_WIDTH  32
  `endif

  `ifndef PZVIP_COREBUS_MAX_RESPONSE_INFO_WIDTH
    `define PZVIP_COREBUS_MAX_RESPONSE_INFO_WIDTH 32
  `endif

  `ifndef PZVIP_COREBUS_MIN_DATA_WIDTH
    `define PZVIP_COREBUS_MIN_DATA_WIDTH  32
  `endif

  `ifndef PZVIP_COREBUS_MAX_DATA_WIDTH
    `define PZVIP_COREBUS_MAX_DATA_WIDTH  512
  `endif

  `ifndef PZVIP_COREBUS_MAX_BYTE_ENABLE_WIDTH
    `define PZVIP_COREBUS_MAX_BYTE_ENABLE_WIDTH \
    (`PZVIP_COREBUS_MAX_DATA_WIDTH / 8)
  `endif

  `ifndef PZVIP_COREBUS_MAX_UNIT_ENABLE_WIDTH
    `define PZVIP_COREBUS_MAX_UNIT_ENABLE_WIDTH \
    (`PZVIP_COREBUS_MAX_DATA_WIDTH / `PZVIP_COREBUS_MIN_DATA_WIDTH)
  `endif

  typedef bit [`PZVIP_COREBUS_MAX_ID_WIDTH-1:0]             pzvip_corebus_id;
  typedef bit [`PZVIP_COREBUS_MAX_ADDRESS_WIDTH-1:0]        pzvip_corebus_address;
  typedef bit [`PZVIP_COREBUS_MAX_LENGTH_WIDTH-1:0]         pzvip_corebus_length;
  typedef bit [`PZVIP_COREBUS_MAX_ATOMIC_COMMAND_WIDTH-1:0] pzvip_corebus_atomic_command;
  typedef bit [`PZVIP_COREBUS_MAX_MESSAGE_CODE_WIDTH-1:0]   pzvip_corebus_message_code;
  typedef bit [`PZVIP_COREBUS_MAX_REQUEST_PARAM_INFO-1:0]   pzvip_corebus_request_param;
  typedef bit [`PZVIP_COREBUS_MAX_REQUEST_INFO_WIDTH-1:0]   pzvip_corebus_request_info;
  typedef bit [`PZVIP_COREBUS_MAX_DATA_WIDTH-1:0]           pzvip_corebus_data;
  typedef bit [`PZVIP_COREBUS_MAX_BYTE_ENABLE_WIDTH-1:0]    pzvip_corebus_byte_enable;
  typedef bit [`PZVIP_COREBUS_MAX_UNIT_ENABLE_WIDTH-1:0]    pzvip_corebus_unit_enable;
  typedef bit [`PZVIP_COREBUS_MAX_RESPONSE_INFO_WIDTH-1:0]  pzvip_corebus_response_info;
  typedef bit [1:0]                                         pzvip_corebus_response_last;

  typedef struct {
    time                          begin_time;
    pzvip_corebus_command_type    command;
    pzvip_corebus_id              id;
    pzvip_corebus_address         address;
    int                           length;
    pzvip_corebus_atomic_command  atomic_command;
    pzvip_corebus_message_code    message_code;
    pzvip_corebus_request_info    info;
    pzvip_corebus_data            data;
    pzvip_corebus_byte_enable     byte_enable;
  } pzvip_corebus_command_item;

  typedef struct {
    time                      begin_time;
    pzvip_corebus_data        data;
    pzvip_corebus_byte_enable byte_enable;
    bit                       last;
  } pzvip_corebus_request_data_item;

  typedef struct {
    time                        begin_time;
    pzvip_corebus_response_type response_type;
    pzvip_corebus_id            id;
    bit                         error;
    pzvip_corebus_data          data;
    pzvip_corebus_response_info info;
    pzvip_corebus_response_last last;
  } pzvip_corebus_response_item;
endpackage
`endif
