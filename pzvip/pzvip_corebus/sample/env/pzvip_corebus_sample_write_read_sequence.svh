`ifndef PZVIP_COREBUS_SAMPLE_WRITE_READ_SEQUENCE_SVH
`define PZVIP_COREBUS_SAMPLE_WRITE_READ_SEQUENCE_SVH
class pzvip_corebus_sample_write_read_sequence extends pzvip_corebus_master_sequence;
  function new(string name = "pzvip_corebus_sample_write_read_sequence");
    super.new(name);
    set_automatic_phase_objection(1);
  endfunction

  task body();
    for (int i = 0;i < 20;++i) begin
      fork
        automatic int ii  = i;
        do_write_read_access(ii);
      join_none
    end
    wait fork;
  endtask

  task do_write_read_access(int index);
    int                                 address_shift;
    pzvip_corebus_master_write_sequence write_sequence;
    pzvip_corebus_master_read_sequence  read_sequence;

    address_shift = configuration.address_shift;

    `uvm_do_with(write_sequence, {
      command != PZVIP_COREBUS_ATOMIC;
      command != PZVIP_COREBUS_ATOMIC_NON_POSTED;

      address >= (32'h0001_0000 * (index + 0) - 0);
      address <= (32'h0001_0000 * (index + 1) - 1);

      ((address >> address_shift) + length) <
        ((32'h0001_0000 * (index + 1)) >> address_shift);
    })

    `uvm_do_with(read_sequence, {
      address == write_sequence.address;
      length  == write_sequence.length;
    })
  endtask

  `uvm_object_utils(pzvip_corebus_sample_write_read_sequence)
endclass
`endif
