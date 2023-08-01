`ifndef PZVIP_PA_WRITER_BASE_SVH
`define PZVIP_PA_WRITER_BASE_SVH
class pzvip_pa_writer_configuration extends tue_configuration;
  rand  bit enable_writer;
  rand  bit enable_memory_writer;
  rand  int address_width;
  rand  int data_width;

  constraint c_default_enable_writer {
    soft enable_writer        == 0;
    soft enable_memory_writer == 0;
  }

  constraint c_valid_address_width {
    address_width > 0;
  }

  constraint c_valid_data_width {
    data_width > 0;
    $countones(data_width) == 1;
  }

  `tue_object_default_constructor(pzvip_pa_writer_configuration)
  `uvm_object_utils_begin(pzvip_pa_writer_configuration)
    `uvm_field_int(enable_writer, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(enable_memory_writer, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(address_width, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(data_width, UVM_DEFAULT | UVM_BIN)
  `uvm_field_utils_end
endclass

class pzvip_pa_writer_base extends uvm_object;
  localparam  int PA_WRITER_BV_MAX_WIDTH  =
    `ifdef  VERDI_PA_WRITER_BV_MAX_WIDTH  `VERDI_PA_WRITER_BV_MAX_WIDTH
    `else                                 1024
    `endif;

  typedef bit [PA_WRITER_BV_MAX_WIDTH-1:0]  pzvip_pa_writer_bv;

  protected string                        protocol_name;
  protected string                        protocol_version;
  protected pzvip_pa_writer_configuration pa_writer_configuration;
  protected int                           word_address_shift;
  protected int                           word_address_width;

