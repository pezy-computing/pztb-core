class pztb_common_env_context_base extends uvm_object;
  string      hdl_path;
  bit [31:0]  csr_base_address;
  `tue_object_default_constructor(pztb_common_env_context_base)
endclass

class pztb_common_env_context_dummy extends pztb_common_env_context_base;
  `tue_object_default_constructor(pztb_common_env_context_dummy)
  `uvm_object_utils(pztb_common_env_context_dummy)
endclass
