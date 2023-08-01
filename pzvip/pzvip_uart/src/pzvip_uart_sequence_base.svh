class pzvip_uart_sequence_base extends tue_sequence #(
  .CONFIGURATION  (pzvip_uart_configuration ),
  .STATUS         (pzvip_uart_status        )
);
  protected pzvip_uart_vif  vif;

  function new(string name = "pzvip_uart_sequence_base");
    super.new(name);
    set_automatic_phase_objection(0);
  endfunction

  function void set_configuration(tue_configuration configuration);
    super.set_configuration(configuration);
    vif = this.configuration.vif;
  endfunction

  protected function bit calc_parity(
    pzvip_uart_parity parity,
    int               data_bits,
    bit [8:0]         data,
    bit               invert  = 0
  );
    bit [8:0] mask;
    bit       parity_bit;

    mask  = (1 << data_bits) - 1;
    if (parity == PZVIP_UART_EVEN_PARITY) begin
      parity_bit  = ^(data & mask);
    end
    else begin
      parity_bit  = ~^(data & mask);
    end

    if (invert) begin
      return ~parity_bit;
    end
    else begin
      return parity_bit;
    end
  endfunction

  `uvm_declare_p_sequencer(pzvip_uart_sequencer)
endclass
