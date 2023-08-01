module top;
  timeunit  1ns/1ps;

  import  uvm_pkg::*;
  import  tue_pkg::*;
  import  pzvip_common_pkg::*;
  import  pzvip_stream_pkg::*;

  `include  "uvm_macros.svh"
  `include  "tue_macros.svh"

  bit clk   = 1;
  bit rst_n = 0;

  initial begin
    forever #(500ps) begin
      clk ^= 1;
    end
  end

  initial begin
    repeat (10) @(posedge clk);
    rst_n = 1;
  end

  pzvip_stream_if stream_if(clk, rst_n);

  class pzvip_stream_test extends tue_test #(
    .CONFIGURATION  (pzvip_stream_configuration ),
    .STATUS         (pzvip_stream_status        )
  );
    pzvip_stream_master_agent master_agent;
    pzvip_stream_slave_agent  slave_agent;

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      master_agent  = pzvip_stream_master_agent::type_id::create("master_agent", this);
      master_agent.set_context(configuration, status);

      slave_agent = pzvip_stream_slave_agent::type_id::create("slave_agent", this);
      slave_agent.set_context(configuration, status);
    endfunction

    task main_phase(uvm_phase phase);
      phase.raise_objection(this);

      fork
        begin
          pzvip_stream_send_file_stream_sequence  send_file_stream_sequence;
          send_file_stream_sequence           = new("send_file_stream_sequence");
          send_file_stream_sequence.file_name = "test.txt";
          send_file_stream_sequence.start(master_agent.sequencer);
        end
        begin
          pzvip_stream_item steam_item;
          slave_agent.sequencer.get_item(steam_item);
        end
      join

      phase.drop_objection(this);
    endtask

    function void create_configuration();
      super.create_configuration();
      configuration.vif = stream_if;
      void'(configuration.randomize() with {
        data_width            == 64;
        data_delay.min_delay  == 0;
        data_delay.max_delay  == 20;
        ready_delay.min_delay == 0;
        ready_delay.max_delay == 20;
      });
    endfunction

    `tue_component_default_constructor(pzvip_stream_test)
    `uvm_component_utils(pzvip_stream_test)
  endclass

  initial begin
    run_test("pzvip_stream_test");
  end
endmodule