`ifdef _PZ_PZVIP_ENABLE_PA_WRITER_
  protected verdi_pa_writer_pkg::verdi_pa_writer  pa_writer;

  function void build(
    uvm_component                 parent,
    pzvip_pa_writer_configuration pa_writer_configuration,
    string                        if_path
  );
    this.pa_writer_configuration  = pa_writer_configuration;
    this.word_address_shift       = $clog2(pa_writer_configuration.data_width / 8);
    this.word_address_width       = pa_writer_configuration.address_width - word_address_shift;
    create_pa_writer(parent, if_path);
  endfunction

  protected virtual function void create_pa_writer(uvm_component parent, string if_path);
    string  parent_path   = parent.get_full_name();
    int     address_width = pa_writer_configuration.address_width;
    int     data_width    = pa_writer_configuration.data_width;

    if (pa_writer_configuration.enable_memory_writer) begin
      pa_writer = new(parent_path, protocol_name, protocol_version, address_width, data_width);
    end
    else begin
      pa_writer = new(parent_path, protocol_name, protocol_version);
    end

    if (if_path.len() > 0) begin
      pa_writer.add_if_paths(if_path);
    end
  endfunction

  function string create_pa_object(
    string  object_name,
    time    start_time,
    string  channel_name    = "",
    string  parent_uid      = "",
    string  predecessor_uid = ""
  );
    string  uid;
    uid = pa_writer.create_object(object_name, "", channel_name, start_time);
    if (parent_uid.len() > 0) begin
      pa_writer.set_object_parent(uid, parent_uid);
    end
    if (predecessor_uid.len() > 0) begin
      pa_writer.set_object_predecessor(uid, predecessor_uid);
    end
    return uid;
  endfunction

  function void close_pa_object(string uid);
    void'(pa_writer.end_object(uid));
  endfunction

  protected function void add_child_object(string uid, string child_uid);
    void'(pa_writer.add_object_child(uid, child_uid));
  endfunction

  function void add_child_objects(
    input string uid,
    ref   string children_uid[$]
  );
    foreach (children_uid[i]) begin
      add_child_object(uid, children_uid[i]);
    end
  endfunction

  function void write_string_value(
    string  uid,
    string  name,
    string  value
  );
    void'(pa_writer.set_object_attribute_value_string(uid, name, value));
  endfunction

  function void write_int_value(
    string  uid,
    string  name,
    int     value
  );
    void'(pa_writer.set_object_attribute_value_int(uid, name, value));
  endfunction

  function void write_bit_value(
    string  uid,
    string  name,
    bit     value
  );
    void'(pa_writer.set_object_attribute_value_bit(uid, name, value));
  endfunction

  function void write_bit_vector_value(
    string              uid,
    string              name,
    pzvip_pa_writer_bv  value,
    int                 width
  );
    if (width <= 0) begin
      return;
    end
    void'(pa_writer.set_object_attribute_value_bit_vector(uid, name, value, width));
  endfunction

  function void memory_read(
    longint unsigned    address,
    pzvip_pa_writer_bv  data,
    bit                 backdoor
  );
    if (backdoor) begin
      void'(pa_writer.mem_peek(address >> word_address_shift, data));
    end
    else begin
      void'(pa_writer.mem_read(address >> word_address_shift, data));
    end
  endfunction

  function void memory_write(
    longint unsigned    address,
    pzvip_pa_writer_bv  data,
    bit                 backdoor
  );
    if (backdoor) begin
      void'(pa_writer.mem_poke(address >> word_address_shift, data));
    end
    else begin
      void'(pa_writer.mem_write(address >> word_address_shift, data));
    end
  endfunction

  function void memory_write_masked(
    longint unsigned    address,
    pzvip_pa_writer_bv  data,
    pzvip_pa_writer_bv  byte_mask,
    pzvip_pa_writer_bv  result,
    bit                 backdoor
  );
    if (backdoor) begin
      memory_write(address, result, 1);
    end
    else begin
      pzvip_pa_writer_bv  bit_mask;

      bit_mask  = '0;
      for (int i = 0;i < pa_writer_configuration.data_width;i += 8) begin
        bit_mask[i+:8]  = {8{byte_mask[i/8]}};
      end

      void'(pa_writer.mem_write_masked(address >> word_address_shift, data, bit_mask, result));
    end
  endfunction

  protected function void write_logical_address(string uid, longint unsigned address);
    if (!pa_writer_configuration.enable_memory_writer) begin
      return;
    end

    write_bit_vector_value(uid, "logical_address", address >> word_address_shift, word_address_width);
  endfunction
`else
  function void build(
    uvm_component                 parent,
    pzvip_pa_writer_configuration pa_writer_configuration,
    string                        if_path
  );
  endfunction

  function string create_pa_object(
    string  object_name,
    time    start_time,
    string  channel_name    = "",
    string  parent_uid      = "",
    string  predecessor_uid = ""
  );
  endfunction

  protected virtual function void create_pa_writer(uvm_component parent, string if_path);
  endfunction

  function void close_pa_object(string uid);
  endfunction

  function void add_child_object(string uid, string child_uid);
  endfunction

  function void add_child_objects(
    input string uid,
    ref   string children_uid[$]
  );
  endfunction

  function void write_string_value(
    string  uid,
    string  name,
    string  value
  );
  endfunction

  function void write_int_value(
    string  uid,
    string  name,
    int     value
  );
  endfunction

  function void write_bit_value(
    string  uid,
    string  name,
    bit     value
  );
  endfunction

  function void write_bit_vector_value(
    string        uid,
    string        name,
    bit [1023:0]  value,
    int           width
  );
  endfunction

  function void memory_read(
    longint unsigned    address,
    pzvip_pa_writer_bv  data,
    bit                 backdoor
  );
  endfunction

  function void memory_write(
    longint unsigned    address,
    pzvip_pa_writer_bv  data,
    bit                 backdoor
  );
  endfunction

  function void memory_write_masked(
    longint unsigned    address,
    pzvip_pa_writer_bv  data,
    pzvip_pa_writer_bv  byte_mask,
    pzvip_pa_writer_bv  result,
    bit                 backdoor
  );
  endfunction

  protected function void write_logical_address(string uid, longint unsigned byte_address);
  endfunction
`endif

  `tue_object_default_constructor(pzvip_pa_writer_base)
endclass

class pzvip_pa_writer_param_base #(
  type  CONFIGURATION = tue_configuration_dummy,
  type  STATUS        = tue_status_dummy
) extends tue_object_base #(
  .BASE           (pzvip_pa_writer_base ),
  .CONFIGURATION  (CONFIGURATION        ),
  .STATUS         (STATUS               )
);
  `tue_object_default_constructor(pzvip_pa_writer_param_base)
endclass
`endif
