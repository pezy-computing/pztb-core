class pztb_common_env_non_param_base #(
  type  HOST_ENV  = pztb_common_env_bfm_env_base
) extends uvm_env;
  HOST_ENV  host_env;

  virtual function HOST_ENV get_host_env();
    if (host_env == null) begin
      pztb_common_env_non_param_base #(HOST_ENV)  parent_env;
      if ($cast(parent_env, get_parent())) begin
        host_env  = parent_env.get_host_env();
      end
    end

    if (host_env == null) begin
      host_env  = get_default_host_env();
    end

    return host_env;
  endfunction

  protected virtual function HOST_ENV get_default_host_env();
    return null;
  endfunction

  `tue_component_default_constructor(pztb_common_env_base)
endclass

class pztb_common_env_base #(
  type  CONFIGURATION = pztb_common_env_configuration_base,
  type  STATUS        = pztb_common_env_status_base,
  type  SEQUENCER     = pztb_common_env_sequencer_base,
  type  HOST_ENV      = pztb_common_env_bfm_env_base
) extends tue_component_base #(
  .BASE           (pztb_common_env_non_param_base #(HOST_ENV) ),
  .CONFIGURATION  (CONFIGURATION                              ),
  .STATUS         (STATUS                                     )
);
  SEQUENCER sequencer;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    do_build();
    do_apply_env_type();
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    void'(get_host_env());
    if (host_env != null) begin
      sequencer.host_sequencer  = host_env.sequencer;
    end

    connect_sub_env();
    if (configuration.enable_checkers) begin
      connect_checkers();
    end
  endfunction

  protected virtual function void do_build();
    sequencer = SEQUENCER::type_id::create("sequencer", this);
    sequencer.set_context(configuration, status);

    create_sub_env();
    if (configuration.enable_checkers) begin
      create_checkers();
    end
  endfunction

  protected virtual function void create_sub_env();
  endfunction

  protected virtual function void create_checkers();
  endfunction

  protected virtual function void connect_sub_env();
  endfunction

  protected virtual function void connect_checkers();
  endfunction

  protected function void do_apply_env_type();
    uvm_component children[$];
    get_children(children);
    foreach (children[i]) begin
      apply_env_type(children[i]);
    end
  endfunction

  protected virtual function void apply_env_type(uvm_component component);
  endfunction

  `tue_component_default_constructor(pztb_common_env_base)
endclass

class pztb_common_env_dummy extends pztb_common_env_base #(
  .CONFIGURATION  (pztb_common_env_configuration_dummy  ),
  .STATUS         (pztb_common_env_status_dummy         ),
  .SEQUENCER      (pztb_common_env_sequencer_dummy      )
);
  `tue_component_default_constructor(pztb_common_env_dummy)
  `uvm_component_utils(pztb_common_env_dummy)
endclass
