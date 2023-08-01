`ifndef PZVIP_TILELINK_MASTER_DEFAULT_SEQUENCE_SVH
`define PZVIP_TILELINK_MASTER_DEFAULT_SEQUENCE_SVH
class pzvip_tilelink_master_default_sequence extends pzvip_tilelink_master_sequence;
  task body();
    fork
      if (configuration.conformance_level == PZVIP_TILELINK_TL_C) begin
        pzvip_tilelink_master_response_probe_sequence response_probe_sequence;
        `uvm_do(response_probe_sequence)
      end
    join
  endtask

  `tue_object_default_constructor(pzvip_tilelink_master_default_sequence)
  `uvm_object_utils(pzvip_tilelink_master_default_sequence)
endclass
`endif
