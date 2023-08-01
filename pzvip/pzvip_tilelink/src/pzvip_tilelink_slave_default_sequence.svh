`ifndef PZVIP_TILELINK_SLAVE_DEFAULT_SEQUENCE_SVH
`define PZVIP_TILELINK_SLAVE_DEFAULT_SEQUENCE_SVH
class pzvip_tilelink_slave_default_sequence extends pzvip_tilelink_slave_sequence;
  task body();
    fork
      if (1) begin
        pzvip_tilelink_slave_respond_get_put_sequence respond_get_put_sequence;
        `uvm_do(respond_get_put_sequence)
      end
      if (configuration.conformance_level == PZVIP_TILELINK_TL_C) begin
        pzvip_tilelink_slave_respond_acquire_sequence respond_acquire_sequence;
        `uvm_do(respond_acquire_sequence)
      end
      if (configuration.conformance_level == PZVIP_TILELINK_TL_C) begin
        pzvip_tilelink_slave_respond_release_sequence respond_release_sequence;
        `uvm_do(respond_release_sequence)
      end
    join
  endtask

  `tue_object_default_constructor(pzvip_tilelink_slave_default_sequence)
  `uvm_object_utils(pzvip_tilelink_slave_default_sequence)
endclass
`endif
