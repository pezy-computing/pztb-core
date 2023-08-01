class pzvip_stream_sequence extends tue_sequence #(
  .CONFIGURATION  (pzvip_stream_configuration ),
  .STATUS         (pzvip_stream_status        )
);
  `uvm_declare_p_sequencer(pzvip_stream_sequencer)
  `tue_object_default_constructor(pzvip_stream_sequencer)
endclass
