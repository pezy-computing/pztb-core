class pztb_common_env_configuration_base #(
  type  TB_CONTEXT  = pztb_common_env_context_base
) extends tue_configuration;
        TB_CONTEXT              tb_context;
  rand  bit                     enable_checkers   = 1;
  rand  bit                     enable_pa_writer  = 0;
  rand  uvm_active_passive_enum env_type          = UVM_ACTIVE;
  rand  int                     env_index         = -1;
        string                  env_prefix;
        string                  plusarg_prefix;

  constraint c_env_index {
    env_index >= -1;
  }

  constraint c_default {
    soft enable_checkers  == 1;
    soft enable_pa_writer == 0;
    soft env_type         == UVM_ACTIVE;
    soft env_index        == -1;
  }

  virtual function void set_tb_context(TB_CONTEXT tb_context);
    this.tb_context = tb_context;
    if (env_index >= 0) begin
      plusarg_prefix  = $sformatf("%s_%0d", env_prefix, env_index);
    end
    else begin
      plusarg_prefix  = env_prefix;
    end
    parse_plusargs();
    create_sub_cfg();
  endfunction

  protected virtual function void parse_plusargs();
    `pztb_define_plusarg_bin(enable_checkers)
    `pztb_define_plusarg_bin(enable_pa_writer)
  endfunction

  protected virtual function void create_sub_cfg();
  endfunction

  `tue_object_default_constructor(pztb_common_env_configuration_base)
endclass

class pztb_common_env_configuration_dummy extends pztb_common_env_configuration_base;
  `tue_object_default_constructor(pztb_common_env_configuration_dummy)
  `uvm_object_utils(pztb_common_env_configuration_dummy)
endclass
