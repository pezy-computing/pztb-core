`ifndef PZVIP_COREBUS_SAMPLE_TEST_SVH
`define PZVIP_COREBUS_SAMPLE_TEST_SVH
class pzvip_corebus_sample_test extends tue_test #(
  .CONFIGURATION  (pzvip_corebus_sample_configuration )
);
  pzvip_corebus_master_agent  master_agent;
  pzvip_corebus_slave_agent   slave_agent;

  function new(string name = "pzvip_corebus_sample_test", uvm_component parent = null);
    super.new(name, parent);
    `uvm_info("SRANDOM", $sformatf("Initial random seed: %0d", $get_initial_random_seed), UVM_NONE)
  endfunction

  function void create_configuration();
    super.create_configuration();
    void'(uvm_config_db #(pzvip_corebus_vif)::get(
      null, "", "vif", configuration.corebus_cfg.vif
    ));
    if (configuration.randomize()) begin
      `uvm_info("CFG", $sformatf("Configuration...\n%s", configuration.sprint()), UVM_NONE)
    end
    else begin
      `uvm_fatal("RNDFLD", "Randomization failed")
    end
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    master_agent  = pzvip_corebus_master_agent::type_id::create("master_agent", this);
    slave_agent   = pzvip_corebus_slave_agent::type_id::create("slave_agent", this);
    master_agent.set_configuration(configuration.corebus_cfg);
    slave_agent.set_configuration(configuration.corebus_cfg);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_config_db #(uvm_object_wrapper)::set(
      master_agent.sequencer, "main_phase", "default_sequence",
      pzvip_corebus_sample_write_read_sequence::type_id::get()
    );
    uvm_config_db #(uvm_object_wrapper)::set(
      slave_agent.sequencer, "run_phase", "default_sequence",
      pzvip_corebus_slave_default_sequence::type_id::get()
    );
  endfunction

  `uvm_component_utils(pzvip_corebus_sample_test)
endclass
`endif
