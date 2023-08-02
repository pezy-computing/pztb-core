class pztb_common_env_status_base #(
  type  TB_CONTEXT  = pztb_common_env_context_base
) extends tue_status;
  virtual function void create_sub_status(TB_CONTEXT tb_context);
  endfunction

  `tue_object_default_constructor(pztb_common_env_status_base)
endclass

class pztb_common_env_status_dummy extends pztb_common_env_status_base #(
  .TB_CONTEXT (pztb_common_env_context_dummy  )
);
  `tue_object_default_constructor(pztb_common_env_status_dummy)
  `uvm_object_utils(pztb_common_env_status_dummy)
endclass
