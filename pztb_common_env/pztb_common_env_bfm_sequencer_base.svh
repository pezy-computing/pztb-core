class pztb_common_env_bfm_sequencer_base extends uvm_sequencer;
  virtual task do_csr_access(
    input bit               write_access,
    input bit [31:0]        address,
    ref   bit [31:0]        data,
    ref   bit               error,
    input uvm_sequence_base parent_sequence
  );
  endtask

  `tue_component_default_constructor(pztb_common_env_bfm_sequencer_non_param_base)
endclass
