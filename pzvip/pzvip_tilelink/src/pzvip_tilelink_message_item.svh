`ifndef PZVIP_TILELINK_MESSAGE_ITEM_SVH
`define PZVIP_TILELINK_MESSAGE_ITEM_SVH
class pzvip_tilelink_message_item extends tue_sequence_item #(
  .CONFIGURATION  (pzvip_tilelink_configuration ),
  .STATUS         (pzvip_tilelink_status        )
);
  //  Opcode
  rand  pzvip_tilelink_opcode               opcode;
  //  Routing
  rand  pzvip_tilelink_source               source;
  rand  pzvip_tilelink_sink                 sink;
  rand  pzvip_tilelink_address              address;
  //  Write/Read data
  rand  int                                 size;
  rand  pzvip_tilelink_mask                 mask[];
  rand  pzvip_tilelink_data                 data[];
  //  Error Status
  rand  bit                                 corrupt;
  rand  bit                                 denied;
  //  Additional parameter
  rand  pzvip_tilelink_atomic_operation     atomic_operation;
  rand  pzvip_tilelink_hint                 hint;
  rand  pzvip_tilelink_permission_transfer  permission_transfer;
  //  Delay configuration
  rand  int                                 gap_delay[];
  rand  int                                 ready_delay[];
  rand  int                                 response_start_delay;
  rand  bit                                 enable_early_response;
        pzvip_tilelink_message_item         related_request;

  function new(string name = "pzvip_tilelink_message_item");
    super.new(name);
    opcode                = pzvip_tilelink_opcode'(0);
    source                = 0;
    sink                  = 0;
    address               = 0;
    size                  = 0;
    corrupt               = 0;
    denied                = 0;
    atomic_operation      = pzvip_tilelink_atomic_operation'(0);
    hint                  = pzvip_tilelink_hint'(0);
    permission_transfer   = pzvip_tilelink_permission_transfer'(0);
    response_start_delay  = 0;
    enable_early_response = 0;
  endfunction

  function int number_of_beats();
    return get_number_of_beats(size, configuration.byte_width);
  endfunction

  function bit has_data();
    return is_opcode_having_data(opcode);
  endfunction

  function bit is_request();
    return (!is_response_opcode(opcode)) ? 1 : 0;
  endfunction

  function bit is_response();
    return is_response_opcode(opcode);
  endfunction

  `uvm_object_utils_begin(pzvip_tilelink_message_item)
    `uvm_field_enum(pzvip_tilelink_opcode, opcode, UVM_DEFAULT)
    `uvm_field_int(source, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(sink, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(address, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(size, UVM_DEFAULT | UVM_DEC)
    `uvm_field_array_int(mask, UVM_DEFAULT | UVM_HEX)
    `uvm_field_array_int(data, UVM_DEFAULT | UVM_HEX)
    `uvm_field_enum(pzvip_tilelink_atomic_operation, atomic_operation, UVM_DEFAULT)
    `uvm_field_enum(pzvip_tilelink_hint, hint, UVM_DEFAULT)
    `uvm_field_enum(pzvip_tilelink_permission_transfer, permission_transfer, UVM_DEFAULT)
    `uvm_field_array_int(gap_delay, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
    `uvm_field_array_int(ready_delay, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
    `uvm_field_int(response_start_delay, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
    `uvm_field_int(enable_early_response, UVM_DEFAULT | UVM_BIN | UVM_NOCOMPARE)
    `uvm_field_object(related_request, UVM_REFERENCE)
  `uvm_object_utils_end
endclass

class pzvip_tilelink_sender_message_item extends pzvip_tilelink_message_item;
  constraint c_valid_opcode {
    if (related_request == null) {
      opcode inside {
        PZVIP_TILELINK_GET,
        PZVIP_TILELINK_PUT_FULL_DATA,
        PZVIP_TILELINK_PUT_PARTIAL_DATA,
        PZVIP_TILELINK_ARITHMETIC_DATA,
        PZVIP_TILELINK_LOGICAL_DATA,
        PZVIP_TILELINK_HINT,
        PZVIP_TILELINK_ACQUIRE_BLOCK,
        PZVIP_TILELINK_ACQUIRE_PERM,
        PZVIP_TILELINK_PROBE,
        PZVIP_TILELINK_RELEASE,
        PZVIP_TILELINK_RELEASE_DATA
      };
    }
    else if (related_request.opcode == PZVIP_TILELINK_GET) {
      opcode == PZVIP_TILELINK_ACCESS_ACK_DATA;
    }
    else if (related_request.opcode inside {
      PZVIP_TILELINK_PUT_FULL_DATA,
      PZVIP_TILELINK_PUT_PARTIAL_DATA
    }) {
      opcode == PZVIP_TILELINK_ACCESS_ACK;
    }
    else if (related_request.opcode inside {
      PZVIP_TILELINK_ARITHMETIC_DATA,
      PZVIP_TILELINK_LOGICAL_DATA
    }) {
      opcode == PZVIP_TILELINK_ACCESS_ACK_DATA;
    }
    else if (related_request.opcode == PZVIP_TILELINK_HINT) {
      opcode == PZVIP_TILELINK_HINT_ACK;
    }
    else if (related_request.opcode == PZVIP_TILELINK_ACQUIRE_BLOCK) {
      opcode inside {PZVIP_TILELINK_GRANT, PZVIP_TILELINK_GRANT_DATA};
    }
    else if (related_request.opcode == PZVIP_TILELINK_ACQUIRE_PERM) {
      opcode == PZVIP_TILELINK_GRANT;
    }
    else if (related_request.opcode inside {
      PZVIP_TILELINK_GRANT,
      PZVIP_TILELINK_GRANT_DATA
    }) {
      opcode == PZVIP_TILELINK_GRANT_ACK;
    }
    else if (related_request.opcode == PZVIP_TILELINK_PROBE) {
      opcode inside {PZVIP_TILELINK_PROBE_ACK, PZVIP_TILELINK_PROBE_ACK_DATA};
    }
    else if (related_request.opcode inside {
      PZVIP_TILELINK_RELEASE,
      PZVIP_TILELINK_RELEASE_DATA
    }) {
      opcode == PZVIP_TILELINK_RELEASE_ACK;
    }
  }

  constraint c_valid_source {
    solve opcode before source;
    if (opcode inside {
      PZVIP_TILELINK_GET,
      PZVIP_TILELINK_PUT_FULL_DATA,
      PZVIP_TILELINK_PUT_PARTIAL_DATA,
      PZVIP_TILELINK_ARITHMETIC_DATA,
      PZVIP_TILELINK_LOGICAL_DATA,
      PZVIP_TILELINK_HINT,
      PZVIP_TILELINK_ACQUIRE_BLOCK,
      PZVIP_TILELINK_ACQUIRE_PERM,
      PZVIP_TILELINK_PROBE,
      PZVIP_TILELINK_RELEASE,
      PZVIP_TILELINK_RELEASE_DATA
    }) {
      source inside {[0:(2**this.configuration.source_width)-1]};
    }
    else if (opcode inside {
      PZVIP_TILELINK_ACCESS_ACK,
      PZVIP_TILELINK_ACCESS_ACK_DATA,
      PZVIP_TILELINK_HINT_ACK,
      PZVIP_TILELINK_PROBE_ACK,
      PZVIP_TILELINK_PROBE_ACK_DATA,
      PZVIP_TILELINK_GRANT,
      PZVIP_TILELINK_GRANT_DATA,
      PZVIP_TILELINK_RELEASE_ACK
    }) {
      source == related_request.source;
    }
    else {
      source == 0;
    }
  }

  constraint c_valid_sink {
    solve opcode before sink;
    if (opcode inside {
      PZVIP_TILELINK_ACCESS_ACK,
      PZVIP_TILELINK_ACCESS_ACK_DATA,
      PZVIP_TILELINK_HINT_ACK,
      PZVIP_TILELINK_GRANT,
      PZVIP_TILELINK_GRANT_DATA,
      PZVIP_TILELINK_RELEASE_ACK
    }) {
      sink inside {[0:(2**this.configuration.sink_width)-1]};
    }
    else if (opcode == PZVIP_TILELINK_RELEASE_ACK) {
      sink == related_request.sink;
    }
    else {
      sink == 0;
    }
  }

  constraint c_valid_address {
    solve opcode, size before address;
    if (opcode inside {
      PZVIP_TILELINK_GET,
      PZVIP_TILELINK_PUT_FULL_DATA,
      PZVIP_TILELINK_PUT_PARTIAL_DATA,
      PZVIP_TILELINK_ARITHMETIC_DATA,
      PZVIP_TILELINK_LOGICAL_DATA,
      PZVIP_TILELINK_HINT,
      PZVIP_TILELINK_ACQUIRE_BLOCK,
      PZVIP_TILELINK_ACQUIRE_PERM,
      PZVIP_TILELINK_PROBE,
      PZVIP_TILELINK_RELEASE,
      PZVIP_TILELINK_RELEASE_DATA
    }) {
      address inside {[0:(2**this.configuration.address_width)-1]};
      (address % size) == 0;
    }
    else if (opcode inside {
      PZVIP_TILELINK_PROBE_ACK,
      PZVIP_TILELINK_PROBE_ACK_DATA
    }) {
      address == related_request.address;
    }
    else {
      address == 0;
    }
  }

  constraint c_valid_size {
    solve opcode before size;
    if (opcode inside {
      PZVIP_TILELINK_GET,
      PZVIP_TILELINK_PUT_FULL_DATA,
      PZVIP_TILELINK_PUT_PARTIAL_DATA,
      PZVIP_TILELINK_ARITHMETIC_DATA,
      PZVIP_TILELINK_LOGICAL_DATA,
      PZVIP_TILELINK_HINT,
      PZVIP_TILELINK_ACQUIRE_BLOCK,
      PZVIP_TILELINK_ACQUIRE_PERM,
      PZVIP_TILELINK_PROBE,
      PZVIP_TILELINK_RELEASE,
      PZVIP_TILELINK_RELEASE_DATA
    }) {
      size inside {[1:this.configuration.max_size]};
      $countones(size) == 1;
    }
    else if (opcode inside {
      PZVIP_TILELINK_ACCESS_ACK,
      PZVIP_TILELINK_ACCESS_ACK_DATA,
      PZVIP_TILELINK_HINT_ACK,
      PZVIP_TILELINK_PROBE_ACK,
      PZVIP_TILELINK_PROBE_ACK_DATA,
      PZVIP_TILELINK_GRANT,
      PZVIP_TILELINK_GRANT_DATA,
      PZVIP_TILELINK_RELEASE_ACK
    }) {
      size == related_request.size;
    }
    else {
      size == 0;
    }
  }

  constraint c_valid_mask {
    solve opcode, size, address before mask;
    if (opcode inside {
      PZVIP_TILELINK_GET,
      PZVIP_TILELINK_HINT,
      PZVIP_TILELINK_ACQUIRE_BLOCK,
      PZVIP_TILELINK_ACQUIRE_PERM,
      PZVIP_TILELINK_PROBE
    }) {
      mask.size == 1;
    }
    else if (opcode inside {
      PZVIP_TILELINK_PUT_FULL_DATA,
      PZVIP_TILELINK_PUT_PARTIAL_DATA,
      PZVIP_TILELINK_ARITHMETIC_DATA,
      PZVIP_TILELINK_LOGICAL_DATA
    }) {
      mask.size == `pzvip_tilelink_get_number_of_beats(size, this.configuration.byte_width);
    }
    else {
      mask.size == 0;
    }
    if (opcode != PZVIP_TILELINK_PUT_PARTIAL_DATA) {
      foreach (mask[i]) {
        mask[i] == `pzvip_tilelink_get_mask(size, address, this.configuration.byte_width);
      }
    }
  }

  constraint c_valid_data {
    solve size before data;
    if (opcode inside {
      PZVIP_TILELINK_PUT_FULL_DATA,
      PZVIP_TILELINK_PUT_PARTIAL_DATA,
      PZVIP_TILELINK_ACCESS_ACK_DATA,
      PZVIP_TILELINK_ARITHMETIC_DATA,
      PZVIP_TILELINK_LOGICAL_DATA,
      PZVIP_TILELINK_PROBE_ACK_DATA,
      PZVIP_TILELINK_GRANT_DATA,
      PZVIP_TILELINK_RELEASE_DATA
    }) {
      data.size == `pzvip_tilelink_get_number_of_beats(size, this.configuration.byte_width);
    }
    else {
      data.size == 0;
    }
    foreach (data[i]) {
      (data[i] >> this.configuration.data_width) == 0;
    }
  }

  constraint c_valid_atomic_operation {
    solve opcode before atomic_operation;
    if (opcode == PZVIP_TILELINK_ARITHMETIC_DATA) {
      atomic_operation inside {
        PZVIP_TILELINK_MIN,
        PZVIP_TILELINK_MAX,
        PZVIP_TILELINK_MINU,
        PZVIP_TILELINK_MAXU,
        PZVIP_TILELINK_ADD
      };
    }
    else if (opcode == PZVIP_TILELINK_LOGICAL_DATA) {
      atomic_operation inside {
        PZVIP_TILELINK_XOR,
        PZVIP_TILELINK_OR,
        PZVIP_TILELINK_AND,
        PZVIP_TILELINK_SWAP
      };
    }
    else {
      atomic_operation == pzvip_tilelink_atomic_operation'(0);
    }
  }

  constraint c_valid_hint {
    solve opcode before hint;
    if (opcode != PZVIP_TILELINK_HINT) {
      hint == pzvip_tilelink_hint'(0);
    }
  }

  constraint c_valid_permission_transfer {
    solve opcode before permission_transfer;
    if (opcode inside {
      PZVIP_TILELINK_ACQUIRE_BLOCK,
      PZVIP_TILELINK_ACQUIRE_PERM
    }) {
      //  Grow
      permission_transfer inside {
        PZVIP_TILELINK_N_TO_B,
        PZVIP_TILELINK_N_TO_T,
        PZVIP_TILELINK_B_TO_T
      };
    }
    else if (opcode inside {
      PZVIP_TILELINK_PROBE,
      PZVIP_TILELINK_GRANT,
      PZVIP_TILELINK_GRANT_DATA
    }) {
      //  Cap
      permission_transfer inside {
        PZVIP_TILELINK_TO_T,
        PZVIP_TILELINK_TO_B,
        PZVIP_TILELINK_TO_N
      };
    }
    else if (opcode inside {
      PZVIP_TILELINK_PROBE_ACK,
      PZVIP_TILELINK_PROBE_ACK_DATA
    }) {
      //  Shrink or Report
      permission_transfer inside {
        PZVIP_TILELINK_T_TO_B,
        PZVIP_TILELINK_T_TO_N,
        PZVIP_TILELINK_B_TO_N,
        PZVIP_TILELINK_T_TO_T,
        PZVIP_TILELINK_B_TO_B,
        PZVIP_TILELINK_N_TO_N
      };
    }
  }

  constraint c_gap_delay_order {
    solve opcode before gap_delay;
  }

  `pzvip_tilelink_array_delay_constraint(
    gap_delay,
    this.configuration.gap_delay,
    (opcode inside {
      PZVIP_TILELINK_PUT_FULL_DATA,
      PZVIP_TILELINK_PUT_PARTIAL_DATA,
      PZVIP_TILELINK_ACCESS_ACK_DATA,
      PZVIP_TILELINK_ARITHMETIC_DATA,
      PZVIP_TILELINK_LOGICAL_DATA,
      PZVIP_TILELINK_PROBE_ACK_DATA,
      PZVIP_TILELINK_GRANT_DATA,
      PZVIP_TILELINK_RELEASE_DATA
    })
  )

  constraint c_response_start_delay_order {
    solve opcode before response_start_delay;
  }

  `pzvip_tilelink_delay_constraint(
    response_start_delay,
    this.configuration.response_start_delay,
    (enable_early_response) ->
      (response_start_delay >= related_request.ready_delay[0]),
    (opcode inside {
      PZVIP_TILELINK_ACCESS_ACK,
      PZVIP_TILELINK_ACCESS_ACK_DATA,
      PZVIP_TILELINK_HINT_ACK,
      PZVIP_TILELINK_PROBE_ACK,
      PZVIP_TILELINK_PROBE_ACK_DATA,
      PZVIP_TILELINK_GRANT,
      PZVIP_TILELINK_GRANT_DATA,
      PZVIP_TILELINK_GRANT_ACK,
      PZVIP_TILELINK_RELEASE_ACK
    })
  )

  constraint c_valid_enable_early_response {
    solve opcode before enable_early_response;
    if (!(opcode inside {
      PZVIP_TILELINK_ACCESS_ACK,
      PZVIP_TILELINK_ACCESS_ACK_DATA,
      PZVIP_TILELINK_HINT_ACK,
      PZVIP_TILELINK_PROBE_ACK,
      PZVIP_TILELINK_PROBE_ACK_DATA,
      PZVIP_TILELINK_GRANT,
      PZVIP_TILELINK_GRANT_DATA,
      PZVIP_TILELINK_GRANT_ACK,
      PZVIP_TILELINK_RELEASE_ACK
    })) {
      enable_early_response == 0;
    }
  }

  function void pre_randomize();
    ready_delay.rand_mode(0);
  endfunction

  `tue_object_default_constructor(pzvip_tilelink_sender_message_item)
  `uvm_object_utils(pzvip_tilelink_sender_message_item)
endclass

class pzvip_tilelink_receiver_message_item extends pzvip_tilelink_message_item;
  `pzvip_tilelink_array_delay_constraint(
    ready_delay,
    this.configuration.ready_delay,
    (opcode inside {
      PZVIP_TILELINK_PUT_FULL_DATA,
      PZVIP_TILELINK_PUT_PARTIAL_DATA,
      PZVIP_TILELINK_ACCESS_ACK_DATA,
      PZVIP_TILELINK_ARITHMETIC_DATA,
      PZVIP_TILELINK_LOGICAL_DATA,
      PZVIP_TILELINK_PROBE_ACK_DATA,
      PZVIP_TILELINK_GRANT_DATA,
      PZVIP_TILELINK_RELEASE_DATA
    })
  )

  function void pre_randomize();
    opcode.rand_mode(0);
    source.rand_mode(0);
    sink.rand_mode(0);
    address.rand_mode(0);
    size.rand_mode(0);
    mask.rand_mode(0);
    data.rand_mode(0);
    corrupt.rand_mode(0);
    denied.rand_mode(0);
    atomic_operation.rand_mode(0);
    hint.rand_mode(0);
    permission_transfer.rand_mode(0);
    gap_delay.rand_mode(0);
    response_start_delay.rand_mode(0);
    enable_early_response.rand_mode(0);
  endfunction

  `tue_object_default_constructor(pzvip_tilelink_receiver_message_item)
  `uvm_object_utils(pzvip_tilelink_receiver_message_item)
endclass
`endif
