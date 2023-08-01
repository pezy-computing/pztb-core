`ifndef PZVIP_SEQUENCE_BASE_SVH
`define PZVIP_SEQUENCE_BASE_SVH
class pzvip_sequence_base #(
  type  SEQUENCER                 = uvm_sequencer_base,
  type  CONFIGURATION             = tue_configuration_dummy,
  type  STATUS                    = tue_status_dummy,
  bit   AUTOMATIC_PHASE_OBJECTION = 1
) extends tue_sequence #(CONFIGURATION, STATUS);
  function new(string name = "pzvip_sequence_base");
    super.new(name);
    set_automatic_phase_objection(AUTOMATIC_PHASE_OBJECTION);
  endfunction
  `uvm_declare_p_sequencer(SEQUENCER)
endclass
`endif
