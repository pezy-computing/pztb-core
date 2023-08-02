class pztb_common_env_sequence_base #(
  type  CONFIGURATION = pztb_common_env_configuration_base,
  type  STATUS        = pztb_common_env_status_base,
  type  SEQUENCER     = pztb_common_env_sequencer_base
) extends tue_sequence #(
  .CONFIGURATION  (CONFIGURATION  ),
  .STATUS         (STATUS         )
);
  rand  bit read_back;

  constraint c_default_read_back {
    soft read_back == 0;
  }

  function new(string name = "pztb_common_env_sequence_base");
    super.new(name);
    set_automatic_phase_objection(1);
  endfunction

  function void set_sequencer(uvm_sequencer_base sequencer);
    super.set_sequencer(sequencer);
    set_sub_sequencers();
  endfunction

  protected virtual function void set_sub_sequencers();
  endfunction

  protected virtual task csr_write(
    input bit [31:0]                          offset,
    input bit [31:0]                          data,
    ref   bit                                 error,
    input bit                                 read_back = 0,
    input pztb_common_env_bfm_sequencer_base  sequencer = null
  );
    bit [31:0]  address;

    address = configuration.tb_context.csr_base_address + offset;
    if (sequencer != null) begin
      sequencer.do_csr_access(1, address, data, error, this);
    end
    else if (p_sequencer.host_sequencer != null) begin
      p_sequencer.host_sequencer.do_csr_access(1, address, data, error, this);
    end
    else begin
      do_csr_access(1, address, data, error);
    end

    if (read_back) begin
      bit [31:0]  temp;
      csr_read(offset, temp, error, sequencer);
    end
  endtask

  protected virtual task csr_read(
    input bit [31:0]                          offset,
    ref   bit [31:0]                          data,
    ref   bit                                 error,
    input pztb_common_env_bfm_sequencer_base  sequencer = null
  );
    bit [31:0]  address;

    address = configuration.tb_context.csr_base_address + offset;
    if (sequencer != null) begin
      sequencer.do_csr_access(0, address, data, error, this);
    end
    else if (p_sequencer.host_sequencer != null) begin
      p_sequencer.host_sequencer.do_csr_access(0, address, data, error, this);
    end
    else begin
      do_csr_access(0, address, data, error);
    end
  endtask

  protected virtual task do_csr_access(
    input bit         is_write,
    input bit [31:0]  address,
    ref   bit [31:0]  data,
    ref   bit         error
  );
  endtask

  protected virtual task update_reg(uvm_reg rg, bit read_back = 0, uvm_door_e path = UVM_FRONTDOOR);
    uvm_status_e    status;
    uvm_reg_data_t  data;
    rg.update(.status(status), .path(path), .parent(this));
    if (read_back) begin
      rg.read(.status(status), .value(data), .parent(this));
    end
  endtask

  protected virtual task mirror_reg(uvm_reg rg, uvm_door_e path = UVM_FRONTDOOR);
    uvm_status_e  status;
    rg.mirror(.status(status), .path(path), .parent(this));
  endtask

  `uvm_declare_p_sequencer(SEQUENCER)
endclass
