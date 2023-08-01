class pzvip_i2c_sequence_base #(
  type  SEQUENCER = uvm_sequencer
) extends tue_sequence #(
  .CONFIGURATION  (pzvip_i2c_configuration  ),
  .STATUS         (pzvip_i2c_status         )
);
  protected pzvip_i2c_vif vif;

  function new(string name = "pzvip_i2c_sequence_base");
    super.new(name);
    set_automatic_phase_objection(0);
  endfunction

  function void set_configuration(tue_configuration configuration);
    super.set_configuration(configuration);
    vif = this.configuration.vif;
  endfunction

  `uvm_declare_p_sequencer(SEQUENCER)
endclass

class pzvip_i2c_master_sequence_base extends pzvip_i2c_sequence_base #(
  .SEQUENCER  (pzvip_i2c_master_sequencer )
);
  `tue_object_default_constructor(pzvip_i2c_master_sequence_base)
endclass

class pzvip_i2c_master_access_sequence_base extends pzvip_i2c_master_sequence_base;
  rand  int       scl_period_ns;
  rand  bit [6:0] device_address;
  rand  int       length;
  rand  bit       send_start;
  rand  bit       send_stop;

  constraint c_valid_scl_period_ns {
    scl_period_ns > 0;
  }

  constraint c_valid_length {
    length > 0;
  }

  constraint c_default_send_start {
    soft send_start == 1;
  }

  constraint c_default_send_stop {
    soft send_stop == 1;
  }

  protected task send_byte(
    input bit [7:0] tx_byte,
    ref   bit       nack,
    ref   bit       lost_arbitration
  );
    for (int i = 7;i >= 0;--i) begin
      vif.send_i2c_master(scl_period_ns, tx_byte[i], lost_arbitration);
      if (lost_arbitration) begin
        return;
      end
    end

    vif.receive_i2c_master(scl_period_ns, nack);
  endtask

  protected task receive_byte(
    ref   bit [7:0] rx_byte,
    input bit       nack,
    ref   bit       lost_arbitration
  );
    bit rx_bit;

    for (int i = 7;i >= 0;--i) begin
      vif.receive_i2c_master(scl_period_ns, rx_bit);
      rx_byte[i]  = rx_bit;
    end

    vif.send_i2c_master(scl_period_ns, nack, lost_arbitration);
  endtask

  protected task start_access(
    input bit rw,
    ref   bit nack,
    ref   bit lost_arbitration
  );
    do begin
      if (send_start) begin
        vif.send_start_condition(scl_period_ns / 2, lost_arbitration);
      end
      else begin
        vif.send_repeated_start_condition(scl_period_ns / 2, lost_arbitration);
      end
    end while (lost_arbitration);

    send_byte({device_address, rw}, nack, lost_arbitration);
  endtask

  protected task stop_access(
    bit force_send  = 0
  );
    if (send_stop || force_send) begin
      vif.send_stop_condition(scl_period_ns / 2);
    end
  endtask

  `tue_object_default_constructor(pzvip_i2c_master_access_sequence_base)
  `uvm_field_utils_begin(pzvip_i2c_master_access_sequence_base)
    `uvm_field_int(scl_period_ns, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(device_address, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(length, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(send_start, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(send_stop, UVM_DEFAULT | UVM_BIN)
  `uvm_field_utils_end
endclass

class pzvip_i2c_slave_sequence_base extends pzvip_i2c_sequence_base #(
  .SEQUENCER  (pzvip_i2c_slave_sequencer  )
);
  `tue_object_default_constructor(pzvip_i2c_slave_sequence_base)
endclass
