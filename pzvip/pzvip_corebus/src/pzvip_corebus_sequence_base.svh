`ifndef PZVIP_COREBUS_SEQUENCE_BASE_SVH
`define PZVIP_COREBUS_SEQUENCE_BASE_SVH
class pzvip_corebus_sequence_base #(
  type  BASE      = uvm_sequence,
  type  SEQUENCER = uvm_sequencer,
  type  ITEM      = uvm_sequence_item
) extends BASE;
  function new(string name = "pzvip_corebus_sequence_base");
    super.new(name);
    set_automatic_phase_objection(0);
  endfunction

  `define pzvip_corebus_define_item_getter_tasks(ITEM_TYPE) \
  virtual task get_``ITEM_TYPE(ref ITEM item); \
    p_sequencer.get_``ITEM_TYPE(item); \
  endtask \
  virtual task get_``ITEM_TYPE``_by_id(input pzvip_corebus_id id, ref ITEM item); \
    p_sequencer.get_``ITEM_TYPE``_by_id(id, item); \
  endtask

  `pzvip_corebus_define_item_getter_tasks(command_item )
  `pzvip_corebus_define_item_getter_tasks(request_item )
  `pzvip_corebus_define_item_getter_tasks(response_item)
  `pzvip_corebus_define_item_getter_tasks(item         )

  `undef  pzvip_corebus_define_item_getter_tasks

  `uvm_declare_p_sequencer(SEQUENCER)
endclass
`endif
