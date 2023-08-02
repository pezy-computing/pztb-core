class pztb_common_env_sequencer_base #(
  type  CONFIGURATION   = pztb_common_env_configuration_base,
  type  STATUS          = pztb_common_env_status_base,
  type  HOST_SEQUENCER  = pztb_common_env_bfm_sequencer_base
) extends tue_sequencer #(
  .CONFIGURATION  (CONFIGURATION  ),
  .STATUS         (STATUS         )
);
  HOST_SEQUENCER  host_sequencer;
  `tue_component_default_constructor(pztb_common_env_sequencer_base)
endclass

class pztb_common_env_sequencer_dummy extends pztb_common_env_sequencer_base #(
  .CONFIGURATION  (pztb_common_env_configuration_dummy  ),
  .STATUS         (pztb_common_env_status_dummy         )
);
  `tue_component_default_constructor(pztb_common_env_sequencer_dummy)
  `uvm_component_utils(pztb_common_env_sequencer_dummy)
endclass
