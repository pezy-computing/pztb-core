class pztb_common_env_bfm_env_base #(
  type  SEQUENCER = pztb_common_env_bfm_sequencer_base
) extends uvm_env;
  uvm_active_passive_enum env_type;
  SEQUENCER               sequencer;

  function new(string name = "pztb_common_env_bfm_env_base", uvm_component parent = null);
    super.new(name, parent);
    env_type  = UVM_ACTIVE;
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    do_build();
    apply_agent_type();
  endfunction

  protected virtual function do_build();
  endfunction

  protected function void apply_agent_type();
    uvm_component children[$];
    uvm_agent     agent;
    get_children(children);
    foreach (children[i]) begin
      if ($cast(agent, children[i])) begin
        agent.is_active = env_type;
      end
    end
  endfunction
endclass
