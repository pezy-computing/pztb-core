class pztb_common_env_test_sequence_base #(
  type  BASE  = uvm_sequence
) extends BASE;
  function new(string name = "pztb_common_env_test_sequence_base");
    super.new(name);
    set_automatic_phase_objection(1);
  endfunction

  task pre_start();
    super.pre_start();
    setup();
  endtask

  protected virtual task setup();
  endtask
endclass

class pztb_common_env_test_base #(
  type  TB_CONTEXT    = pztb_common_env_context_dummy,
  type  CONFIGURATION = pztb_common_env_configuration_dummy,
  type  STATUS        = pztb_common_env_status_dummy,
  type  ENV           = pztb_common_env_dummy,
  type  SEQUENCER     = pztb_common_env_sequencer_dummy
) extends tue_test #(
  .CONFIGURATION  (CONFIGURATION  ),
  .STATUS         (STATUS         )
);
  ENV       env;
  SEQUENCER sequencer;

  function new(string name = "pzvip_test_base", uvm_component parent = null);
    super.new(name, parent);
    `uvm_info("SRANDOM", $sformatf("Initial Random Seed: %0d", $get_initial_random_seed), UVM_NONE)
    if (get_report_verbosity_level() >= UVM_HIGH) begin
      uvm_root  root;
      root                        = uvm_root::get();
      root.enable_print_topology  = 1;
    end
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!tue_check_type(ENV::get_type(), pztb_common_env_dummy::type_id::get())) begin
      env = ENV::type_id::create("env", this);
      env.set_context(configuration, status);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (env != null) begin
      $cast(sequencer, env.sequencer);
    end
  endfunction

  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    setup_default_sequences();
    setup_main_sequence();
  endfunction

  protected virtual function void setup_default_sequences();
  endfunction

  protected virtual function void setup_main_sequence();
    uvm_sequencer_base  main_sequencer;
    uvm_object_wrapper  main_sequence;

    main_sequencer  = get_main_sequencer();
    main_sequence   = get_main_sequence();
    if (main_sequence != null) begin
      set_default_sequence(main_sequence, "main_phase", 0, main_sequencer);
    end
  endfunction

  protected virtual function uvm_sequencer_base get_main_sequencer();
    return null;
  endfunction

  protected virtual function uvm_object_wrapper get_main_sequence();
    return null;
  endfunction

  protected virtual function void set_default_sequence(
    uvm_object_wrapper  default_sequence,
    string              phase,
    bit                 override          = 0,
    uvm_sequencer_base  target_sequencer  = null
  );
    if (target_sequencer == null) begin
      target_sequencer  = sequencer;
    end
    if (target_sequencer == null) begin
      return;
    end

    if ((!override) && has_default_sequence(target_sequencer, phase)) begin
      return;
    end

    uvm_config_db #(uvm_object_wrapper)
      ::set(target_sequencer, phase, "default_sequence", default_sequence);
  endfunction

  protected function bit has_default_sequence(
    uvm_sequencer_base  sequencer,
    string              phase
  );
    return uvm_config_db #(uvm_object_wrapper)::exists(sequencer, phase, "default_sequence");
  endfunction

  protected function void create_configuration();
    super.create_configuration();
    setup_configuration();
    if (!tue_check_type(TB_CONTEXT::type_id::get(), pztb_common_env_context_dummy::type_id::get())) begin
      TB_CONTEXT  tb_context  = get_tb_context();
      if (tb_context != null) begin
        configuration.set_tb_context(tb_context);
      end
    end
    override_configuration();
  endfunction

  protected virtual function void setup_configuration();
  endfunction

  protected virtual function void override_configuration();
  endfunction

  protected virtual function TB_CONTEXT get_tb_context();
    TB_CONTEXT  tb_context;
    uvm_object  temp;

    if (uvm_config_db #(TB_CONTEXT)::get(null, "", "tb_context", tb_context)) begin
      return tb_context;
    end

    if (uvm_config_db #(uvm_object)::get(null, "", "tb_context", temp)) begin
      if ($cast(tb_context, temp)) begin
        return tb_context;
      end
    end

    return null;
  endfunction

  protected function void create_status();
    super.create_status();
    status.create_sub_status(configuration.tb_context);
  endfunction
endclass
