`ifndef PZTB_COMMON_ENV_MACROS_SVH
`define PZTB_COMMON_ENV_MACROS_SVH

`define pztb_safe_refer(HANDLE, ACTION_BLOCK) \
if (HANDLE != null) begin \
  ACTION_BLOCK; \
end

`define pztb_define_plusarg(PLUGARG, ACTION_BLOCK, PREFIX = plusarg_prefix) \
begin \
  uvm_cmdline_processor __clp; \
  string                __prefix; \
  string                __plugarg; \
  string                __values[$]; \
  __clp     = uvm_cmdline_processor::get_inst(); \
  __prefix  = PREFIX; \
  if (__prefix.len() > 0) begin \
    __plugarg = $sformatf("+%s_%s", __prefix, `"PLUGARG`"); \
  end \
  else begin \
    __plugarg = $sformatf("+%s", `"PLUGARG`"); \
  end \
  if (__clp.get_arg_matches(__plugarg, __values)) begin \
    ACTION_BLOCK; \
  end \
end

`define pztb_define_plusarg_value(PLUGARG, ACTION_BLOCK, PREFIX = plusarg_prefix) \
begin \
  uvm_cmdline_processor __clp; \
  string                __prefix; \
  string                __plugarg; \
  string                __value; \
  __clp     = uvm_cmdline_processor::get_inst(); \
  __prefix  = PREFIX; \
  if (__prefix.len() > 0) begin \
    __plugarg = $sformatf("+%s_%s=", __prefix, `"PLUGARG`"); \
  end \
  else begin \
    __plugarg = $sformatf("+%s=", `"PLUGARG`"); \
  end \
  if (__clp.get_arg_value(__plugarg, __value)) begin \
    ACTION_BLOCK; \
  end \
end

`define pztb_define_plusarg_flag(FLAG, PREFIX = plusarg_prefix) \
`pztb_define_plusarg(FLAG, begin FLAG  = 1; end, PREFIX)

`define pztb_define_plusarg_bin(VARIABLE, PREFIX = plusarg_prefix) \
`pztb_define_plusarg_value(VARIABLE, begin VARIABLE = __value.atobin(); end, PREFIX)

`define pztb_define_plusarg_dec(VARIABLE, PREFIX = plusarg_prefix) \
`pztb_define_plusarg_value(VARIABLE, begin VARIABLE = __value.atoi(); end, PREFIX)

`define pztb_define_plusarg_hex(VARIABLE, PREFIX = plusarg_prefix) \
`pztb_define_plusarg_value(VARIABLE, begin VARIABLE = __value.atohex(); end, PREFIX)

`define pztb_define_plusarg_string(VARIABLE, PREFIX = plusarg_prefix) \
`pztb_define_plusarg_value(VARIABLE, begin VARIABLE = __value; end, PREFIX)


`define pztb_run_uvm_test(TB_CONTEXT, TIME_UNIT = -9, TIME_PRECISION = 3, TIME_SUFFIX = ns) \
initial begin \
  $timeformat(TIME_UNIT, TIME_PRECISION, `"TIME_SUFFIX`"); \
  uvm_pkg::uvm_wait_for_nba_region(); \
  uvm_pkg::uvm_config_db #(uvm_pkg::uvm_object)::set(null, "", "tb_context", TB_CONTEXT); \
  uvm_pkg::run_test(); \
end

`endif
